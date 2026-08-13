CREATE PROCEDURE "informix".sp_buscardetallectatf_web(pEmpresa CHAR(3), pNumCteTf CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) AS  	CodRet,
	CHAR(60) AS  	Mensaje,
	CHAR(20) AS 	NumCteTf,
	CHAR(20) AS 	NumCtaTf,
	CHAR(16) AS 	NumTarjeta,
	CHAR(4) AS 		NumProd,
	DATE AS			FechaAlta,
	CHAR(1) AS		StatusCta,
	MONEY(14,2) AS  UltimoSaldo;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cMensaje				CHAR(60);
	DEFINE cNumCteTf			CHAR(20);
	DEFINE cNumCtaTf			CHAR(20);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE cNumProd				CHAR(4);
	DEFINE dFechaAlta			DATE;
	DEFINE cStatusCta			CHAR(1);
	DEFINE mUltimoSaldo			MONEY(14,2);
	
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cMensaje			= 'EJECUTADO EXITOSAMENTE';
	LET cNumCteTf			= '';
	LET cNumCtaTf			= '';
	LET cNumTarjeta			= '';
	LET cNumProd			= '';
	LET dFechaAlta			= DATE(1);
	LET cStatusCta			= '';
	LET mUltimoSaldo		= 0.00;
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_buscardetallectatf_web.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
				RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCteTf,'') = '' THEN
			LET cCodRet = '00001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
		END IF;
		
		FOREACH
		
			SELECT numcte_tf, cuenta_tf, num_tarjeta, producto, fec_alta, status_cta, ultimo_saldo
				INTO cNumCteTf, cNumCtaTf, cNumTarjeta, cNumProd, dFechaAlta, cStatusCta, mUltimoSaldo
				FROM "informix".tf_maecte
				WHERE empresa = pEmpresa 
				AND numcte_tf = pNumCteTf
			
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00) WITH RESUME;
			
		END FOREACH

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
		END IF;

	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Realiza una consulta para obtener detalles de la cuenta del cliente',
'FECHA: 11/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';