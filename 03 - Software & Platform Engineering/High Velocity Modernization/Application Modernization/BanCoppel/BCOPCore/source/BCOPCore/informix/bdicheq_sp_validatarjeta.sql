CREATE PROCEDURE "informix".sp_validatarjeta(pcTipoTarjeta CHAR (1),
												pcNumTarjetaNueva CHAR(16),
												piOpcion INTEGER)

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

--Asignacion de Variables.
LET cCodRet = "";
LET iSqlErr = 0;

--SET DEBUG FILE TO "/tmp/sp_validatarjeta.out";	
--TRACE ON;													

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;								
	SET LOCK MODE TO WAIT 3;									

	IF piOpcion = 1 THEN	--Valida asignaciÃ³n Intercard		
		IF EXISTS(SELECT tar.numtarjeta FROM intercard:"informix".tarjeta tar
				  INNER JOIN intercard:"informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta	
				  WHERE tar.numtarjeta = pcNumTarjetaNueva AND fechaasignacion IS NOT NULL AND codstatusasignada = 'SIA') THEN
			LET cCodRet = "00000";	--Asignada en intercard		
		ELSE
			LET cCodRet = "00001";	--No asignada en intercard
		END IF;
	END IF;
 													
	IF piOpcion = 2 THEN	--Valida reposiciÃ³n en bdicheq o bdicred		
		IF pcTipoTarjeta = '1' THEN		-- dÃ©bito
			IF EXISTS(SELECT tardeb.num_tarjeta FROM bdicheq:"informix".sc_tarjeta tardeb
					  INNER JOIN intercard:"informix".tarjeta tar ON tardeb.num_tarjeta = tar.numtarjeta
					  INNER JOIN intercard:"informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					      WHERE empresa = '001' AND tardeb.num_tarjeta = pcNumTarjetaNueva AND status_tar='A' AND codstatustarjeta = 'ACT') THEN

				LET cCodRet = "00000";   --reposiciÃ³n ok
			ELSE
				LET cCodRet = "00001";   --no rep en bdicheq
			END IF;
		
		ELIF pcTipoTarjeta = '2' THEN		-- crÃ©dito
			IF EXISTS(SELECT tarcred.num_tarjeta FROM bdicred:"informix".sd_tarjeta tarcred
					  INNER JOIN intercard:"informix".tarjeta tar ON tarcred.num_tarjeta = tar.numtarjeta
					  INNER JOIN intercard:"informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					  WHERE empresa = '001' AND tarcred.num_tarjeta = pcNumTarjetaNueva AND status_tar = 'I' AND codstatustarjeta = 'INA') THEN

				LET cCodRet = "00000";   --reposiciÃ³n ok					
			ELSE
				LET cCodRet = "00001";	--no rep en bdicred
			END IF;
		END IF;
	END IF;	
		
	IF piOpcion = 3 THEN	--Valida asignaciÃ³n 	
		IF pcTipoTarjeta = '1' THEN		-- dÃ©bito
			IF EXISTS(SELECT tardeb.num_tarjeta FROM bdicheq:"informix".sc_tarjeta tardeb
					  INNER JOIN intercard:"informix".tarjeta tar ON tardeb.num_tarjeta = tar.numtarjeta
					  INNER JOIN intercard:"informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					  WHERE empresa = '001' AND tardeb.num_tarjeta = pcNumTarjetaNueva AND status_tar='A') THEN
				LET cCodRet = "00000";   --asignaciÃ³n ok
			ELSE
				LET cCodRet = "00001";   --no asignada en bdicheq
			END IF;
		END IF;
	END IF;	
	
	IF piOpcion = 4 THEN	--Valida activaciÃ³n intercard
		IF pcTipoTarjeta = '1' THEN		-- dÃ©bito
			IF EXISTS(SELECT tardeb.num_tarjeta FROM bdicheq:"informix".sc_tarjeta tardeb
					  INNER JOIN intercard:"informix".tarjeta tar ON tardeb.num_tarjeta = tar.numtarjeta
					  INNER JOIN intercard:"informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					  WHERE empresa = '001' AND tardeb.num_tarjeta = pcNumTarjetaNueva AND codstatustarjeta='ACT') THEN
				LET cCodRet = "00000";   --activaciÃ³n ok
			ELSE
				LET cCodRet = "00001";   --no activaciÃ³n en intercard
			END IF;
		END IF;
	END IF;	

RETURN cCodRet;
END
END PROCEDURE
;