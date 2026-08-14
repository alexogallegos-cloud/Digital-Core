CREATE PROCEDURE "informix".sp_cancelatarjeta_canales(pNumcte CHAR(20),pDigtarjeta CHAR(4),pCanal CHAR(2), pFolio CHAR(16), pNotificacion CHAR(1))
RETURNING CHAR(5) AS rCodigoRetorno, CHAR(160) AS mensaje;
    
	DEFINE vNumcte				CHAR(20);
    DEFINE vDigtarjeta  		CHAR(4);
    DEFINE vCanal        		CHAR(2);
    DEFINE vFolio        		CHAR(16);
    DEFINE vNotificacion		CHAR(1);
	DEFINE vTarjeta  			CHAR(16);
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE vStatus	 			CHAR(3);
	DEFINE vBin					CHAR(6);
	DEFINE vCreditodebito		CHAR(1);
	
	LET vNumcte = pNumcte;
	LET vDigtarjeta = pDigtarjeta;
	LET vCanal =pCanal;
	LET vFolio = pFolio;
	LET vNotificacion = pNotificacion;
	LET vTarjeta = '0000000000000000';
	LET vCodigoRetorno = '00000';
	LET vStatus = 'ACT';
	LET vBin = '0000';
	LET vCreditodebito = 'A';

--SET DEBUG FILE TO  "/resplogifx/cancelaTarjeta.out";
--TRACE ON;

 BEGIN
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
	SELECT numtarjeta
	INTO vTarjeta
	FROM intercard:tarjeta 
	WHERE numcliente = vNumcte and numtarjeta LIKE '%'|| vDigtarjeta;
  
	LET vBin = SUBSTR (vTarjeta, 1, 6);
	
	SELECT codstatustarjeta
	INTO vStatus
	FROM intercard:tarjeta
	WHERE numcliente = vNumcte and numtarjeta LIKE '%'|| vDigtarjeta;
	
	IF (vTarjeta IS NOT NULL )THEN 
		
		IF (vStatus != 'CAN') THEN
			UPDATE intercard:"informix".tarjeta SET codstatustarjeta ='CAN' where numtarjeta = vTarjeta;
						
			LET vCodigoRetorno = '00000';
			LET vMensaje = "Tarjeta cancelada exitosamente";
			
			
			SELECT creditodebito
			INTO vCreditodebito
			FROM intercard:bines
			WHERE bin = vBin;
			
			IF(vCreditodebito = 'D') THEN 
				UPDATE bdicheq:"informix".sc_tarjeta SET status_tar = 'C' WHERE num_tarjeta = vTarjeta;
			ELIF ( vCreditodebito = 'C' ) THEN
				UPDATE bdicred:"informix".sd_tarjeta SET status_tar = 'C' WHERE num_tarjeta = vTarjeta; 
			END IF
			
			EXECUTE PROCEDURE intercard:"informix".sp_regbitacoracancelcanal( vNumcte, vTarjeta,  vCanal, vFolio,  CURRENT);

			
			RETURN vCodigoRetorno, vMensaje;
			
		ELSE
		
			LET vCodigoRetorno = '00002';
			LET vMensaje = "La tarjeta ya ha sido cancelada previamente";
			RETURN vCodigoRetorno, vMensaje;
		
		END IF
  
	ELSE 
	
		LET vCodigoRetorno = '00001';
		LET vMensaje = "La tarjeta no existe";
		RETURN vCodigoRetorno, vMensaje;
	
	END IF
  END
END PROCEDURE;