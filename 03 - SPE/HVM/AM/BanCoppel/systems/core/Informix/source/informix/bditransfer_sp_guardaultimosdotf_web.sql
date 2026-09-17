CREATE PROCEDURE "informix".sp_guardaultimosdotf_web(pEmpresa CHAR(3), pNumCtetf CHAR(20), pNumCtatf CHAR(20), pUltimoSaldo MONEY(14,2))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)	  AS  CodRet,
	CHAR(60)  AS  Mensaje;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cMensaje				CHAR(60);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EJECUTADO EXITOSAMENTE';
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_guardaultimosdotf_web.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCtetf,'') = '' OR NVL(pNumCtatf,'') = '' OR 
			NVL(pUltimoSaldo,'') = '' THEN 
		
			LET cCodRet = '00001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN  cCodRet,cMensaje;
			
		END IF;
			
		--SE VALIDA SI NUMERO DE CLIENTE Y CUENTA EXISTE.
		IF(SELECT count(numcte_tf) FROM "informix".tf_maecte 
					WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf) > 0 THEN 
			
				UPDATE "informix".tf_maecte SET ultimo_saldo = pUltimoSaldo 
				WHERE empresa = pEmpresa AND cuenta_tf = pNumCtatf AND numcte_tf = pNumCtetf;

		END IF;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN  cCodRet,cMensaje;
	
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Actualiza el ultimo_saldo del cliente',
'FECHA: 17/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';