CREATE PROCEDURE "informix".sp_reenviotokeniccat(pNumSolicitud CHAR(10))
	RETURNING CHAR(5);

	--// ***************************************************************************
	--//FUNCIONALIDAD:SP utilizada para grabar el reenvio del token.
	--// Autor: Francisco Rodriguez Ibarra
	--//Fecha:18 Marzo 2010
	--//modificacion: Se modifico el update para que desasigne el nstoken de la solicitud
	--//Modifico:Francisco Rodriguez Ibarra
	--//Fecha: 13 Abril 2010
	--27-11-2013
	--Realizo: Jose Ruben Lopez
	--Se cambia el flujo para los estatus nuevos de reposicion de token
	--Solicito:Jose de Jesus Nevarez
	--BD: bdibpi
	--Fecha: 26-08-2015
	--Realizo: 95419888 Elmer López Valenzuela
	--Se modifica para agregar un insert al final para el registro de la conciliación
	--Solicito:Alejandro Vazquez
	--BD: bdibpi
	--// ***************************************************************************
	
---Definicion de variables

DEFINE vsCodRet  		CHAR(5);
DEFINE vSqlErr          INTEGER;
DEFINE vSolicitud		CHAR(10);
DEFINE vId_status 		CHAR(4);
DEFINE vTipo			CHAR(2);

DEFINE cNumCte			CHAR(9);
DEFINE dMonto			DECIMAL(12,2);
DEFINE cSucursal		CHAR(5);

DEFINE cCodRet            CHAR(5);
DEFINE cFolioSucursal     CHAR(16);

--asignacion de valores

LET vsCodRet = '00000';
LET vSqlErr = 0;
LET vSolicitud='';
LET vId_status='';
LET vTipo='';

LET cNumCte = '';
LET dMonto = 0.00;
LET cFolioSucursal = '';
LET cSucursal = '';

--SET DEBUG FILE TO "/tmp/sp_reenviotokeniccat.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet ;
	      END IF;
		END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
		SELECT solicitud,id_status,tipo, numcte, folio_suc, sucursal
		INTO vSolicitud,vId_status,vTipo, cNumCte, cFolioSucursal, cSucursal
		FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud=TRIM(pNumSolicitud);
		
		IF(NVL(vSolicitud,'') <> '' AND NVL(vId_status,'') <> '' AND NVL(vTipo,'') <> '') THEN
			
			IF(vId_status = '170' AND vTipo ='1')THEN
				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=180, tipo=2,ns_token='' WHERE solicitud=TRIM(pNumSolicitud);
			ELIF (vId_status = '170' AND vTipo ='2')THEN
				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=180, tipo=2,ns_token='' WHERE solicitud=TRIM(pNumSolicitud);
			ELIF (vId_status = '170' AND vTipo ='6')THEN
				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=180, tipo=7,ns_token='' WHERE solicitud=TRIM(pNumSolicitud);
			ELIF (vId_status = '170' AND vTipo ='7')THEN
				UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=180, tipo=7,ns_token='' WHERE solicitud=TRIM(pNumSolicitud);
			ELSE
				LET vsCodRet='00002';
			END IF;
		ELSE
			LET vsCodRet='00001';
		END IF
		
		IF vsCodRet = '00000' THEN
				
			IF TRIM(SUBSTR(cFolioSucursal,1,8)) = 'SINCOMIS' THEN
				LET dMonto = 0.00;
			END IF;

			INSERT INTO bdibpi: "informix".tkn_solcobranza 
			(solicitud, Numcte, id_status, f_solicitud, folio_suc, f_cobro, cuenta, monto_tot, T_Persona)
			VALUES (pNumSolicitud, cNumCte, '180', CURRENT, cFolioSucursal, CURRENT, cFolioSucursal, dMonto, '01');
		
		END IF;

		RETURN vsCodRet;
			
	END;
END PROCEDURE;