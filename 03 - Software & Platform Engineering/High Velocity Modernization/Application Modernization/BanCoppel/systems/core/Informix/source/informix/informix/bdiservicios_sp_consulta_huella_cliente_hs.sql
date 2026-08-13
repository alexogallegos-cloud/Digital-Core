CREATE PROCEDURE "informix".sp_consulta_huella_cliente_hs(numcte CHAR(9))
RETURNING CHAR(5) AS  cCodRet,
		CHAR(942) AS  cTemplate1,
		CHAR(942) AS  cTemplate2,
		CHAR(942) AS  cTemplate3,
		CHAR(942) AS  cTemplate4,
		CHAR(942) AS  cTemplate5,
		CHAR(942) AS  cTemplate6,
		CHAR(942) AS  cTemplate7,
		CHAR(942) AS  cTemplate8,
		CHAR(942) AS  cTemplate9,
		CHAR(942) AS  cTemplate10,
		SMALLINT AS sNfiq1,
		SMALLINT AS sNfiq2, 
		SMALLINT AS sNfiq3, 
		SMALLINT AS sNfiq4, 
		SMALLINT AS sNfiq5, 
		SMALLINT AS sNfiq6, 
		SMALLINT AS sNfiq7, 
		SMALLINT AS sNfiq8, 
		SMALLINT AS sNfiq9, 
		SMALLINT AS sNfiq10,
		SMALLINT AS sMinucias1,
        SMALLINT AS sMinucias2,
        SMALLINT AS sMinucias3,
        SMALLINT AS sMinucias4,
        SMALLINT AS sMinucias5,
        SMALLINT AS sMinucias6,
        SMALLINT AS sMinucias7,
		SMALLINT AS sMinucias8,
		SMALLINT AS sMinucias9,
		SMALLINT AS sMinucias10,
		SMALLINT AS sSecuencia;


		 DEFINE cCodRet 	CHAR(5);
		 DEFINE cTemplate1  CHAR(942);
		 DEFINE cTemplate2  CHAR(942);
		 DEFINE cTemplate3  CHAR(942);
		 DEFINE cTemplate4  CHAR(942);
		 DEFINE cTemplate5  CHAR(942);
		 DEFINE cTemplate6  CHAR(942);
		 DEFINE cTemplate7  CHAR(942);
		 DEFINE cTemplate8  CHAR(942);
		 DEFINE cTemplate9  CHAR(942);
         DEFINE cTemplate10 CHAR(942);
		 DEFINE iSqlErr INTEGER;
		 DEFINE i INTEGER;
		 DEFINE cId_template SMALLINT;
		 DEFINE cTemplate CHAR(942);
		 DEFINE sNfiq SMALLINT;
		 DEFINE sMinucias SMALLINT;
		 
		 DEFINE sNfiq1  SMALLINT;
		 DEFINE sNfiq2  SMALLINT;
		 DEFINE sNfiq3  SMALLINT;
		 DEFINE sNfiq4  SMALLINT;
		 DEFINE sNfiq5  SMALLINT;
		 DEFINE sNfiq6  SMALLINT;
		 DEFINE sNfiq7  SMALLINT;
		 DEFINE sNfiq8  SMALLINT;
		 DEFINE sNfiq9  SMALLINT;
		 DEFINE sNfiq10 SMALLINT;
		 
		 DEFINE sMinucias1 SMALLINT;
		 DEFINE sMinucias2 SMALLINT;
		 DEFINE sMinucias3 SMALLINT;
		 DEFINE sMinucias4 SMALLINT;
		 DEFINE sMinucias5 SMALLINT;
		 DEFINE sMinucias6 SMALLINT;
		 DEFINE sMinucias7 SMALLINT;
		 DEFINE sMinucias8 SMALLINT;
		 DEFINE sMinucias9 SMALLINT;
		 DEFINE sMinucias10 SMALLINT;
		 
		 DEFINE sSecuencia SMALLINT;	 
		 
		 LET cCodRet = '00000';
		 LET cTemplate1  = '';
		 LET cTemplate2  = '';
		 LET cTemplate3  = '';
		 LET cTemplate4  = '';
		 LET cTemplate5  = '';
		 LET cTemplate6  = '';
		 LET cTemplate7  = '';
		 LET cTemplate8  = '';
		 LET cTemplate9  = '';
         LET cTemplate10 = '';
		 LET iSqlErr=0;
		 LET i = 0;
		 LET cId_template = 0;
		 LET cTemplate = '';
		 LET sNfiq = 0;
		 
		 LET sNfiq1  = 0;
		 LET sNfiq2  = 0;
		 LET sNfiq3  = 0;
		 LET sNfiq4  = 0;
		 LET sNfiq5  = 0;
		 LET sNfiq6  = 0;
		 LET sNfiq7  = 0;
		 LET sNfiq8  = 0;
		 LET sNfiq9  = 0;
		 LET sNfiq10 = 0;
		 
		 LET sMinucias1 = 0; 
		 LET sMinucias2 = 0; 
		 LET sMinucias3 = 0; 
		 LET sMinucias4 = 0; 
		 LET sMinucias5 = 0; 
		 LET sMinucias6 = 0; 
		 LET sMinucias7 = 0; 
		 LET sMinucias8 = 0; 
		 LET sMinucias9 = 0; 
		 LET sMinucias10 = 0;
		 
		 LET sSecuencia = 0;


BEGIN

	ON EXCEPTION SET iSqlerr 
		
		IF iSqlErr !=0 THEN
			RETURN TRIM (isqlerr),cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		END IF
		
	END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	IF numcte= "" OR numcte IS NULL THEN 
		RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
	ELSE 		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_huella_actual(numcte)
		INTO cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;

		RETURN  cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		
	END IF;	

END
END PROCEDURE
