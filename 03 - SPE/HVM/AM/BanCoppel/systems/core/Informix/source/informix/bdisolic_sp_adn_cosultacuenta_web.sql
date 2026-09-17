CREATE PROCEDURE "informix".sp_adn_cosultacuenta_web(pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR (20))
RETURNING CHAR(5)       AS codigo_retorno,
		  CHAR(10)		AS movil_cta,
		  CHAR(20)		AS cofirmado,
		  CHAR(04)		AS compania ;
		 

DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cMovilCta	CHAR(10);
DEFINE cCompania	CHAR(04);
DEFINE cCompania2	CHAR(04);
DEFINE cNumSol		CHAR(20);
DEFINE cstatus_cred	CHAR(2);
DEFINE cConfirmado	CHAR(20);
DEFINE iFlag		INTEGER;
DEFINE cTelefono	CHAR(10);
DEFINE cVerificado	CHAR(1);


LET cCodRet			= "00000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cMovilCta		= "";
LET cCompania		= "";
LET cCompania2		= "";
LET cNumSol		= "";
LET cstatus_cred = "";
LET iFlag		= 0;
LET cConfirmado = "";
LET cTelefono = "";
LET cVerificado = "";




BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN cCodRet,cMovilCta, cConfirmado , cCompania ;
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/sp_adn_cosultacuenta.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR    TRIM(NVL(pNumCte,"")) = "" OR  TRIM(NVL(pCuenta,"")) = ""  THEN
		LET cCodRet  = "00001";	
		RETURN cCodRet,cMovilCta, cConfirmado , cCompania ;		
	ELSE			
	
	
		SELECT a.movil_cuenta, a.compania, a.num_solicitud, b.status_cred
			INTO cMovilCta, cCompania , cNumSol, cstatus_cred
		FROM  "informix".ss_adn_solicitudcuenta a,
             bdicred:"informix".sd_maecred b
		WHERE a.numcte = pNumCte
		AND a.cuenta_nomina = pCuenta
        AND a.num_solicitud = b.num_credito;

        
		IF NVL(cMovilCta,'') <> '' THEN
			-- indica que la cuenta no tiene movil asociado	al anticipo de nomina
			LET cCodRet ='00002';
		END IF;	
		--se consulta el telefono celular del cliente		
		SELECT LIMIT 1 a.telefono, b.verificado ,a.carrier
		  INTO cTelefono,cVerificado ,cCompania2
		  FROM bdinteg:"informix".si_telefonos_actual a
		  LEFT JOIN  bdinteg:"informix".si_telefonos b on (b.numcte     = a.numcte 
											   AND b.tipo_tel   = a.tipo_tel
											   AND b.status_tel = a.status_tel
											   AND b.telefono = a.telefono 
											   )
		 WHERE a.numcte     = pNumCte
		   AND a.tipo_tel   = 2
		   AND a.status_tel = 'A';
		   
		IF NVL(cMovilCta,'') <>'' AND  NVL(cTelefono,'') <> '' AND (NVL(cTelefono,'')  <> NVL(cMovilCta,'')) THEN
		   -- indica que la cuenta no tiene movil asociado	al anticipo de nomina
			LET cCodRet ='00003';
		END IF;
		
		IF NVL(cMovilCta,'') = '' AND  NVL(cTelefono,'') ='' THEN
		   -- indica que la cuenta no tiene numero de celular
			LET cCodRet ='00004';
		END IF;
		
		IF NVL(cMovilCta,'') ='' THEN
				LET cMovilCta =cTelefono;
		END IF 
			
		IF NVL(cVerificado,'') <>  "V" THEN 
			 
			LET cConfirmado = 'NO CONFIRMADO';	
			FOREACH 
				SELECT LIMIT 1 1
				INTO iFlag
				FROM bdinteg:"informix".si_bitsmstels b
				WHERE b.numcte     = pNumCte
				AND b.telefono   = cMovilCta
				AND b.bandera    = 't'
				ORDER BY b.fecha DESC
				
				LET cConfirmado = decode(iFlag,1,'CONFIRMADO',"NO CONFIRMADO");
			END FOREACH
		ELSE 
			LET cConfirmado = 'CONFIRMADO';		
		END IF;
		
	
		IF NVL(cNumSol,'') <> '' THEN
       	/*	
			IF nvl(cstatus_cred,'')<>'FF' THEN
                LET cCodRet ='00005';		--indica que tiene un anticipo en tramite o vigente
			ELSE
				UPDATE "informix".ss_adn_solicitudcuenta SET num_solicitud = '' WHERE numcte = pNumCte AND cuenta_nomina = pCuenta;
			END IF;
*/
            
            IF (SELECT COUNT(num_solicitud) FROM bdisolic:ss_solicitudes where empresa ='001' and num_solicitud = cNumSol and status_solicitud  in ('CN','AN','PC','CM') ) > 0 THEN 
                --insertar en tabla historica ss_adn_solicitudcuenta_his  
				INSERT INTO "informix".ss_adn_solicitudcuenta_his(empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, fecha_respaldo)
				SELECT empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, today
				FROM "informix".ss_adn_solicitudcuenta 
				WHERE numcte=pNumCte
				AND cuenta_nomina=pCuenta;
				
				DELETE FROM "informix".ss_adn_solicitudcuenta WHERE numcte = pNumCte AND cuenta_nomina = pCuenta;
				
            ELSE            
                IF nvl(cstatus_cred,'')<>'FF' THEN
                    LET cCodRet ='00005';		--indica que tiene un anticipo en tramite o vigente
                    -- 
                ELSE
					--insertar en tabla historica ss_adn_solicitudcuenta_his  
                    INSERT INTO "informix".ss_adn_solicitudcuenta_his(empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, fecha_respaldo)
					SELECT empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, today
					FROM "informix".ss_adn_solicitudcuenta 
					WHERE numcte=pNumCte
					AND cuenta_nomina=pCuenta;
				
					DELETE FROM "informix".ss_adn_solicitudcuenta WHERE numcte = pNumCte AND cuenta_nomina = pCuenta;
					
                END IF;
           END IF;
			
		END IF;	
			
	END IF;		
	IF NVL(cCompania,'') ='' THEN
	LET cCompania = cCompania2;
	END IF 
	RETURN cCodRet,NVL(cMovilCta,''), cConfirmado , NVL(cCompania,'0');


END
END PROCEDURE
