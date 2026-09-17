CREATE PROCEDURE "informix".sp_insbitsmstelcte_bpi2(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5),pdigito_ver CHAR(6), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
-- Se clona el sp "sp_insbitsmstelcte" para que cuando el diÃÂÃÂÃÂÃÂ­gito verificador sea 6, se utilice la tabla si_bitsmstelsms_bpi.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 01/12/2016
-- BD    : bdinteg

RETURNING char(5) , SMALLINT ;

DEFINE iSqlErr			INTEGER;
DEFINE iNumRnd          INTEGER;
DEFINE iExist           INTEGER;
DEFINE vcorreo          CHAR(100);
DEFINE vtipocorreo      CHAR(1);
DEFINE vstatuscorreo    CHAR(1); 
DEFINE dNumRnd2         DECIMAL(10,0);
DEFINE cCodigo          CHAR(6);
DEFINE cCodSp           CHAR(5); 
DEFINE cCodSp1          CHAR(3);

DEFINE cFecAct          INTERVAL MINUTE(9) to MINUTE;
DEFINE cContAct         SMALLINT;
DEFINE cLenDig         SMALLINT;
DEFINE cLim             INTERVAL MINUTE(9) to MINUTE;
DEFINE cTim             INTERVAL MINUTE(9) to MINUTE;
LET cCodSp1     =   '';
LET iNumRnd     =   0;
LET iExist	    =   0;
LET dNumRnd2    =   0;
LET cCodigo     =   '';
LET cCodSp      =   '00000'; 

LET vcorreo       = '';
LET vtipocorreo   = '';
LET vstatuscorreo = '';
LET cFecAct        =   '70';
LET cLim        =   '60';
LET cTim        =   '0';
LET cContAct    =   0;
LET cLenDig 	= 	0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,cContAct;
			END IF;
		END EXCEPTION;

	--SET DEBUG FILE TO "/informix/gaby/bdinteg_msjtel/sp_insbitsmstelcte_bpi.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	LET pdigito_ver = TRIM(pdigito_ver);
	
	LET cLenDig = LENGTH(pdigito_ver);
	
	IF (cLenDig = 4) THEN
		IF popcion='1' THEN		
		--*****OPCION 1 DE INSERCION*****--
				SELECT count(*) INTO iExist FROM "informix".si_bitsmstelsms WHERE numcte=pnumcte and telefono=ptelefono and EXTEND(fecha, YEAR TO MINUTE)=EXTEND(current, YEAR TO MINUTE);
				
			   IF (iExist = 0) THEN

				   INSERT INTO "informix".si_bitsmstelsms(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			   ELSE

				FOREACH
					SELECT LIMIT 1 digito_ver INTO pdigito_ver 
					FROM "informix".si_bitsmstelsms 
					WHERE numcte=pnumcte and telefono=ptelefono
					ORDER BY fecha DESC
					
				END FOREACH;	
				 
					
			   END IF;
			   
					
			   

  			    IF (psucursal = '5007') THEN --MENSJA SMS PARA LAS APPS
			   
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL',  pnumcte, 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;					   
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'BPI_CLVCEL', pnumcte, 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
					   
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				
				SELECT count(*) INTO iExist FROM "informix".si_bitsmstelsms WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
				IF  (iExist > 0) THEN 
					UPDATE "informix".si_bitsmstelsms SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) 
						AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp,cContAct;
				END IF;

		END IF;  
	ELSE -- ENTONCES ES DE 6
		IF popcion='1' THEN		

                   SELECT COUNT(numcte)  ,(CURRENT HOUR TO MINUTE - EXTEND(MAX(fecha),HOUR TO MINUTE) )::INTERVAL MINUTE(9) to MINUTE
                   INTO cContAct ,cFecAct
                   FROM "informix".si_bitsmstelsms_bpi 
                   WHERE EXTEND(fecha,YEAR TO DAY) = CURRENT YEAR TO DAY AND numcte = pnumcte 
                   GROUP BY numcte;

                   IF(cContAct >= 25) THEN
                        IF(cFecAct <= cLim) THEN
                            LET cCodSp  =  '00002';
                            RETURN cCodSp,cContAct;
                        END IF;
                   END IF;
				   
				 IF(cFecAct <=cTim) THEN
					LET cCodSp  =  '00003';
						RETURN cCodSp,cContAct;
				 END IF;

		--*****OPCION 1 DE INSERCION*****--
					SELECT count(*) INTO iExist FROM "informix".si_bitsmstelsms_bpi 
					WHERE numcte=pnumcte and telefono=ptelefono --and EXTEND(fecha, YEAR TO MINUTE)=EXTEND(current, YEAR TO MINUTE);
					AND fecha::date = TODAY 
					AND bandera='f';
					
			   IF ( iExist = 0) THEN
					
				   IF (cLenDig < 6) THEN
						LET pdigito_ver = '1' ||pdigito_ver;	
				   END IF;
				   
				   INSERT INTO "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			    ELSE
					FOREACH
					SELECT LIMIT 1 digito_ver INTO pdigito_ver 
					FROM "informix".si_bitsmstelsms_bpi 
					WHERE numcte=pnumcte and telefono=ptelefono
					AND fecha::date = TODAY
					AND bandera='f'
					ORDER BY fecha DESC
					
					END FOREACH; 	
				 					 	
			   END IF;
			
			  EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos( '001',pnumcte,1,0)
			   INTO cCodSp1,vcorreo,vtipocorreo,vstatuscorreo;

			   IF (psucursal = '5007') THEN  --MENSJA SMS PARA LAS APPS		
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)					
					   INTO cCodSp;
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL', '000000000','XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current) --//Actualza cliente
					   INTO cCodSp;
					
					IF(cCodSp1  = '000' AND vstatuscorreo = 'A') THEN								
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'BPI_CLVCEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', vcorreo, ptelefono, 1, 0, 0, 0, 0,current,current)
						INTO cCodSp;
					ELSE  
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'BPI_CLVCEL', pnumcte, 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)					
					   INTO cCodSp;
					END IF; 
					   
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				SELECT count(*) INTO iExist FROM "informix".si_bitsmstelsms_bpi WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
				
				IF (iExist > 0) THEN 
					UPDATE "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp,cContAct;
				END IF;

		END IF;  
	END IF;

RETURN cCodSp,cContAct;
END
END PROCEDURE;