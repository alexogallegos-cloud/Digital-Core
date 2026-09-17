CREATE PROCEDURE "informix".sp_marcajesitesp(pEmpresa CHAR(3), pTipoProceso SMALLINT,pNumcte CHAR(20), pUsuario CHAR(8))

--RETORNOS-
RETURNING
CHAR(6) AS codigo_ret,
CHAR(40) AS mensaje_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret  CHAR(6);
DEFINE cMensajeRet CHAR(80);
DEFINE iSql_err				    INTEGER; 
DEFINE cSituacion          CHAR(1);
DEFINE iCausa          SMALLINT;  
DEFINE cSitEspecialAct          CHAR(1);
DEFINE sCausaSitEspAct          SMALLINT;   
DEFINE cSitEspecialNew          CHAR(1);      
DEFINE sCausaSitEspNew          SMALLINT;       
DEFINE iPonderacionAct 			SMALLINT;         
DEFINE iPonderacionNew			SMALLINT;   
DEFINE iGrabo               INTEGER;
DEFINE dtFechaHoY              DATE;

    
--INICIALIZACION DE VARIABLES--
LET cCodret = '000000';
LET cMensajeRet = 'Mensaje Exitoso';
LET iSql_err = 0 ;
LET cSituacion = '';
LET iCausa = 0 ;
LET cSitEspecialAct = '';
LET sCausaSitEspAct = 0 ;
LET cSitEspecialNew = '';    
LET sCausaSitEspNew = 0 ;  
LET iPonderacionAct = 0 ;        
LET iPonderacionNew = 0 ;
LET iGrabo = 0 ;
LET dtFechaHoY = DATE(1) ;

BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret, "";
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/jesus/marcaje.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--CONTROL DE ERRORES POR PARAMETRO--
  
	IF NVL(pEmpresa, "") = "" OR NVL(pTipoProceso, '') = '' OR NVL(pNumcte,'') = '' THEN
		LET cCodret = '000001'; --PROCEDIMIENTO EJECUTADO SIN PROPORCIONAR PARAMETROS
		LET cMensajeRet ='PARAMETROS INVALIDOS';
		RETURN cCodret,cMensajeRet;
	END IF;
  
	IF NVL(pTipoProceso,0) NOT IN (1,2,3,4,5) THEN
		LET cCodret = '000002'; --MODO DE EJECUCION INEXISTENTE
		LET cMensajeRet ='TIPO DE EJECUCION INVALIDO';
		RETURN cCodret,cMensajeRet;
	END IF;
	--Obtener la fecha actual del servidor
	SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy  
	INTO dtFechaHoY FROM bdinteg:"informix".si_fechas WHERE empresa = pEmpresa;
						
	 IF pTipoProceso = 1 THEN -- 1- PROCESO DE VENTA DE CARTERAS.			
		LET cSituacion ="T";
		LET iCausa =  97;	 
	 ELIF pTipoProceso = 2 THEN ---2 PROCESO DE ALTA EN LA REESTRUCTURA.	
		LET cSituacion ="P";
		LET iCausa =  35;	 		
	 ELIF pTipoProceso = 4 THEN -- 3- MÃDULO DE CANCELACIÃN DE CRÃDITOS. 	 
		LET cSituacion ="F";
		LET iCausa =  42;	
	 ELIF pTipoProceso = 5 THEN -- 5- MÃDULO DE CANCELACIÃN DE CRÃDITOS POR FALLECIMIENTO DEL CLIENTE. 	 
		LET cSituacion ="F";
		LET iCausa =  102;	
	 END IF;
	 
	 --JMAH INI 
	 IF pTipoProceso = 3 THEN ---2 PROCESO DE LIQUIDACION  REESTRUCTURA.			 
				
			IF EXISTS (SELECT causa FROM "informix".se_ctessitespcte
						WHERE numcte=pNumCte AND situacion = "P" AND causa = 35)  THEN
			
				SELECT LIMIT 1 MAX(cat.ponderacion),cat.situacion,cat.causa
				INTO iPonderacionNew,cSitEspecialNew,sCausaSitEspNew
				FROM "informix".se_ctessitespcte_his hist	
				 INNER JOIN "informix".se_catsitesp cat ON (cat.situacion = hist.situacion and cat.causa=hist.causa )
				WHERE numcte=pNumCte
				GROUP BY cat.situacion,cat.causa;		
					
				IF NVL(cSitEspecialNew ,'') <> '' THEN
				
					--Insertar en la tabla Historica el registro de la marca anterior
					INSERT INTO "informix".se_ctessitespcte_his
					(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal,
					empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
					SELECT tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, 
					empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
					FROM "informix".se_ctessitespcte
					WHERE numcte=pNumCte;	
					
					--se actualiza con la causa historica de mas ponderacion
					UPDATE "informix".se_ctessitespcte 
					SET tipomovto='S',cvesitesporigen='2',situacion = cSitEspecialNew, 
					causa = sCausaSitEspNew, motivo_desmarcaje = '', empleadoefectuo = 'INFORMIX' ,
					nombreefectuo = '',	usralta = 'INFORMIX' 
					WHERE idmovto = idmovto AND empresa = '001' AND numcte = TRIM(pNumCte);		
				
				ELSE--Descarmar
				
					UPDATE "informix".se_ctessitespcte 
					SET tipomovto='S',cvesitesporigen='2',situacion = "U", causa = 65, 
					motivo_desmarcaje = '', empleadoefectuo = 'INFORMIX' ,
					nombreefectuo = '', usralta = 'INFORMIX' 
					WHERE idmovto = idmovto AND empresa = '001' AND numcte = TRIM(pNumCte);
					
				END IF;
			END IF;
	 ELSE
		
		SELECT situacion, causa,ponderacion
		INTO cSitEspecialNew,sCausaSitEspNew,iPonderacionNew
		FROM "informix".se_catsitesp
		WHERE situacion =cSituacion
		AND causa=iCausa;
					
		SELECT situacion,causa
		INTO cSitEspecialAct,sCausaSitEspAct
		FROM "informix".se_ctessitespcte
		WHERE numcte=pNumCte;
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN--SI NO TIENE SITUACION ESPECIAL SE REGISTRA
			INSERT INTO "informix".se_ctessitespcte
			(empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo,
			fechamovto, usralta, fchalta, usrmodifica, fchmodifica)
			VALUES (pEmpresa, pNumCte, cSitEspecialNew, sCausaSitEspNew, '2', '9250', 'M', pUsuario, '', dtFechaHoY, pUsuario, dtFechaHoY, '', DATE(1));
			LET iGrabo =1;
		ELSE 
			
			SELECT ponderacion
				INTO iPonderacionAct
			FROM "informix".se_catsitesp
			WHERE situacion =cSitEspecialAct
			AND causa = sCausaSitEspAct;
		
			--SI LA PONDERACION MAXIMA DE CLIENTE ES MAYOR A LA QUE TIENE ACTUALMENTE
			--IF COMPARA PONDERACIONES																					
			IF NVL(iPonderacionNew,0) < NVL(iPonderacionAct,0) THEN

				--Insertar en la tabla Historica el registro del cliente ya marcado con Situacion y Causa
				INSERT INTO "informix".se_ctessitespcte_his
				(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal,
				empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
				SELECT tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, 
				empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
				FROM "informix".se_ctessitespcte
				WHERE numcte=pNumCte;				

				
				--SI LA PONDERACION NUEVA ES MAYOR (DE MAS PESO) QUE LA ACTUAL SE ACTUALIZA LA  se_ctessitespcte CON LA SITUACION-CAUSA												
				UPDATE "informix".se_ctessitespcte 
				SET tipomovto='S',cvesitesporigen='2',situacion = cSitEspecialNew, causa = sCausaSitEspNew, motivo_desmarcaje = '', empleadoefectuo = 'INFORMIX' ,nombreefectuo = '', usralta = 'INFORMIX' 
				WHERE idmovto = idmovto AND empresa = '001' AND numcte = TRIM(pNumCte);
				LET iGrabo =1;
			END IF;
		END IF;
	END IF;	
	IF iGrabo =1 THEN
		INSERT INTO bdinteg:"informix".si_bitacora_dictamenes(
		numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,tipo,sucursal,numemp,origen,fecha_insert)
		VALUES(pNumCte,cSitEspecialNew, sCausaSitEspNew,0,"",0,0,"9250",pUsuario,"2",dtFechaHoY);
	END IF;	 	
	
 
	--JMAH FIN
	RETURN cCodret, cMensajeRet;
	 	
END;
END PROCEDURE
