CREATE PROCEDURE "informix".sp_insbitsmstelcte_apps(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5),pdigito_ver CHAR(6), ptelefono CHAR(10), pEmail  CHAR(100), pteclea_ejecut CHAR(100), pbandera boolean)

RETURNING char(5) as codret ;

DEFINE iSqlErr			INTEGER;
DEFINE iNumRnd          INTEGER;
DEFINE iExist           INTEGER;
DEFINE dNumRnd2         DECIMAL(10,0);
DEFINE cCodigo          CHAR(6);
DEFINE cCodSp1          CHAR(5);
DEFINE cCodSp           CHAR(5);
DEFINE pEmail 			CHAR(100);
DEFINE pSec		  		CHAR(10);

LET iNumRnd     =   0;
LET iExist	    =   0;
LET dNumRnd2    =   0;
LET cCodigo     =   '';
LET cCodSp1     =   '00000';
LET cCodSp      =   '00000';
LET pEmail		= 	'';
LET pSec		= 	'';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	--SET DEBUG FILE TO "/informix/ireb/correo/sp_insbitsmstelcte_apps.out";
    --TRACE ON; 
	
	SELECT correo_elec, MAX(secuencia)  
	INTO pEmail, pSec
	FROM bdinteg:si_correos 
	WHERE  status_correo = 'A' 
	AND numcte = pnumcte
	and tipo_correo='1'
	GROUP BY correo_elec;

	
	IF (LENGTH(TRIM(pdigito_ver)) = 4) THEN
		
		--*****OPCION 1 DE INSERCION*****--
		IF popcion='1' THEN		
				
				SELECT count(numcte) INTO iExist 
					FROM bdinteg: "informix".si_bitsmstelsms 
					WHERE numcte=pnumcte 
					AND telefono=ptelefono 
					AND fecha::date = TODAY 
					AND bandera='f';
			   
			    IF (iExist = 0) THEN
				
					INSERT INTO bdinteg: "informix".si_bitsmstelsms(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
					VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
		
				ELSE
			 
					FOREACH
					
						SELECT LIMIT 1 digito_ver INTO pdigito_ver 
							FROM "informix".si_bitsmstelsms 
							WHERE numcte=pnumcte 
							AND telefono=ptelefono
							AND fecha::date = TODAY
							AND bandera='f'
							ORDER BY fecha DESC
							
					END FOREACH;	
					
			    END IF;

  			    IF (psucursal = '5007') THEN --MENSJA SMS PARA LAS APPS

					--Envia SMS
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)					
					INTO cCodSp;  				
					
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'APP_CLVCEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail , ptelefono, 1, 0, 0, 0, 0,current,current)										
					INTO cCodSp1;  									
					
					IF cCodSp <> '00000' AND cCodSp1 <> '00000' THEN
						LET cCodSp='00002'; 
						--LET cMensajeRet = 'ERROR EN LATINIA';
					ELSE
						LET cCodSp='00000'; 
					END IF;
					
				ELSE
			
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;					   
					  
				END IF;
					   
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--
		ELIF popcion='2' THEN
		
				SELECT count(numcte) INTO iExist 
					FROM bdinteg: "informix".si_bitsmstelsms 
					WHERE numcte=pnumcte AND ejecutivo=pejecutivo 
					AND sucursal=psucursal 
					AND fecha::date = TODAY 
					AND teclea_ejecut IS NULL;
				
				IF (iExist > 0) THEN 
				
					UPDATE bdinteg: "informix".si_bitsmstelsms SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;
					
				ELSE
				
					LET cCodSp  =  '00001';
					Return cCodSp;
					
				END IF;
				
				--AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
				IF pbandera<>'F' or pbandera<>'f' THEN
					UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
				END IF;
				

		END IF; 
		
	ELSE -- ENTONCES ES DE 6
	
		--*****OPCION 1 DE INSERCION*****--
		IF popcion='1' THEN		
			   
				SELECT count(numcte) INTO iExist FROM bdinteg: "informix".si_bitsmstelsms_bpi 
				WHERE numcte=pnumcte 
				AND telefono=ptelefono 
				AND fecha::date = TODAY AND bandera='f';	   

			    IF (iExist = 0) THEN
				   INSERT INTO bdinteg: "informix".si_bitsmstelsms_bpi(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
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
			
			   IF (psucursal = '5007') THEN  --MENSJA SMS PARA LAS APPS		
			   
					--Envia SMS
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'APP_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;  				
					
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_BPI', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', pEmail, ptelefono, 1, 0, 0, 0, 0,current,current)										
					INTO cCodSp1;  									
					
					IF cCodSp <> '00000' AND cCodSp1 <> '00000' THEN
					LET cCodSp='00002'; 
					--LET cMensajeRet = 'ERROR EN LATINIA';
					ELSE
					LET cCodSp='00000'; 
					END IF;
			
					
				ELSE
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(1,'PORTAL_SMS', 'BPI_VACEL','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', '', '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
					INTO cCodSp;
				   
				END IF;
		
		--*****OPCION 2 ACTUALIZACION CODIGO CORRECTO*****--		
		ELIF popcion='2' THEN
		
				SELECT count(numcte) into iExist FROM bdinteg: "informix".si_bitsmstelsms_bpi 
				WHERE numcte=pnumcte 
				AND ejecutivo=pejecutivo 
				AND sucursal=psucursal 
				AND fecha::date = TODAY 
				AND teclea_ejecut IS NULL;				
				
				IF (iExist > 0) THEN 
				
					UPDATE bdinteg: "informix".si_bitsmstelsms_bpi SET teclea_ejecut=pteclea_ejecut, bandera=pbandera
						WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL AND digito_ver = pteclea_ejecut;

				ELSE

					LET cCodSp  =  '00001';
					Return cCodSp;

				END IF;
				
				--AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
				
				IF pbandera<>'F' or pbandera<>'f' THEN
					UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
				END IF;

		END IF;  
	END IF;

RETURN cCodSp;
END
END PROCEDURE;