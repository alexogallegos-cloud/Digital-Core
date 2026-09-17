CREATE PROCEDURE "informix".sp_cancelactatf_web(pEmpresa CHAR(3), pNumCtetf CHAR(20), pNumCtatf CHAR(20), pEmpleado CHAR(8), pSucursal CHAR(4))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)	  AS  CodRet,
	CHAR(60)  AS  Mensaje,
	CHAR(22)  AS  FolioCAncel;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cMensaje				CHAR(60);
	DEFINE dFechaHoy			DATE;
	DEFINE dHoraActual			DATETIME HOUR TO SECOND;
	DEFINE cFolioCancel         CHAR(22); 
	DEFINE cStatusCuenta		CHAR(1);
	DEFINE mUltimoSaldo			MONEY(14,2);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EJECUTADO EXISTOSAMENTE';
	LET dFechaHoy			= DATE(1);
	LET dHoraActual			= CURRENT HOUR TO FRACTION(3);
	LET cFolioCancel		= '';
	LET cStatusCuenta		= '';
	LET mUltimoSaldo		= 0.00;
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_cancelactatf_web.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cMensaje,cFolioCancel;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCtetf,'') = '' OR NVL(pNumCtatf,'') = '' OR 
			NVL(pEmpleado,'') = '' OR NVL(pSucursal,'') = '' THEN 
		
			LET cCodRet = '00001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cFolioCancel;
			
		END IF;
			
		--SE VALIDA SI NUMERO DE CLIENTE Y CUENTA EXISTE.
		IF(SELECT count(numcte_tf) FROM "informix".tf_maecte 
					WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf) > 0 THEN 
				
			SELECT status_cta, ultimo_saldo
			INTO cStatusCuenta, mUltimoSaldo
			FROM "informix".tf_maecte
			WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf;
			
			IF NVL(mUltimoSaldo,0.00) <> 0.00 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR, LA CUENTA TIENE SALDO';
				RETURN cCodRet,cMensaje,cFolioCancel;
			END IF;
			
			IF cStatusCuenta = '1' THEN
				SELECT {+ INDEX (si_fechas idx_si_fechas)} fecha_hoy 
				INTO dFechaHoy
				FROM bdinteg:"informix".si_fechas
				WHERE empresa = pEmpresa;
			
				UPDATE "informix".tf_maecte SET status_cta = '2', fec_cancelac = dFechaHoy 
				WHERE empresa = pEmpresa AND cuenta_tf = pNumCtatf AND numcte_tf = pNumCtetf AND status_cta = '1';
			
				--FOLIO DE CANCELACION
				LET cFolioCancel = LPAD(pEmpleado,8,'0') || YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || 
									LPAD(DAY(dFechaHoy),2,'0') || LPAD(SUBSTR(dHoraActual,1,2),2,'0') || 
									LPAD(SUBSTR(dHoraActual,4,2),2,'0') || LPAD(SUBSTR(dHoraActual,7,2),2,'0'); 
			
				INSERT INTO "informix".tf_ctacancelada (empresa,cuenta_tf,folio_cancelacion,motivo,promotor_cancelo,sucursal,fecha_cancelacion) 
				VALUES (pEmpresa, pNumCtatf,cFolioCancel,'Peticion del Cliente', pEmpleado,pSucursal,dFechaHoy);
			
			--SE ELIMINA DE SC_CUENTA_TELEFONO POR CANCELACIONN DE NUMERO TRANSFER	
			DELETE FROM bdicheq:"informix".sc_cuenta_telefono 
			WHERE  cuenta = pNumCtatf AND es_transfer='S';
			
			ELIF cStatusCuenta = '2' THEN
				LET cCodRet = '00002';
				LET cMensaje = 'ERROR, LA CUENTA YA ESTA CANCELADA';
			END IF; 
		END IF;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00003';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN cCodRet,cMensaje,cFolioCancel;
	
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Cancela cuenta transfer y registra los datos de la cuenta cancelada',
'FECHA: 17/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';