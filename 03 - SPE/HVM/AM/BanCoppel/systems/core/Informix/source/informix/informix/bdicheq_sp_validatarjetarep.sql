CREATE PROCEDURE "informix".sp_validatarjetarep (pcTipoTarjeta CHAR (1),
												pcNumTarjetaNueva CHAR(16),
												pcNumCliente CHAR(13))

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE tar_tarjeta CHAR(16);
DEFINE tcta_tarjeta CHAR(16);
DEFINE deb_tarjera CHAR(16);
DEFINE cre_tarjera CHAR(16);

--Asignacion de Variables.
LET cCodRet = "";
LET iSqlErr = 0;
LET tar_tarjeta = "";
LET tcta_tarjeta = "";
LET deb_tarjera = "";
LET cre_tarjera = "";

--SET DEBUG FILE TO "/tmp/sp_validatarjetarep.out";	
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

 													
			IF pcTipoTarjeta = '1' THEN		-- dÃ©bito
				SELECT  tar.numtarjeta,  tarcta.numtarjeta, deb.num_tarjeta
				INTO tar_tarjeta, tcta_tarjeta, deb_tarjera
				FROM intercard:"informix".tarjeta tar 
				LEFT JOIN intercard:"informix".tarjetacuenta tarcta ON (tar.numtarjeta = tarcta.numtarjeta )
				LEFT JOIN bdicheq:"informix".sc_tarjeta deb ON ( tar.numtarjeta = deb.num_tarjeta) 
				WHERE tar.numtarjeta = pcNumTarjetaNueva AND codstatusasignada='SIA' AND codstatustarjeta = 'ACT' AND tar.numcliente = pcNumCliente;
						  
				If (tar_tarjeta is null or tar_tarjeta = "") or (tcta_tarjeta is null or tcta_tarjeta = "") then   
					LET cCodRet = "00001";  
				ELSE
					LET cCodRet = "00000";   
				END IF;
				
			ELIF pcTipoTarjeta = '2' THEN		-- crÃ©dito
				SELECT tar.numtarjeta, tarcta.numtarjeta,cre.num_tarjeta
				INTO tar_tarjeta, tcta_tarjeta, cre_tarjera
				FROM intercard:"informix".tarjeta tar 
				LEFT JOIN intercard:"informix".tarjetacuenta tarcta ON (tar.numtarjeta = tarcta.numtarjeta )		
				LEFT JOIN bdicred:"informix".sd_tarjeta cre ON ( tar.numtarjeta = cre.num_tarjeta) 
				WHERE tar.numtarjeta = pcNumTarjetaNueva AND codstatusasignada='SIA' AND codstatustarjeta = 'INA'AND tar.numcliente = pcNumCliente;

				If (tar_tarjeta is null or tar_tarjeta = "") or (tcta_tarjeta is null or tcta_tarjeta = "") then    
					LET cCodRet = "00001";   					
				ELSE
					LET cCodRet = "00000";
				END IF;
				
			END IF;

RETURN cCodRet;
END
END PROCEDURE
;