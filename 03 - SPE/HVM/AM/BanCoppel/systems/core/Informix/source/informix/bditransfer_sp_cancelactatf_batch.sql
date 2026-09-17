CREATE PROCEDURE "informix".sp_cancelactatf_batch()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(6)	  AS  CodRet,
	CHAR(60)  AS  Mensaje;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	DEFINE dFechaHoy			DATE;
	DEFINE dHoraActual			DATETIME HOUR TO SECOND;
	DEFINE cFolioCancel         CHAR(22); 
	DEFINE cStatusCuenta		CHAR(1);
	DEFINE mUltimoSaldo			MONEY(14,2);
	
	DEFINE cempresa CHAR(3);
	DEFINE cnumcte_tf CHAR(20);
	DEFINE ccuenta_tf CHAR(20);
	DEFINE ctelefono CHAR(13);
	DEFINE cejecutivo CHAR(8);
	DEFINE csucursal CHAR(4);
	DEFINE cstatus_cta CHAR(1);
	DEFINE cfolio CHAR(12);
	DEFINE cmpstransactionid CHAR(12);
	DEFINE msaldo MONEY;
	
	DEFINE cont INTEGER;
	LET cont = 0;
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'PROCESO EJECUTADO EXISTOSAMENTE';
	--LET dFechaHoy			= DATE(1);
	LET cFolioCancel		= '';
	LET cStatusCuenta		= '';
	--LET mUltimoSaldo		= 0.00;
	
	LET cempresa 			= '001';
	LET cejecutivo 			= '98309684';
	LET csucursal 			= '9646';
	LET cstatus_cta 		= '3';
	LET cfolio 				= '';
	LET cmpstransactionid 	= '999999999999';
	LET dFechaHoy 			= TODAY;
	LET dHoraActual			= CURRENT HOUR TO FRACTION(3);
	
	--SET DEBUG FILE TO "/tmp/leestrada/2019-01-04/sp_cancelactatf_batch.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT {+AVOID_FULL()} numcte_tf, cuenta_tf, telefono
			INTO cnumcte_tf, ccuenta_tf, ctelefono
			FROM "informix".tf_maecte 
			WHERE status_cta = 1 AND numcte_tf IS NOT NULL
		
			--Consulta anterior
			--SELECT empresa, numcte_tf, cuenta_tf, telefono,	ejecutivo, sucursal, status_cta, folio,	mpstransactionid, saldo 
			--INTO cempresa, cnumcte_tf, ccuenta_tf, ctelefono, cejecutivo, csucursal, cstatus_cta, cfolio, cmpstransactionid, msaldo 
			--FROM "informix".tf_cancelacioncte_batch
			
			--pNuevoStatus DEBE SER '2' o '3'
			UPDATE "informix".tf_maecte SET status_cta = cstatus_cta, fec_cancelac = dFechaHoy 
			WHERE empresa = cempresa AND cuenta_tf = ccuenta_tf AND numcte_tf = cnumcte_tf AND status_cta = '1';
				
			--FOLIO DE CANCELACION
			LET cFolioCancel = LPAD(cejecutivo,8,'0') || YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || 
				LPAD(DAY(dFechaHoy),2,'0') || LPAD(SUBSTR(dHoraActual,1,2),2,'0') || 
				LPAD(SUBSTR(dHoraActual,4,2),2,'0') || LPAD(SUBSTR(dHoraActual,7,2),2,'0'); 
				
			INSERT INTO "informix".tf_ctacancelada (empresa, cuenta_tf, folio_cancelacion, motivo, promotor_cancelo, sucursal, fecha_cancelacion) 
				VALUES (cempresa, ccuenta_tf, cFolioCancel, 'P. Productos(Bloq)', cejecutivo, csucursal, dFechaHoy);
			--SE ELIMINA DE SC_CUENTA_TELEFONO POR CANCELACIONN DE NUMERO TRANSFER	
			DELETE FROM bdicheq:"informix".sc_cuenta_telefono 
				WHERE cuenta = ccuenta_tf AND es_transfer='S';
					
			--ACTUALIZA LA BITACORA
			INSERT INTO "informix".tf_bitacora_transadmin(numcte_tf, folio, mpstransactionid, tipo, fecha_insert, ejecutivo) 
				VALUES (cnumcte_tf, cFolioCancel, cmpstransactionid, cstatus_cta, CURRENT, cejecutivo);
				
			LET cont = cont + 1;
			IF(cont = 1000) THEN
				COMMIT WORK;
				LET cont = 0;
				BEGIN WORK; 
			END IF;
		END FOREACH;
		IF(cont < 1000) THEN
			COMMIT WORK;
			LET cont = 0;
			BEGIN WORK; 
		END IF;
		
		RETURN cCodRet, cMensaje;
	
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Lauro Esaú Estrada López',
'DESCRIPCION: Cancela cuentas transfer pendientes y registra los datos de la cuenta cancelada',
'FECHA: 04/01/2019',
'SUSTENTO: Se cancelan cuentas transfer por baja del servicio.',
'BD: BDITRANSFER';