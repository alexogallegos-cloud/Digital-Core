CREATE PROCEDURE "informix".sp_marcaje_quitacondonacion()
--EXECUTE PROCEDURE sp_marcaje_quitacondonacion();
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE COD_RET      		CHAR(5);
DEFINE cCodRet2				CHAR(6);
DEFINE cCodRet      	    CHAR(6);
DEFINE cMen_ret 			VARCHAR(100,1);
DEFINE cNumeroFolio 	    CHAR(16);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vNumCte 			    CHAR(20);
DEFINE vNumProducto        CHAR(4);
--DEFINE vNumProductoP        CHAR(4);
DEFINE vIndProc			    CHAR(1);
DEFINE vDia					CHAR(2);
DEFINE vMes					CHAR(2);
DEFINE vAnio				CHAR(4);
DEFINE vFechaHoy            DATE;

DEFINE nombre_cliente       CHAR(105);
DEFINE cSQL                 CHAR(1000);
DEFINE cParamInsumo         CHAR(100);
DEFINE cParamRepCondona     CHAR(100);
DEFINE cParamRepQuita       CHAR(100);
DEFINE cRutaArch            CHAR(100);
DEFINE cRutaInsumo          CHAR(100);
DEFINE cNumProducto         CHAR(4);
DEFINE vNombre1             CHAR(26);
DEFINE vNombre2				CHAR(26);
DEFINE vApellPat			CHAR(26);
DEFINE vApellMat			CHAR(26);
DEFINE vTelefono			CHAR(13);

DEFINE vSaldoLiquidar       DECIMAL(18,2);
DEFINE vCopeteMoratorio     DECIMAL(18,2);
DEFINE vCopeteMoratorioIva	DECIMAL(18,2);
DEFINE vExiste              SMALLINT;
DEFINE vCred                CHAR(1);
DEFINE vCuenta              SMALLINT;
DEFINE vExisteQ             INTEGER;
DEFINE vExisteC				INTEGER;

DEFINE cArchivo_dbld		CHAR(50);
DEFINE cArchivo_log			CHAR(50);
DEFINE cArchivo_out			CHAR(50);
DEFINE vArchivoCarga        CHAR(25);
DEFINE vStatusProceso       CHAR(2);
DEFINE vFechaStatus         DATE;
DEFINE dFechaInsert			DATE;
DEFINE vNombreCte   		CHAR(110);
DEFINE dSdoCapInsoluto		DECIMAL(18,2);
DEFINE dPagoMinimo			DECIMAL(18,2);
DEFINE dIntVdo				DECIMAL(18,2);
DEFINE dIntMoratorio		DECIMAL(18,2);
DEFINE vTotalIntMoratorio   DECIMAL(18,2);
DEFINE dIvaIntVdo			DECIMAL(18,2);
DEFINE dPagosVdos			DECIMAL(18,2);
DEFINE dIvaIntMoratorio		DECIMAL(18,2);
DEFINE dIntMes				DECIMAL(18,2);
DEFINE dIvaIntMes			DECIMAL(18,2);
DEFINE dIntVig				DECIMAL(18,2);
DEFINE dIvaIntVig			DECIMAL(18,2);
DEFINE vSucursal			CHAR(04);
DEFINE dIvaSuc              DECIMAL(5,3);
DEFINE cSucursal            CHAR(4);
DEFINE dIntMoratorio_d	    DECIMAL(18,2);


LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET COD_RET         		= "00000";
LET cMen_ret     			= "";
LET cNumeroFolio            = "";
LET cCodRet2                = '';
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vNumCte                 = '';
LET vNumProducto            = '';
--LET vNumProductoP           = '';
LET vNombre1                = '';
LET vNombre2				= '';
LET vApellPat			    = '';
LET vApellMat			    = '';
LET vTelefono			    = '';
LET vIndProc                = '';
LET vDia					= '';
LET vMes					= '';
LET vAnio				    = '';
LET v_empresa 		        = '001';
LET vFechaHoy               = '';
LET cCodRet      	        = '';

LET nombre_cliente			= '';
LET cParamInsumo            = '';
LET cParamRepCondona        = '';
LET cParamRepQuita          = '';
LET cRutaArch               = '';
LET cRutaInsumo             = '';

LET vSaldoLiquidar          = 0;
LET vCopeteMoratorio        = 0;

LET vExiste                 = 0;
LET vCred                   = '0';
LET vCuenta                 = 0;
LET vExisteQ                = 0;
LET vExisteC				= 0;
LET vStatusProceso          = '';
LET vFechaStatus            = '';
LET vNombreCte              = '';
LET dFechaInsert			= DATE(1);

LET vArchivoCarga   = "dbload_cargainsumo.sh";
LET cArchivo_dbld	= "f_carga_insumo.cmd";
LET cArchivo_log	= "f_carga_insumo.log";
LET cArchivo_out	= "f_carga_insumo.out";

LET dSdoCapInsoluto			= 0;
LET dPagoMinimo				= 0;
LET dIntVdo					= 0;
LET dIntMoratorio			= 0;
LET dIvaIntVdo				= 0;
LET dPagosVdos				= 0;
LET dIvaIntMoratorio		= 0;
LET dIntMes					= 0;
LET dIvaIntMes				= 0;
LET dIntVig					= 0;
LET dIvaIntVig				= 0;
LET vCopeteMoratorioIva		= 0;
LET vTotalIntMoratorio		= 0;
LET vSucursal				= '';
LET dIvaSuc                 = 0;
LET cSucursal               = '';
LET dIntMoratorio_d         = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

    IF iSqlErr = -668 THEN
		--system  "0 " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || ".txt";
		--system  "0 " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || ".txt";
		system  "touch " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || ".txt";
		system  "touch " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || ".txt";
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

	--SET DEBUG FILE TO "sp_marcaje_quitacondonacion.out";
	--TRACE ON;
	
	TRUNCATE TABLE sd_paso_marcaje_cq;
	
	-- Nombre de Insumo de Cobranza, Reporte de Condonacion, Reporte de Quita y ruta de archivo 
    SELECT trim(valor) INTO cParamInsumo FROM bdicred:sd_param WHERE cod_param = 991; --Insumo_QuitaCondonacion_DDMMAAAA.txt
	SELECT trim(valor) INTO cParamRepCondona FROM bdicred:sd_param WHERE cod_param = 992;  --Complemento_Condonaciones_
	SELECT trim(valor) INTO cParamRepQuita FROM bdicred:sd_param WHERE cod_param = 993; --Complemento_QuitasCastigos_
	SELECT trim(valor) INTO cRutaInsumo FROM bdicred:sd_param WHERE cod_param = 994; --/resplogifx/archivoscartera/cobranza/
	SELECT trim(valor) INTO cRutaArch FROM bdicred:sd_param WHERE cod_param = 103; --/resplogifx/archivoscartera/cobranza/
	
	--Para Pruebas
/* 	LET cParamInsumo = 'Insumo_QuitaCondonacion_';
	LET cParamRepCondona = 'Complemento_Condonaciones_';
	LET cParamRepQuita = 'Complemento_QuitasCastigos_';
	LET cRutaInsumo = '/ifxsif01/'; --para pruebas
	LET cRutaArch = '/ifxsif01/'; --para pruebas */
	
	--DROP TABLE IF EXISTS "informix".paso_cred;
    --CREATE TABLE "informix".paso_cred (numcte CHAR(20), num_producto CHAR(4)); --Para guardar el nombre de los clientes
			
	SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy) INTO vFechaHoy, vDia, vMes, vAnio FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
    --Para pruebas
/* 	LET vFechaHoy = MDY('05','30','2022'); 
	LET vDia = DAY(vFechaHoy);
	LET vMes = MONTH(vFechaHoy);
	LET vAnio = YEAR(vFechaHoy); */
	
	IF MONTH(vFechaHoy) < 10 THEN LET vMes = '0' || TRIM(vMes); END IF;
	IF DAY(vFechaHoy) < 10 THEN LET vDia = '0' || TRIM(vDia); END IF;
	
	--Se realiza el dbload a la tabla de insumos
	--system ' chmod 777 ' || TRIM(cRutaInsumo)|| TRIM(cParamInsumo) || vDia || vMes || vAnio ||'.txt';	
	system ' echo "FILE ' || TRIM(cRutaInsumo) ||  TRIM(cParamInsumo) || vDia || vMes || vAnio ||'.txt DELIMITER '|| "'" || '|' || "'" || ' 3;' || '">' || TRIM(cRutaArch) || TRIM (cArchivo_dbld);  
	system ' echo "INSERT INTO sd_paso_marcaje_cq;' || '">> ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);
	--system ' chmod 777 ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);	--"f_carga_insumo.cmd"
	 
	system ' echo "dbload -d bdicred -c '|| TRIM(cRutaArch) || TRIM(cArchivo_dbld) ||' -l '|| TRIM(cRutaArch) || TRIM(cArchivo_log) ||' -e 10000 -n 1000 -k | tee -a '|| 
		TRIM(cRutaArch) || TRIM(cArchivo_out) || '"> ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); 
	--system 'chmod 777 ' || TRIM(cRutaArch)|| TRIM(vArchivoCarga); --"dbload_cargainsumo.sh"
	system '/usr/bin/sh ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); --"dbload_cargainsumo.sh"
	
--Proceso de marcaje	
FOREACH WITH HOLD	
--Buscar el credito en la tabla de insumos 
	SELECT a.numcte, a.num_credito, a.indicador_proceso
	INTO vNumCte, vNumCredito,  vIndProc
	FROM bdicred:"informix".sd_paso_marcaje_cq a 

		SELECT cred.num_producto, cred.sucursal INTO vNumProducto, vSucursal --Se realiza busqueda en cuentas revolventes
		FROM bdicred:sd_maecred cred  WHERE cred.empresa  = v_empresa AND cred.num_credito = vNumCredito;	
		
		IF vNumProducto IS NULL OR vNumProducto = '' THEN LET vNumProducto = ''; END IF;
		
		IF vNumProducto = '' THEN --Se realiza busqueda en cuentas a plazo
			SELECT cred.num_producto, cred.sucursal INTO vNumProducto, vSucursal
			FROM bdicred:sd_maecredcrd cred WHERE cred.num_credito = vNumCredito;		
		END IF;
		
		IF vNumProducto = '' OR vNumProducto IS NULL THEN 
			--Se inserta registro en tabla de cuentas duplicadas = rechazadas
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'LA CUENTA NO EXISTE' ,vFechaHoy);
		
			CONTINUE FOREACH; 
		END IF; --Prueba

		SELECT NVL(iva,0) INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = vSucursal
		AND empresa  = v_empresa;				
		
		BEGIN WORK;
		--Para volver a solicitar un nuevo marcaje posterior a liquidar el pago de Condoncacion y Quita/Castigo
		SELECT a.estatus_proceso, a.fecha_status, a.fecha_insert  INTO  vStatusProceso, vFechaStatus, dFechaInsert
		FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
		WHERE a.num_credito = vNumCredito --AND a.estatus_proceso IN ('FI','MA')
		AND fecha_insert = (select MAX(fecha_insert) from sd_bitacora_quitacondonacion where num_credito = vNumCredito);
		
		IF vFechaStatus = '' OR vFechaStatus IS NULL THEN LET vFechaStatus = date(1); END IF;
		IF vStatusProceso IS NULL OR vStatusProceso = '' THEN LET vStatusProceso = ''; END IF;
		
		IF (vFechaStatus = date(1)) OR (ROUND((vFechaHoy - vFechaStatus) / 30.2) >= 3 AND vStatusProceso = 'FI') OR (vStatusProceso IN ('','CN') AND dFechaInsert != vFechaHoy) THEN
			--Se inserta registro en la tabla de bitacora
			INSERT INTO bdicred:"informix".sd_bitacora_quitacondonacion 
			(num_credito, numcte, num_producto,estatus_proceso, indicador_proceso, num_cuenta_chq, copete_moratorio, saldo_tot_liquidar, 
			fecha_status,meses_vencidos, meses_historia, sdo_credito, cap_vigente,
			cap_vencido, int_vigente, int_vencido, int_moratorio, iva_int_vigente, iva_int_vencido,
			iva_int_mora, monto_condonado, pago_realizado, cap_vigente_cq, cap_vencido_cq, int_vigente_cq,
			int_vencido_cq, int_moratorio_cq, iva_int_vigente_cq, iva_int_vencido_cq, iva_int_mora_cq, sdo_remanente_dq,
			fecha_pago, fecha_ult_disp_com, monto_ult_disp_comp, abono_mensual_al_quita, fecha_ult_mov, tipo_ult_mov,
			mto_quita, cap_vigente_dq, cap_vencido_dq, int_vigente_dq, int_vencido_dq, int_moratorio_dq,
			iva_int_vigente_dq, iva_int_vencido_dq, iva_int_mora_dq, fecha_liquidacion, fecha_negociacion, 
			porc_quita, porc_recuperado, fecha_insert)
			VALUES (vNumCredito, vNumCte, vNumProducto, 'MA',vIndProc,'',0,0,vFechaHoy,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','',0,0,'','',			
			0,0,0,0,0,0,0,0,0,'','',0,0,vFechaHoy);
			
			--Se inserta registro en la tabla de autorizacion
		ELSE --Cuenta duplicada en la bitacora, se rechaza cuenta
			--Se inserta registro en tabla de cuentas duplicadas = rechazadas
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
			VALUES (vNumCredito, vNumCte, vIndProc, 'EL CREDITO YA EXISTE EN LA BITACORA' ,vFechaHoy);
		END IF;
		
		IF vIndProc = 'C' THEN --Para Condonacion			
			--Calculo de copete moratorio
			IF vNumProducto in ('6001','6600','7000','8100','8500') THEN				
				SELECT sum( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0))
				INTO vCopeteMoratorio
				FROM "informix".sd_amortiza_credito
				WHERE empresa = v_empresa AND num_credito = vNumCredito AND capital_status IN ("2","7","6")
				AND (mora_provi_ordi + mora_provi_cope) > 0;

				SELECT sum(NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0) * dIvaSuc ))
				INTO vCopeteMoratorioIva
				FROM "informix".sd_amortiza_credito
				WHERE empresa = v_empresa AND num_credito = vNumCredito AND capital_status IN ("2","7","6");

			ELIF vNumProducto in ('6011','6300','6800','6900','7600','7700') THEN
				SELECT sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)))
				INTO vCopeteMoratorio
				FROM bdicred:sd_amortiza_creditocrd
				WHERE empresa = v_empresa AND num_credito = vNumCredito AND capital_status IN (2,7,6);

				SELECT sum((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * dIvaSuc )
				INTO vCopeteMoratorioIva
				FROM bdicred:sd_amortiza_creditocrd
				WHERE empresa = v_empresa AND num_credito = vNumCredito AND capital_status IN (2,7,6);
				
			END IF;		
			--Actualiza valor de copete moratorio del credito
			IF vCopeteMoratorio = 0 THEN LET vCopeteMoratorio = 0; ELSE LET vCopeteMoratorio = vCopeteMoratorio + vCopeteMoratorioIva;  END IF;		
			
			UPDATE bdicred:"informix".sd_bitacora_quitacondonacion SET copete_moratorio = vCopeteMoratorio
			WHERE num_credito = vNumCredito;
			
		ELIF vIndProc = 'Q' THEN --Para Quita		
			--Calculo de saldo a liquidar
			IF vNumProducto in ('6001','6600','7000','8100') THEN
				SELECT sdo_cap_insoluto INTO dSdoCapInsoluto
				FROM bdicred:sd_maesdos 
				WHERE empresa = v_empresa AND num_credito = vNumCredito;		

			ELIF vNumProducto in ('6011','6300','6800','6900','7600','7700') THEN
				SELECT sdo_cap_insoluto INTO dSdoCapInsoluto
				FROM bdicred:sd_maesdoscrd
				WHERE empresa = v_empresa AND num_credito = vNumCredito;		
			END IF;
			
			EXECUTE PROCEDURE "informix".sp_obtener_pagomin(v_empresa,vNumCredito)  
			INTO COD_RET, P_MENSAJE, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;

			IF COD_RET != '00000' THEN 
				LET P_MENSAJE = 'Error en consulta pago minimo '|| trim(vNumCredito);
				RETURN COD_RET,P_MENSAJE;
			ELSE
				LET P_MENSAJE = 'PROCESO EXITOSO';
			END IF;
			
			LET vSaldoLiquidar = dSdoCapInsoluto + dIntMoratorio + dIvaIntMoratorio + dIntVdo + dIvaIntVdo;
								
			--Actualiza valor de saldo a liquidar
			IF vSaldoLiquidar = 0 THEN LET vSaldoLiquidar = 0; ELSE LET vSaldoLiquidar = vSaldoLiquidar; END IF;
			
			UPDATE bdicred:"informix".sd_bitacora_quitacondonacion SET saldo_tot_liquidar = vSaldoLiquidar
			WHERE num_credito = vNumCredito;
			
		END IF;
			
			LET vNumProducto = '';
			LET vSucursal = 0;
		
		LET vNombreCte = TRIM(vNombre1) || ' ' || TRIM(vNombre2) || ' ' || TRIM(vApellPat) || ' ' || TRIM(vApellMat);
		COMMIT WORK;	
END FOREACH 

--Proceso de Generacion de Reportes
--Para Condonacion
SELECT COUNT(a.num_credito) INTO vExisteC 
FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
WHERE a.estatus_proceso = 'MA' AND indicador_proceso = 'C'
AND a.fecha_insert = vFechaHoy;

	IF vExisteC > 0 THEN --Reporte Complementario de Condonacion	
				
		system 'echo " UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArch) || 'ejecuta_reporte_Condonacion.sql;';
				
		  system 'echo "SELECT bitacora.numcte, bitacora.num_credito, bitacora.num_producto,TRIM(cliente.nombre1)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.nombre2)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.apell_paterno)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.apell_materno),TRIM(tel.telefono),' ||
		 ' NVL(bitacora.copete_moratorio,0)' ||
		 ' FROM bdicred:sd_bitacora_quitacondonacion bitacora ' ||
		 ' JOIN bdinteg:si_cliente cliente ON bitacora.numcte = cliente.numcte ' ||
		 ' JOIN bdinteg:si_telefonos tel ON tel.numcte = cliente.numcte AND tel.status_tel = ''A''' ||
		 ' WHERE bitacora.fecha_insert = mdy(' || vMes || ',' || vDia ||',' || vAnio || ') AND bitacora.estatus_proceso = ''MA''' ||
		 ' AND bitacora.indicador_proceso = ''C''' || ';" >> ' || TRIM(cRutaArch) || 'ejecuta_reporte_Condonacion.sql;';
		
		--system 'chmod 777 ' || TRIM(cRutaArch) || 'ejecuta_reporte_Condonacion.sql;';
		
		system 'dbaccess bdicred ' || TRIM(cRutaArch) || 'ejecuta_reporte_Condonacion.sql;';
		
		system  "sed 's/|$//g' " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || "_1.txt > " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || ".txt";

		system 'rm ' || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || "_1.txt";	
		system 'rm ' || TRIM(cRutaArch) || 'ejecuta_reporte_Condonacion.sql;';
	ELSE
		--system  "0 " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || ".txt";
		system  "touch " || TRIM(cRutaArch) || TRIM(cParamRepCondona) || vDia || vMes || vAnio || ".txt";
	END IF;

--Para Quita
SELECT COUNT(a.num_credito) INTO vExisteQ
FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
WHERE a.estatus_proceso = 'MA' AND indicador_proceso = 'Q'
AND a.fecha_insert = vFechaHoy;

	IF vExisteQ > 0 THEN --Reporte Complementario de Quitas	
	
		system 'echo " UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArch) || 'ejecuta_reporte_Quita.sql;';
        
		system 'echo "SELECT bitacora.numcte, bitacora.num_credito, bitacora.num_producto, TRIM(cliente.nombre1)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.nombre2)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.apell_paterno)' || '||' || "' "|| "'" || '||' || 'TRIM(cliente.apell_materno),TRIM(tel.telefono),' ||
		 ' NVL(bitacora.saldo_tot_liquidar,0)' ||		
		 ' FROM bdicred:sd_bitacora_quitacondonacion bitacora ' ||
		 ' JOIN bdinteg:si_cliente cliente ON bitacora.numcte = cliente.numcte ' ||
		 ' JOIN bdinteg:si_telefonos tel ON tel.numcte = cliente.numcte AND tel.status_tel = ''A''' ||
		 ' WHERE bitacora.fecha_insert = mdy(' || vMes || ',' || vDia ||',' || vAnio || ') AND bitacora.estatus_proceso = ''MA''' ||
		 ' AND bitacora.indicador_proceso = ''Q''' || ';" >> ' || TRIM(cRutaArch) || 'ejecuta_reporte_Quita.sql;';
        
		--system 'chmod 777 ' || TRIM(cRutaArch) || 'ejecuta_reporte_Quita.sql;';		
		
		system 'dbaccess bdicred ' || TRIM(cRutaArch) || 'ejecuta_reporte_Quita.sql;';

		system  "sed 's/|$//g' " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || "_1.txt > " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || ".txt";
		
		system 'rm ' || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || "_1.txt";
		system 'rm ' || TRIM(cRutaArch) || 'ejecuta_reporte_Quita.sql;';
	ELSE
		--system  "0 " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || ".txt";
		system  "touch " || TRIM(cRutaArch) || TRIM(cParamRepQuita) || vDia || vMes || vAnio || ".txt";
	END IF;

	--Borra los archivos generados para ejecutar el dbload
	system 'rm ' || TRIM(cRutaArch) || TRIM(vArchivoCarga); --Borra archivo sh
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_dbld); --Borra archivo cmd
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_log); --Borra archivo out
	system 'rm ' || TRIM(cRutaArch) || TRIM(cArchivo_out); --Borra archivo log
		
RETURN COD_RET,P_MENSAJE;
     
END
END PROCEDURE;