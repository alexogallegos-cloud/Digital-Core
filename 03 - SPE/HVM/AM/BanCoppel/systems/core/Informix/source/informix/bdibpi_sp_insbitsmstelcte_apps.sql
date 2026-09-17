CREATE PROCEDURE "informix".sp_insbitsmstelcte_apps(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5),pdigito_ver CHAR(6), ptelefono CHAR(10), pEmail  CHAR(100), pteclea_ejecut CHAR(100), pbandera boolean)
-- Se clona el sp "sp_insbitsmstelcte" para que cuando el diÃÂ­gito verificador sea 6, se utilice la tabla si_bitsmstelsms_bpi.
-- BD    : bdinteg

RETURNING char(5) as codret ;
DEFINE iSqlErr			INTEGER;
DEFINE iNumRnd          INTEGER;
DEFINE dNumRnd2         DECIMAL(10,0);
DEFINE cCodigo          CHAR(6);
DEFINE cCodSp1           CHAR(5);
DEFINE cCodSp           CHAR(5);

LET iNumRnd     =   0;
LET dNumRnd2    =   0;
LET cCodigo     =   '';
LET cCodSp1      =   '00000';
LET cCodSp      =   '00000';


	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

	--SET DEBUG FILE TO "/informix/Aida/sp_insbitsmstelcte_apps1.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 4;

	IF (LENGTH(TRIM(pdigito_ver)) = 4) THEN
		IF popcion='1' THEN		
		--*****OPCION 1 DE INSERCION*****--
			   IF NOT EXISTS(SELECT * FROM bdinteg: "informix".si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current)) THEN

				   INSERT INTO bdinteg: "informix".si_bitsmstelsms(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			   END IF;

  			    IF (psucursal = '5007') THEN --MENSJA SMS PARA LAS APPS
			   
					--Envia SMS
					CALL bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL',pnumcte, 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					RETURNING cCodSp1;  				
					
					--Envia email
					IF (cCodSp1 = '00000') THEN 
						CALL bdimnsj:"informix".sp_registra_evento(1,'BPI_CLVCEL',pnumcte,'','', '1',pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail, '', 1, 0, 0, 0, 0,current,current)
						RETURNING cCodSp;   
						ELSE
						LET cCodSp      = "00002";
					END IF
					
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;					   
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				IF EXISTS (SELECT * FROM bdinteg: "informix".si_bitsmstelsms WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL) THEN 
					UPDATE bdinteg: "informix".si_bitsmstelsms SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp;
				END IF;

		END IF;  
	ELSE -- ENTONCES ES DE 6
		IF popcion='1' THEN		
		--*****OPCION 1 DE INSERCION*****--
			   IF NOT EXISTS(SELECT * FROM bdinteg: "informix".si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current)) THEN

				   INSERT INTO bdinteg: "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			   END IF;
			
			   IF (psucursal = '5007') THEN  --MENSJA SMS PARA LAS APPS		
			   
					--Envia SMS
					CALL bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL',pnumcte, 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					RETURNING cCodSp1;  				
					
					--Envia email
					IF (cCodSp1 = '00000') THEN 
						CALL bdimnsj:"informix".sp_registra_evento(1,'BPI_CLVCEL',pnumcte,'','', '1',pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail, '', 1, 0, 0, 0, 0,current,current)
						RETURNING cCodSp;   
						ELSE
						LET cCodSp      = "00002";
					END IF
					
				ELSE
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				IF EXISTS (SELECT * FROM bdinteg: "informix".si_bitsmstelsms_bpi WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL) THEN 
					UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp;
				END IF;

		END IF;  
	END IF;

RETURN cCodSp;
END
END PROCEDURE;