CREATE PROCEDURE "informix".sp_act_susc_ctes(pNumCte CHAR(20), pCod1 CHAR(1), pCod2 CHAR(1),pCod3 CHAR(1),pCod4 CHAR(1),
											 pCod5 CHAR(1),pCod6 CHAR(1),pCod7 CHAR(1),pCod8 CHAR(1))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(40)  AS cMensaje,
		  CHAR(20)  AS cNumCte;
		  		  
DEFINE cCodRet      CHAR (5);
DEFINE cMensaje     CHAR (40);
DEFINE cNumCte		CHAR (20);
DEFINE vCod1		CHAR (1);
DEFINE vCod2		CHAR (1);
DEFINE vCod3		CHAR (1);
DEFINE vCod4		CHAR (1);
DEFINE vCod5		CHAR (1);
DEFINE vCod6		CHAR (1);
DEFINE vCod7		CHAR (1);
DEFINE vCod8		CHAR (1);
DEFINE vCod         CHAR (3);  
DEFINE iSqlErr		INTEGER;
DEFINE iCont		INTEGER;
DEFINE sCodigo		CHAR(3);

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet 	= '00000';
LET cMensaje 	= '';
LET cNumCte 	= '';
LET vCod1 		= '0';
LET vCod2 		= '0';
LET vCod3 		= '0';		  
LET vCod4 		= '0';		  
LET vCod5 		= '0';
LET vCod6 		= '0';
LET vCod7 		= '0';
LET vCod8 		= '0';
LET vCod        = '0';
LET iSqlErr    	= 0;
LET iCont       = 0;
LET sCodigo		= '';
/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/douglas/cancelacionsms/sp_act_susc_ctes.out";
--TRACE ON;		  
		  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			
			RETURN cCodRet,cMensaje,cNumCte;
			
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	-- SE VALIDA SI LOS PARAMETROS VIENEN VACIOS
	IF NVL(pNumCte,'') = '' AND  NVL(pCod1,'') = '' AND NVL(pCod2,'') = '' AND NVL(pCod3,'') = '' AND NVL(pCod4,'') = '' AND NVL(pCod5,'') = '' AND NVL(pCod6,'') = '' AND NVL(pCod7,'') = '' AND NVL(pCod8,'') = '' THEN 
	
		LET cCodRet = '00001';    -- Error De Parametros De Entrada
		LET cMensaje = 'Parametros De Entrada Vacíos';
		RETURN cCodRet,cMensaje,cNumCte;
			
	ELSE 
		FOREACH 
		
			SELECT codigo INTO sCodigo 
			FROM bdimnsj:"informix".mnsjr_suscripcion_ctes WHERE numcte=pNumCte
			
			IF sCodigo = '001' AND pCod1 = '1' THEN -- Contrato de productos o servicios
				LET pCod1='5';			END IF;
			IF sCodigo = '002' AND pCod2 = '1' THEN -- Transferencia o Retiros
				LET pCod2='5';			END IF;
			IF sCodigo = '003' AND pCod3 = '1' THEN -- Activacion de tarjeta de debito
				LET pCod3='5';			END IF;
			IF sCodigo = '004' AND pCod4 = '1' THEN -- depositos en cuentas de debito
				LET pCod4='5';			END IF;
			IF sCodigo = '005' AND pCod5 = '1' THEN -- Actualizacion de domicilio
				LET pCod5='5';			END IF;
			IF sCodigo = '006' AND pCod6 = '1' THEN -- Actualizaciòn de Tel/Correo
				LET pCod6='5';			END IF;
			IF sCodigo = '007' AND pCod7 = '1' THEN -- Activaciòn de tarjeta de credito
				LET pCod7='5';			END IF;
			IF sCodigo = '008' AND pCod8 = '1' THEN -- Pago tarjeta de credito
				LET pCod8='5';			END IF;
			
		
		END FOREACH
		
		IF pCod1 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'001',CURRENT);
		ELIF pCod1 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '001';
		END IF;
		
		IF pCod2 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'002',CURRENT);
		ELIF pCod2 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '002';
		END IF;
		
		IF pCod3 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'003',CURRENT);
		ELIF pCod3 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '003';
		END IF;
		
		IF pCod4 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'004',CURRENT);
		ELIF pCod4 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '004';
		END IF;
		
		IF pCod5 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'005',CURRENT);
		ELIF pCod5 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '005';
		END IF;
		
		IF pCod6 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'006',CURRENT);
		ELIF pCod6 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '006';
		END IF;
		
		IF pCod7 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'007',CURRENT);
		ELIF pCod7 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '007';
		END IF;
		
		IF pCod8 = '1' THEN -- Contrato de productos o servicios
				INSERT INTO "informix".mnsjr_suscripcion_ctes (numcte,codigo,fecha_insert) VALUES (pNumCte,'008',CURRENT);
		ELIF pCod8 = '0' THEN
			DELETE FROM "informix".mnsjr_suscripcion_ctes WHERE numcte = pNumCte AND codigo = '008';
		END IF;

	END IF;
	RETURN cCodRet,cMensaje,cNumCte;
END;		  
END PROCEDURE;