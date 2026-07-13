CREATE PROCEDURE "informix".sp_valida_dias_transcurridos_personas_vulnerables(pEmpresa CHAR(3),pNumcte CHAR(20), pDiasConfigurados int)
    RETURNING 
    CHAR(6) as sCodRet, 
    CHAR(1) as sDiasTranscurridosPV;

-- DEFINICION DE VARIABLES.
    DEFINE cCodRet                      CHAR(6);
    DEFINE cBandDiasTranscurridosPV     CHAR(1);
    DEFINE iDiastranscurridos           INTEGER;
    DEFINE iDiasConfigurados            INTEGER;
    DEFINE iSqlErr                      INTEGER;
    DEFINE dFecha                       DATE;
    DEFINE iFound                       INTEGER; -- Variable para indicar si se encontrÃ³ el registro
    DEFINE iNopreguntar                 INTEGER;
    
 --SET DEBUG FILE TO '/home/sysifx/sp_consulta_nocaut_sitesp.trc'; 
 --TRACE ON;

-- INICIALIZACION DE VARIABLE.
    LET cCodRet                     = '000000';
    LET cBandDiasTranscurridosPV    = '';
    LET iDiastranscurridos          = 0;
    LET iDiasConfigurados           = 0;
    LET iSqlErr                     = 0;
    LET iFound                      = 0; -- Inicializamos a 0 (no encontrado)
    LET iNopreguntar                = 1;
    BEGIN    
        -- Manejo general de excepciones SQL.
        -- SQLCODE es un cÃ³digo numÃ©rico especÃ­fico de Informix para errores.
        -- Por ejemplo, SQLCODE 100 significa "no data found".
        ON EXCEPTION SET iSqlErr
            IF(iSqlErr != 0) THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cBandDiasTranscurridosPV WITH RESUME;
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        IF NVL(pNumcte, '') = '' THEN
            LET cCodRet = '000001'; -- CÃ³digo de error para cliente nulo/vacÃ­o
            RETURN cCodRet, cBandDiasTranscurridosPV;
        END IF;

        -- Bloque para manejar especÃ­ficamente el caso de "no data found" usando SQLCODE.
        -- SQLCODE 100 es el equivalente a SQLSTATE '02000' para "no data found".
        BEGIN
            ON EXCEPTION IN (100) -- SQLCODE 100 es para "no data found"
                LET iFound = 0; -- No se encontrÃ³ el registro
            END EXCEPTION;
            SELECT COUNT(*) INTO iFound FROM "informix".si_personas_vulnerables WHERE numcte = pNumcte AND FECHA IS NOT NULL LIMIT 1;
            -- PARA OBTENER LOS DIAS TRANSCURRIDOS OBTENGO FECHA DE LA TABLA DE BITACORAS Y REALIZO EL CALCULO DE LOS DIAS 
            
            IF iFound != 0 THEN
                SELECT FECHA INTO dFecha FROM "informix".si_personas_vulnerables WHERE numcte = pNumcte AND FECHA IS NOT NULL LIMIT 1;
            END IF;
            --LET iFound = 1; -- Se encontrÃ³ el registro
        END; -- Fin del bloque de manejo de "no data found"

        -- Validar si se encontrÃ³ el registro
        
        IF iFound = 0 THEN
            LET iNopreguntar = 0;
            LET dFecha = TODAY;
        END IF;

        IF iNopreguntar = 0 THEN
            LET cCodRet = '000000'; 
            LET cBandDiasTranscurridosPV = '1'; -- Indica que sÃ­ han transcurrido los dÃ­as configurados
            RETURN cCodRet, cBandDiasTranscurridosPV;
        ELSE
             -- Si se encontrÃ³ el registro, procedemos con el cÃ¡lculo
            LET iDiastranscurridos = TODAY - dFecha;
            -- SI EL CALCULO DE LOS DIAS TRANSCURRIDOS ES MAYOR O IGUAL A LOS DIAS CONFIGURADOS SE VALIDA SI ESTA CONFIGURADA MOSTRAR VENTANAS 
            IF iDiastranscurridos >= pDiasConfigurados  THEN     
                LET cCodRet = '000000'; 
                LET cBandDiasTranscurridosPV = '1'; -- Indica que sÃ­ han transcurrido los dÃ­as configurados
                RETURN cCodRet, cBandDiasTranscurridosPV;
            ELSE
                LET cCodRet = '000000';     
                LET cBandDiasTranscurridosPV = '0'; -- Indica que no han transcurrido los dÃ­as configurados
                RETURN cCodRet, cBandDiasTranscurridosPV;
            END IF;
        END IF;

        -- Este RETURN final solo se alcanzarÃ­a si no se retorna antes, lo cual no deberÃ­a ocurrir con la lÃ³gica actual
        RETURN cCodRet, cBandDiasTranscurridosPV;
    END;
END PROCEDURE
DOCUMENT
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consulta_bandera_Personas_vulnerabes"',
'Folio.........: RQM 10 1697-2 Adendum: Reparos de AuditorÃ­a.',
'Autor.........: 99801890 - Miguel angel Blanoc Arechiga',
'Fecha.........: 02/07/2025',
'Solicita......: Fernando Rojas',
'BD............: bdisolic';

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