CREATE PROCEDURE "informix".sp_con_susc_ctes(pTipo CHAR(1), pNumCte CHAR(20), pNumCta CHAR(20), pNumTarjeta CHAR(16))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(40)	AS cMensaje,
		  CHAR(20)  AS numcte,
		  CHAR(107) AS nombre,
		  CHAR(2)   AS cCod1,
		  CHAR(2)   AS cCod2,
		  CHAR(2)   AS cCod3,
		  CHAR(2)   AS cCod4,
		  CHAR(2)   AS cCod5,
		  CHAR(2)   AS cCod6,
		  CHAR(2)   AS cCod7,
		  CHAR(2)   AS cCod8;	  
		  		  
DEFINE cCodRet      VARCHAR (5);
DEFINE cMensaje		VARCHAR(40);
DEFINE vCod1		VARCHAR (2);
DEFINE vCod2		VARCHAR (2);
DEFINE vCod3		VARCHAR (2);
DEFINE vCod4		VARCHAR (2);
DEFINE vCod5		VARCHAR (2);
DEFINE vCod6		VARCHAR (2);
DEFINE vCod7		VARCHAR (2);
DEFINE vCod8		VARCHAR (2);
DEFINE vCod			VARCHAR (3);
DEFINE vNumCte		CHAR(20);  
DEFINE vNombre1		VARCHAR(26);
DEFINE vNombre2		VARCHAR(26);
DEFINE vApellPat	VARCHAR(26);
DEFINE vApellMat	VARCHAR(26);
DEFINE vNombre		VARCHAR(107);
DEFINE iSqlErr		INTEGER;
DEFINE vCodAct		CHAR(3);

/*FIN DE DEFINICION DE VARIABLES*/

LET cCodRet = '00000';
LET cMensaje = 'Proceso Exitoso';
LET vCod1 = '-1';
LET vCod2 = '-1';
LET vCod3 = '-1';		  
LET vCod4 = '-1';		  
LET vCod5 = '-1';
LET vCod6 = '-1';
LET vCod7 = '-1';
LET vCod8 = '-1';
LET vCod = '';
LET vCodAct = '';
LET vNumCte = '';
LET vNombre1 = '';	
LET vNombre2 = '';
LET vApellPat = '';
LET vApellMat = '';
LET vNombre = '';
LET iSqlErr    = 0;

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/douglas/cancelacionsms/sp_con_susc_ctes.out";
--TRACE ON;		  
		  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			
			RETURN cCodRet,cMensaje,vNumCte,vNombre,vCod1,vCod2,vCod3,vCod4,vCod5,vCod6,vCod7,vCod8;
			
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
	IF NVL(pTipo,'') = '' OR  (NVL(pNumCte,'') = '' AND NVL(pNumCta,'') = '' AND NVL(pNumTarjeta,'') = '' 
		AND NVL(pNumCte,'') = '') THEN 
	
		LET cCodRet = '00001';    -- Error De Parametros De Entrada
		
		RETURN cCodRet,cMensaje,vNumCte,vNombre,vCod1,vCod2,vCod3,vCod4,vCod5,vCod6,vCod7,vCod8;
		
	END IF;
	
	IF pTipo = '1' THEN
		LET vNumCte = LPAD(TRIM(pNumCte),9,'0');
	ELIF pTipo = '2' THEN
		SELECT FIRST 1 num_cte 
		INTO vNumCte
		FROM bdicheq:"informix".sc_maechq 
		WHERE cuenta = pNumCta;
		
		IF NVL(vNumCte,'') = '' THEN
			SELECT FIRST 1 numcte 
			INTO vNumCte
			FROM bdicred:"informix".sd_maecred
			WHERE num_credito = pNumCta;
		END IF;
		
	ELIF pTipo = '3' THEN
		SELECT FIRST 1 numcte 
		INTO vNumCte
		FROM bdicheq:"informix".sc_tarjeta
		WHERE num_tarjeta = pNumTarjeta;
		
		IF NVL(vNumCte,'') = '' THEN
			SELECT FIRST 1 numcte 
			INTO vNumCte
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_tarjeta = pNumTarjeta;
		END IF;
	ELSE
		LET cCodRet = '00002';   --Opcion No Valida
		RETURN cCodRet,cMensaje,vNumCte,vNombre,vCod1,vCod2,vCod3,vCod4,vCod5,vCod6,vCod7,vCod8;
	END IF;
	SELECT numcte,nombre1,nombre2,apell_paterno,apell_materno 
	INTO vNumCte,vNombre1,vNombre2,vApellPat,vApellMat
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = vNumCte;
	
	IF NVL(vNumCte,'') = '' THEN
		LET cCodRet = '00003';    -- No Se Encontro Numero De Cliente
	ELSE 
		LET vNombre = TRIM(TRIM(vNombre1)||' '||TRIM(vNombre2))||' '||TRIM(TRIM(vApellPat)||' '||TRIM(vApellMat));
		-- Buscar cancelacion de suscripcion 
		-- Aqui va la magia
		
		FOREACH 
			SELECT distinct(codigo)
			INTO vCodAct
			FROM bdimnsj:"informix".mnsjr_cat_suscripcion
			
				-- ASIGNA PARAMETROS
			IF 	 vCodAct = '001'  THEN LET vCod1 = '0';
			ELIF vCodAct = '002'  THEN LET vCod2 = '0';
			ELIF vCodAct = '003'  THEN LET vCod3 = '0';
			ELIF vCodAct = '004'  THEN LET vCod4 = '0';
			ELIF vCodAct = '005'  THEN LET vCod5 = '0';
			ELIF vCodAct = '006'  THEN LET vCod6 = '0';
			ELIF vCodAct = '007'  THEN LET vCod7 = '0';
			ELIF vCodAct = '008'  THEN LET vCod8 = '0';
			END IF;
			
		END FOREACH
		
		FOREACH 
			SELECT codigo 
			INTO vCod
			FROM bdimnsj:"informix".mnsjr_suscripcion_ctes
			WHERE numcte = vNumCte
			
				-- ASIGNA PARAMETROS
			IF 	 vCod = '001'  THEN LET vCod1 = '1';
			ELIF vCod = '002'  THEN LET vCod2 = '1';
			ELIF vCod = '003'  THEN LET vCod3 = '1';
			ELIF vCod = '004'  THEN LET vCod4 = '1';
			ELIF vCod = '005'  THEN LET vCod5 = '1';
			ELIF vCod = '006'  THEN LET vCod6 = '1';
			ELIF vCod = '007'  THEN LET vCod7 = '1';
			ELIF vCod = '008'  THEN LET vCod8 = '1';
			END IF;
			
		END FOREACH

		
	END IF;
	RETURN cCodRet,cMensaje,vNumCte,vNombre,vCod1,vCod2,vCod3,vCod4,vCod5,vCod6,vCod7,vCod8;
	END;		  
END PROCEDURE;