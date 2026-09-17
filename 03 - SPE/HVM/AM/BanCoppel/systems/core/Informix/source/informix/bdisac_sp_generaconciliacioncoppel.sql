CREATE PROCEDURE "informix".sp_generaconciliacioncoppel(pFecha_Hoy DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;


-- DEFINICION DE VARIABLES
DEFINE cCodRet					CHAR(5);
DEFINE cCodRetSP				CHAR(5);
DEFINE cMensaje					CHAR(80);
DEFINE iSqlErr     	 			INTEGER;
DEFINE iIsamErr     			INTEGER;
DEFINE cInfoErr  				VARCHAR(100);
DEFINE cNumcategoria			CHAR(2);
DEFINE cNumconvenio				CHAR(3);
DEFINE dFecha_ini				DATE;
DEFINE iDias_rang				INTEGER;
DEFINE cMovimiento          	CHAR(2);
DEFINE cTipomovimiento      	CHAR(2);
DEFINE cStatus						CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET cCodRetSP					= "99999";
LET cMensaje					= 'PROCESO EXITOSO';
LET iSqlErr						= 0;
LET cNumcategoria 				= '';
LET cNumconvenio 				= '';
LET dFecha_ini					= DATE(1);
LET iDias_rang					= 0;
LET cMovimiento             	= '';
LET cTipomovimiento         	= '';
LET cStatus						= '0';

	--SET DEBUG FILE TO  '/informix/EPG/sp_generaconciliacioncoppel.out';
	--TRACE ON;

	BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_generaconciliacioncoppel");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
		--OBTENGO VALOR DE DIAS DE TOLERANCIA PARA INCLUIR EN ARCHIVO
		SELECT valor
		INTO   iDias_rang
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
			
		FOREACH
			
			SELECT a.numcategoria, a.numconvenio, b.movimiento, b.tipomovimiento
			INTO cNumcategoria, cNumconvenio, cMovimiento, cTipomovimiento
			FROM   bdisac:"informix".sac_convenios as a, bdisac:"informix".sac_servicios_cpl as b
			WHERE  a.numcategoria = b.numcategoria
			AND a.numconvenio = b.numconvenio
			AND b.conciliacion = '1'
			
			--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
			SELECT fecha_ultimo_archivo
			INTO   dFecha_ini
			FROM   "informix".sac_controlarchivoscobranza
			WHERE  numcategoria = cNumcategoria
			AND    numconvenio  = cNumconvenio;
			
			--BORRO TABLA TEMPORAL SI EXISTE
			DROP TABLE IF EXISTS tmp_movs;
			
			--CREO TABLA TEMPORAL
			CREATE TEMP TABLE tmp_movs(
			  folio_suc    CHAR(16),
			  fecha_pago   DATE,
              numcategoria CHAR(2),
              numconvenio  CHAR(3)) WITH NO LOG;
			  

			--GUARDAR LOS CONCILIADOS
			--INSERT INTO bdisac:"informix".sac_movimientos_bcpl_cpl
			INSERT INTO tmp_movs
			SELECT b.folio_suc, b.fecha_pago, b.numcategoria, b.numconvenio
			FROM bdisac:"informix".sac_conciliacion_bcpl_cpl AS a					
			INNER JOIN 
			TABLE (MULTISET(SELECT id_sucursal,numcategoria,numconvenio,referencia1,referencia2,forma_pago,importe_pago,importe_comision_convenio,iva_comision_convenio,
				importe_comision_cte,iva_comision_cte,cuenta_cargo,usuario,folio_suc,transacc_suc,flag_confirmacion_central,flag_confirmacion_sucursal,
				fecha_pago,fecha_insert,status_cancelado,origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4 
			FROM "informix".sac_movimientos
			WHERE  numcategoria     =  cNumcategoria
			AND    numconvenio      =  cNumconvenio
			AND    fecha_pago       =  pFecha_Hoy
			AND    status_cancelado <> 'S'
			AND    (flag_confirmacion_central  = 1
			OR     flag_confirmacion_sucursal  = 1)
			AND    id_sucursal = '9764'
			UNION ALL
			SELECT id_sucursal,numcategoria,numconvenio,referencia1,referencia2,forma_pago,importe_pago,importe_comision_convenio,iva_comision_convenio,
				importe_comision_cte,iva_comision_cte,cuenta_cargo,usuario,folio_suc,transacc_suc,flag_confirmacion_central,flag_confirmacion_sucursal,
				fecha_pago,fecha_insert,status_cancelado,origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4 
			FROM "informix".sac_movimientoshistorial
			WHERE  numcategoria     =  cNumcategoria
			AND    numconvenio      =  cNumconvenio
			AND    fecha_pago       >  dFecha_ini - iDias_rang
			AND    fecha_pago       <= pFecha_Hoy
			AND    status_cancelado <> 'S'
			AND    (flag_confirmacion_central  = 1
			OR     flag_confirmacion_sucursal  = 1)
			AND    id_sucursal      = '9764')) AS b
		  --ON     a.tienda         = b.sucursal_cpl::INTEGER
		  --AND    a.caja           = b.caja_cpl
		  --AND    a.numerotiket    = b.folio_operacion
		  --AND    a.foliosucursal  = b.folio_suc
			ON     a.foliosucursal  = b.folio_suc
			AND    a.fechapago      = b.fecha_pago
            AND    a.tipomovimiento = (SELECT tipomovimiento FROM sac_servicios_cpl WHERE numcategoria = b.numcategoria AND numconvenio = b.numconvenio )
			WHERE  a.st_conciliado  = 0;
			
			--ACTUALIZA LAS CONCILIADAS ANTERIOES QUE FUERON CONCILIADOS CON EL ARCHIVO DE COPPEL DEL DIA
			MERGE INTO bdisac:"informix".sac_conciliacion_bcpl_cpl AS a 
			USING bdisac:"informix".tmp_movs AS b
			ON a.foliosucursal || a.fechapago = b.folio_suc || b.fecha_pago 
            AND    a.tipomovimiento = (SELECT tipomovimiento FROM sac_servicios_cpl WHERE numcategoria = b.numcategoria AND numconvenio = b.numconvenio )
			WHEN MATCHED THEN UPDATE SET a.st_conciliado = 1, a.fecha_concil = TODAY;
			
			DROP TABLE IF EXISTS tmp_movs;
			
		END FOREACH;	
			
		RETURN cCodRet, cMensaje;
	
	END;
	
END PROCEDURE
;