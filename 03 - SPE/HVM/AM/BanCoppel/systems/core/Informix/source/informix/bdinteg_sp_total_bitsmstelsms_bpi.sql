CREATE PROCEDURE "informix".sp_total_bitsmstelsms_bpi(pNumCliente CHAR(9))
   returning CHAR(5);
   
	-- Se clona stored procedure sp_total_bitsmstelsms para contabilizar las oportunidades de solicitud de clave nueva por sms pero en la tabla si_bitsmstelsms_bpi
	-- AUTOR : Keevyn Adrian Gil Valenzuela
	-- FECHA : 20/12/2016
	-- BD    : bdinteg

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iContador INTEGER;
	
	LET cCodRet='00000';
	
  --SET DEBUG FILE TO "/tmp/sp_total_bitsmstelsms_bpi.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte) 
	INTO iContador 
	FROM bdinteg:"informix".si_bitsmstelsms_bpi 
	WHERE numcte =pNumCliente AND DATE(fecha)=DATE(CURRENT);
	IF iContador>=10 THEN
		LET cCodRet='00001';
	ELSE
		LET cCodRet='00000';
	END IF;

	RETURN cCodRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1616?BPI-ValidaNumeroCelular',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30-11-2015',
'MODIFICACIÓN..: Se crea stored procedure para contabilizar las oportunidades de solicitud de clave nueva por sms',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG',
'FOLIO.........: 1631-BPILogin',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 12-02-2016',
'MODIFICACIÓN..: Se verifica si es id de usuario o numero de cliente',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_claveasocia_cta_cel(pNumCel CHAR(10))
											  
-- Genera una clave de confirmación para validar el número de celular que se desea asociar a una cuenta.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 16/11/2016
-- BD    : bdinteg

RETURNING
    CHAR(6);        -- CodigoRetorno
	

	-- Declarar variables 
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSql_err 	INTEGER;
	
	DEFINE cUno			CHAR(2);
	DEFINE cDos			CHAR(2);
	DEFINE cTres		CHAR(2);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_claveasocia_cta_cel.out";
	--TRACE ON;
	
	LET dHora = current hour to fraction;
	LET cUno = SUBSTR(pNumCel,3,2);
	LET cDos = SUBSTR(pNumCel,7,2);
	LET cTres = SUBSTR(dHora, 7,2);
	LET cCodRet = cUno || cDos || cTres;
	
		
	RETURN cCodRet;
	
END 
END PROCEDURE;