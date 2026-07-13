CREATE PROCEDURE "informix".sp_generaarchivo_pagosprogramadostdc()

RETURNING
    CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE cMensaje CHAR(80);

DEFINE iSqlErr						INTEGER;
DEFINE vFechaConsultada				DATE;
DEFINE cRutaArchPagosProg			CHAR(50);
DEFINE vFecha_Pago					DATE;
DEFINE vSucursal					CHAR(4);
DEFINE vPromotor					CHAR(8);
DEFINE vCliente						CHAR(15);
DEFINE vCuenta						CHAR(15);
DEFINE cStmt						CHAR(250);
DEFINE vNumEjecuciones				INTEGER;
DEFINE vEstatusEjecucion			INTEGER;



--INICIALIZACION DE VARIABLES--
LET cCodRet = "00000";
LET cMensaje = 'PROCESO EXITOSO';

LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET vFechaConsultada		= current::date -1;

LET vFecha_Pago				= "";
LET vSucursal				= "";
LET vPromotor				= "";
LET vCliente				= "";
LET vCuenta					= "";
LET cStmt					= "";
LET vNumEjecuciones			= 0;
LET vEstatusEjecucion		= 1;

--RECUPERA RUTA Y NOMBRE DEL ARCHIVO A GENERAR--
	SELECT TRIM(valor) || "PPROG" || LPAD(DAY(vFechaConsultada),2,0) 
								  || LPAD(MONTH(vFechaConsultada),2,0) 
								  || LPAD(substr(year(vFechaConsultada),3,2),2,0) || ".txt"
			INTO cRutaArchPagosProg
			FROM bdisac:"informix".sac_param
			WHERE cod_param = '119';


	--SET DEBUG FILE TO  '/RESPALDOS/sp_generaarchivo_pagosprogramadostdc.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				LET vEstatusEjecucion		= 0;
				LET vNumEjecuciones =(select count(*) from bdisac:"informix".sac_procesos_jobs where proceso='522_PAGOSPROG_TDC_FINANZAS_PRO' and fecha_proceso=vFechaConsultada);

				IF vNumEjecuciones > 0 THEN
					UPDATE bdisac:"informix".sac_procesos_jobs SET numero_ejecuciones=vNumEjecuciones + 1, fecha_insert=current WHERE proceso='522_PAGOSPROG_TDC_FINANZAS_PRO' and fecha_proceso=vFechaConsultada;
				ELSE
					INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion) 
	    			VALUES('522_PAGOSPROG_TDC_FINANZAS_PRO', vFechaConsultada, vEstatusEjecucion, 'informix', current, vNumEjecuciones + 1, 'sp_generaarchivo_pagosprogramadostdc', 'Genera reporte diario de Pagos Prog de TDC se ejecuta 5:00 hrs.');
				END IF;

				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

				
	--SI EXISTE UN ARCHIVO LLAMADO IGUAL (EJECUCIÃN PREVIA), LO ELIMINA--
		LET cStmt = 'rm -f ' || cRutaArchPagosProg;
		SYSTEM cStmt;

	--GENERA ARCHIVO NUEVO Y AGREGA ENCABEZADO--
		LET cStmt = 'echo "' || RPAD('FECHA_PAGO',10,' ') || ' ' || RPAD('SUC.',4,' ') || ' ' || RPAD('PROMOTOR',8,' ') || ' ' || RPAD('NUM_CLIENTE',15,' ') || ' ' || RPAD('NUM_CUENTA',15,' ') || ' ' || chr(13) || '" >> ' || cRutaArchPagosProg;
		SYSTEM cStmt;

	--AGREGA LINEA EN BLANCO--
		LET cStmt = 'echo "" >> ' || cRutaArchPagosProg;
		SYSTEM cStmt;

	--INSERTA LOS PAGOS PROGRAMADOS DEL DÃA--
		FOREACH SELECT PEN.fecha_aplic, EJE.sucursal, EJE.ejecutivo, PRG.num_cte, PRG.cuenta_origen
            INTO vFecha_Pago, vSucursal, vPromotor, vCliente, vCuenta
		    FROM bdiprog:"informix".pp_pagoprog PRG
		       , bdiprog:"informix".pp_pagospend  PEN
		       , bdinteg:"informix".si_ejecut EJE
		    WHERE PRG.cve_pagoprog = PEN.cve_pagoprog
		            AND EJE.ejecutivo=PEN.user_insert
		            AND PEN.estado = '05' -- 05	Aplicado
		            AND PRG.cve_pago IN ('05','06') -- 05 Pago de Tarjeta de Credito Bancoppel Visa 
		            								-- 06 Pago de Tarjeta de Credito Otro Banco
		            AND PEN.fecha_aplic = vFechaConsultada
			
			LET cStmt = 'echo "' || vFecha_Pago || ',' || vSucursal || ',' || vPromotor || ',' || vCliente || ',' || vCuenta || ',' || chr(13) || '" >> ' || cRutaArchPagosProg;
			SYSTEM cStmt;
			
		END FOREACH;

	--REVISA NUMERO DE EJECUCIONES DEL DÃA Y ACTUALIZA O INSERTA EL REGISTRO, SEGUN SEA EL CASO--
		LET vNumEjecuciones =(select count(*) from bdisac:"informix".sac_procesos_jobs where proceso='522_PAGOSPROG_TDC_FINANZAS_PRO' and fecha_proceso=vFechaConsultada);

		IF vNumEjecuciones > 0 THEN
			UPDATE bdisac:"informix".sac_procesos_jobs SET numero_ejecuciones=vNumEjecuciones + 1, fecha_insert=current WHERE proceso='522_PAGOSPROG_TDC_FINANZAS_PRO' and fecha_proceso=vFechaConsultada;
		ELSE
			INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion) 
	    	VALUES('522_PAGOSPROG_TDC_FINANZAS_PRO', vFechaConsultada, vEstatusEjecucion, 'informix', current, vNumEjecuciones + 1, 'sp_generaarchivo_pagosprogramadostdc', 'Genera reporte diario de Pagos Prog de TDC se ejecuta 5:00 hrs.');
		END IF;
		
		RETURN cCodRet, cMensaje; 
	END;
END PROCEDURE;