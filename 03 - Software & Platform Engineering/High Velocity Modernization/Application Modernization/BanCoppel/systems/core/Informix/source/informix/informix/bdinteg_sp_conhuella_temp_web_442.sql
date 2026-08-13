CREATE PROCEDURE "informix".sp_conhuella_temp_web_442( cEmpresa CHAR(3),
                                         cSucursal CHAR(4),
                                         cUser_Insert CHAR(8),
                                         cNumCte CHAR(20))
	RETURNING CHAR(5);

	DEFINE cCodRet    CHAR(5);
	DEFINE cExiste    CHAR(1);
	DEFINE cSqlErr    INTEGER;
	DEFINE cIsamErr   INTEGER;
	DEFINE cDHActual  CHAR(955);
	DEFINE cDH1  	  CHAR(955);
	DEFINE cDH2  	  CHAR(955);
	DEFINE cDH3  	  CHAR(955);
	DEFINE cDH4  	  CHAR(955);
	DEFINE cDH5  	  CHAR(955);
	DEFINE cDH6  	  CHAR(955);
	DEFINE cDH7  	  CHAR(955);
	DEFINE cDH8  	  CHAR(955);
	DEFINE cDH9  	  CHAR(955);
	DEFINE cDH10      CHAR(955);
	DEFINE cContador  INTEGER;
	DEFINE iSecuencia SMALLINT;

	LET cCodRet = "00000";
	LET cExiste = 0;
	LET cDHActual = "";
	LET cDH1 = "";
	LET cDH2 = "";
	LET cDH3 = "";
	LET cDH4 = "";
	LET cDH5 = "";
	LET cDH6 = "";
	LET cDH7 = "";
	LET cDH8 = "";
	LET cDH9 = "";
	LET cDH10 = "";
	LET cContador = 1;
	LET iSecuencia = 0;

	BEGIN
		ON EXCEPTION SET cSqlErr,cIsamErr
		IF cSqlErr != 0 THEN
			LET cCodRet=cSqlErr;
			RETURN cCodRet;
		END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--- Verifica recepcion correcta de datos
		IF NVL(cNumCte, '') = '' THEN 
			LET cCodRet = "00110";
			RETURN cCodRet;
		END IF;

		SELECT 1 INTO cExiste
		FROM si_ejecut
		WHERE ejecutivo=cUser_Insert;
		IF cExiste IS NULL THEN
			LET cCodRet="00112";
			RETURN cCodRet;
		END IF;

		SELECT MAX(secuencia) INTO iSecuencia FROM si_cte_huella_dec_temp WHERE numcte = cNumCte;
	   
		FOREACH
			SELECT template 
			INTO cDHActual
			FROM bdinteg:si_cte_huella_dec_temp
			WHERE  numcte = cNumCte
			AND status ="M" AND secuencia = iSecuencia
			ORDER BY id_template ASC
			
			IF (cContador = 1) THEN 
				LET cDH1 = cDHActual;
			END IF;
			
			IF (cContador = 2) THEN 
				LET cDH2 = cDHActual;
			END IF;
			
			IF (cContador = 3) THEN 
				LET cDH3 = cDHActual;
			END IF;
			
			IF (cContador = 4) THEN 
				LET cDH4 = cDHActual;
			END IF;
			
			IF (cContador = 5) THEN 
				LET cDH5 = cDHActual;
			END IF;
			
			IF (cContador = 6) THEN 
				LET cDH6 = cDHActual;
			END IF;
			
			IF (cContador = 7) THEN 
				LET cDH7 = cDHActual;
			END IF;
			
			IF (cContador = 8) THEN 
				LET cDH8 = cDHActual;
			END IF;
			
			IF (cContador = 9) THEN 
				LET cDH9 = cDHActual;
			END IF;
			
			IF (cContador = 10) THEN 
				LET cDH10 = cDHActual;
			END IF;
			
			LET cContador = cContador + 1;
		END FOREACH;
	   
		IF NVL(cDH1, '') = '' or NVL(cDH2, '') = '' or NVL(cDH3, '') = '' or NVL(cDH4, '') = '' or NVL(cDH5, '') = '' or
			NVL(cDH6, '') = '' or NVL(cDH7, '') = '' or NVL(cDH8, '') = '' or NVL(cDH9, '') = '' or NVL(cDH10, '') = '' THEN
			let cCodRet = "00132";
			RETURN cCodRet;
		END IF;
		RETURN cCodRet;
		
	END;
END PROCEDURE;