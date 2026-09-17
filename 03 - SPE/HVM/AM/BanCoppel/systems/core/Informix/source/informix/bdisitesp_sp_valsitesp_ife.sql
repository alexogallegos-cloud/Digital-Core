CREATE PROCEDURE "informix".sp_valsitesp_ife(pNumCte CHAR(9))
	RETURNING 	CHAR(5) 	 AS cCodRet, 
				CHAR(5) 	 AS cSitEsp;
				
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cSitEsp 		CHAR(5);


--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET cCodRet 	 = "00000";
LET cSitEsp 	 = "00000";


--SET DEBUG FILE TO '/tmp/sp_valtel_ctedupout.SQL';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cSitEsp;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    -- SE VERIFICA QUE EL CLIENTE TENGA LA CAUSA 109
    
    IF EXISTS (SELECT * FROM se_ctessitespcte WHERE numcte=pNumCte and causa in ('60', '3', '59', '42', '43', '29', '108')) THEN
	 
	   IF EXISTS (SELECT * FROM se_ctessitespcte WHERE numcte=pNumCte and situacion = 'C' and causa = '3') THEN
	     LET cSitEsp  = '00000';
	   ELSE
	     LET cSitEsp='109';
	   END IF
       
    ELIF EXISTS (SELECT * FROM se_ctessitespcte WHERE numcte=pNumCte and causa in ('62')) THEN
       LET cSitEsp='62';
    END IF;

    IF EXISTS (SELECT * FROM bdinteg:si_cte_huella where numcte=pNumCte AND estado='A') THEN
        insert into bdinteg:si_bit_altatime(numcte, fecha, hora) values(pNumCte, current, current);
    END IF;

RETURN cCodRet,cSitEsp; -- SE RETORNA EL CODIGO Y EL PORCENTAJE DE COINCIDENCIA FINAL DE LOS TRES TELEFONOS
END;
END PROCEDURE;