CREATE PROCEDURE "informix".sp_adn_guardasolicitudcuenta(pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR (20),pMovil CHAR (20) , pCompania CHAR(04) , pUsuario CHAR(10) )
RETURNING CHAR(6)       AS codigo_retorno;
		 

DEFINE cCodRet		CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cMovil	CHAR(20);
DEFINE cMovil2	CHAR(20);
DEFINE cCuenta	CHAR(20);
DEFINE c_num_solicitud CHAR(20);
DEFINE c_status_solicitud CHAR(20);

LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cMovil		= "";
LET cMovil2		= "";
LET cCuenta		= "";
LET c_num_solicitud = "";
LET c_status_solicitud = "";




BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/ifxsif01/tmp/Anticipo/sp_adn_guardasolicitudcuenta.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR  TRIM(NVL(pCuenta,"")) = ""  OR  TRIM(NVL(pMovil,"")) = ""  OR  TRIM(NVL(pCompania,"")) = ""    THEN
		LET cCodRet  = "000001";		
	ELSE			
		
			IF (SELECT count(cve_carrier)			
			FROM bdinteg:si_carriers car, bdicred:"informix".sd_param_campania par
			WHERE car.cve_carrier = par.valor_numerico
			AND par.tipo_campania  =66
			AND par.grupo_parametro ='ADN_MOVIL'		
			and cve_carrier = pCompania		) = 0 THEN
			
				LET cCodRet  = "000004";  --Cliente no tiene numero movil asociado con una compaÃ±ia telefonica valida
				RETURN cCodRet;
			END IF;
		
		 SELECT  movil_cuenta
		 INTO cMovil
		 FROM "informix".ss_adn_solicitudcuenta
		 WHERE numcte =pNumCte and  cuenta_nomina = pCuenta;
		
		 SELECT  movil_cuenta,cuenta_nomina, num_solicitud
		 INTO cMovil2,cCuenta,c_num_solicitud
		 FROM "informix".ss_adn_solicitudcuenta
		 WHERE   movil_cuenta = pMovil;
		 
		 IF NVL(c_num_solicitud,'') <> '' THEN
            SELECT status_solicitud INTO c_status_solicitud 
            FROM "informix".ss_solicitudes 
            WHERE num_solicitud=c_num_solicitud;
         END IF;
			
		IF NVL(cMovil2,'') <> '' and NVL(cCuenta,'') <> pCuenta AND (c_status_solicitud<>'CN' AND c_status_solicitud<>'') THEN
			LET cCodRet  = "000002";		 --El numero movil capturado ya se encuentra registrado en el sistema
			
		ELSE ---NVL(cMovil,'') = '' and  NVL(cMovil2,'') = '' THEN
            IF (SELECT count(numcte) FROM "informix".ss_adn_solicitudcuenta WHERE numcte =pNumCte)>0 THEN
            
                INSERT INTO "informix".ss_adn_solicitudcuenta_his(empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, fecha_respaldo)
                SELECT empresa, numcte, cuenta_nomina, movil_cuenta, num_solicitud, linea, compania, frecuencia_pgo, dia_pago, activacion_cobrada, fecha_ult_disp, monto_disp, flag_validar_cancel, flag_porta, user_insert, fecha_insert, saldocuenta_lc, today
                FROM "informix".ss_adn_solicitudcuenta 
                WHERE numcte=pNumCte;

                DELETE FROM "informix".ss_adn_solicitudcuenta WHERE numcte = pNumCte;
            END IF;				
            
			INSERT INTO "informix".ss_adn_solicitudcuenta(empresa,numcte,cuenta_nomina ,movil_cuenta ,linea , compania ,user_insert, fecha_insert)
			VALUES (pEmpresa, pNumCte,  pCuenta ,pMovil , 0 ,pCompania,pUsuario,TODAY);
            
            IF(SELECT COUNT(telefono) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCte AND tipo_tel = 2 AND telefono = pMovil)=0 THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos('001', pNumCte, pMovil, 2, '', 0, 1, pUsuario) INTO cCodRet;		
            END IF 
		
		/*ELIF NVL(cMovil,'') <> '' and NVL(cMovil2,'') <> cMovil THEN
			UPDATE  "informix".ss_adn_solicitudcuenta
			SET movil_cuenta =pMovil
			WHERE numcte =pNumCte and  cuenta_nomina = pCuenta;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos('001', pNumCte, pMovil, 2, '', 0, 1, pUsuario) INTO cCodRet;			*/	
		END IF;		
		
	END IF;		

	RETURN cCodRet;


END
END PROCEDURE
