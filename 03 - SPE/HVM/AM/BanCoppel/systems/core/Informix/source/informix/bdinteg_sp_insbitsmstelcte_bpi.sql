CREATE FUNCTION "informix".sp_insbitsmstelcte_bpi(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5), 
                                pdigito_ver CHAR(6), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
								
-- Se clonÃ³ el sp "sp_insbitsmstelcte" para que cuando el dÃ­gito verificador sea 6, se utilice la tabla si_bitsmstelsms_bpi.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 01/12/2016
-- BD    : bdinteg

RETURNING char(5) as codret ;
DEFINE iSqlErr			INTEGER;
DEFINE iNumRnd          INTEGER;
DEFINE exist			INTEGER;
DEFINE dNumRnd2         DECIMAL(10,0);
DEFINE cCodigo          CHAR(6);
DEFINE cCodSp           CHAR(5);
DEFINE codMTU           CHAR(2);

LET iNumRnd     =   0;
LET dNumRnd2    =   0;
LET exist	    =   0;
LET cCodigo     =   '';
LET cCodSp      =   '00000';
LET codMTU      =   '02';


	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
	
	SET LOCK MODE TO WAIT 4;

	IF (LENGTH(TRIM(pdigito_ver)) = 4) THEN
		IF popcion='1' THEN		
		--*****OPCION 1 DE INSERCION*****--
				SELECT count(*) INTO exist FROM bdinteg: "informix".si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
		
			   IF (exist = 0) THEN

				   INSERT INTO bdinteg: "informix".si_bitsmstelsms(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			   END IF;

  			    IF (psucursal = '5007') THEN --MENSJA SMS PARA LAS APPS
			   
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;					   
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				SELECT count(*) INTO exist 
				FROM bdinteg: "informix".si_bitsmstelsms WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
				
				IF (exist > 0) THEN 
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
				SELECT count(*) INTO exist 
				FROM bdinteg: "informix".si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
				
			   IF (exist = 0) THEN
				   INSERT INTO bdinteg: "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
			   END IF;
			
			   IF (psucursal = '5007') THEN  --MENSJA SMS PARA LAS APPS		
			   
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
				ELSE
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					   INTO cCodSp;
				END IF;
					   
		ELIF popcion='2' THEN
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
				SELECT count(*) INTO exist
				FROM bdinteg: "informix".si_bitsmstelsms_bpi WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
				
				IF (exist > 0) THEN 
					UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp;
				END IF;

        ELIF popcion='3' THEN
                
                SELECT count(*) INTO exist 
				FROM bdinteg: "informix".si_bitsmstelsms_bpi WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current) and bandera='f' and tipo_flujo=codMTU;
				
			   IF (exist = 0) THEN
				   INSERT INTO bdinteg: "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha, tipo_flujo) 
						  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current, codMTU);
			   ELSE
                   UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET digito_ver=pdigito_ver, fecha=CURRENT
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND tipo_flujo=codMTU;
               END IF;
			
			   
               EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'MAIL_OTP_LT', pnumcte, '','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0,current,current)
                  INTO cCodSp;

               EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 0, 0, 0, 0, 0,current,current)
                  INTO cCodSp;
				
		ELIF popcion='4' THEN 
                SELECT count(*) INTO exist
				FROM bdinteg: "informix".si_bitsmstelsms_bpi WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND tipo_flujo=codMTU;
				
				IF (exist > 0) THEN 
					UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut AND tipo_flujo=codMTU;
				ELSE
					LET cCodSp  =  '00001';
					Return cCodSp;
				END IF;

        END IF;  
	END IF;

RETURN cCodSp;
END
END FUNCTION;