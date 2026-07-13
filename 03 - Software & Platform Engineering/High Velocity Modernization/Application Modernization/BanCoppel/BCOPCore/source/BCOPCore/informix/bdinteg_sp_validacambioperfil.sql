CREATE PROCEDURE "informix".sp_validacambioperfil(pEmpresa CHAR(3), pSucursal CHAR(4), pEjecutivo CHAR(8), pNombramiento CHAR(30))
RETURNING 
	CHAR(6) AS cCodRet;

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cResp CHAR(1);
DEFINE cPuesto CHAR(3);

LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '000000';
LET cResp = '';
LET cPuesto = '';

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO '/home/sysifx/respaldosbd/JoseLuis/trace.sql';
	 --TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,'') = ''
	OR NVL(pSucursal,'') = ''
	OR NVL(pEjecutivo,'') = '' 
	OR NVL(pNombramiento, '') = '' THEN
		LET cCodRet = '000002';
	ELSE
		 
		SELECT puesto_bancoppel
		INTO cPuesto
		FROM bdinteg:"informix".si_puestosrelacion
		WHERE nombramiento = pNombramiento;
		
		
		SELECT 1 
		INTO cResp
		FROM bdinteg:"informix".si_ejecut
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND ejecutivo = pEjecutivo
		AND puesto = cPuesto;		
		 
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000001';
		END IF;
		
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para validar que se haya realizado previamente el cambio de perfil en central',
'AUTOR : 97247642- Alexis Ibarra',
'FECHA : 29/09/2017',
'Folio : 319',
'BD    : bdinteg',
'----------------------------------------------------------------------------------------------------------',
'Se realiza modificacion para obtener el puesto de la tabla si_puestosrelacion',
'AUTOR : 97839523- Jose Luis Garcia',
'FECHA : 13/11/2018',
'Folio : 502',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_validapuestoejecut(pEmpresa CHAR(3), pEjecutivo CHAR(8))
RETURNING 
	CHAR(6) AS cCodRet, CHAR(3) AS cPuesto;

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cPuesto CHAR(3);

LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '000000';
LET cPuesto = '';

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cPuesto;
		END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO '/home/sysifx/Angel/sp_validapuestoejecut.out';
	-- TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,'') = ''
	OR NVL(pEjecutivo,'') = '' THEN
		LET cCodRet = '000002';
	ELSE
			SELECT puesto
			INTO cPuesto
			FROM bdinteg:"informix".si_ejecut
			WHERE empresa = pEmpresa
			AND ejecutivo = pEjecutivo;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000001';
			LET cPuesto = '';
		END IF;
		
	END IF;
	RETURN cCodRet, cPuesto;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para validar el nÃºmero de puesto de un ejecutivo en central.',
'AUTOR : 98480162 - Ãngel Azael Bobadilla GonzÃ¡lez',
'FECHA : 08/11/2018',
'Folio : 502 - Ademdum Nuevo Perfil de Cajero Principal Supervisor',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_depura_ctespendictayanalisis()
RETURNING CHAR(6) AS codret;

	--DEFINICION DE VARIABLES
	DEFINE vCodret		 CHAR(6);
	DEFINE vSqlerr		 INTEGER;
	DEFINE cNumCte		 CHAR(20);
	DEFINE sCont		 SMALLINT;
	DEFINE sContCtes	 INTEGER;
	DEFINE cDescripcion  CHAR(100);
	DEFINE cNomCte		CHAR(104);
	DEFINE dFechaEnv	DATETIME YEAR to SECOND;
	DEFINE cSituacion	CHAR(1);
	DEFINE cCausa   	CHAR(2);
	DEFINE cSit_ant     CHAR(6);
	DEFINE cEmpresa	CHAR(1);
	DEFINE cStatus	CHAR(1);
	
	
	LET vCodret		= '000000';
	LET vSqlerr		= 0;
	LET cNumCte		= '';
	LET sCont		= 0;
	LET sContCtes	= 0;
	LET cDescripcion = '';	
	LET cNomCte		= '';
	LET dFechaEnv	= DATE(1);
	LET cSituacion  ='';
	LET cCausa      ='';
	LET cSit_ant    ='';
	LET cEmpresa    ='';
	LET cStatus    ='';
	



	--SET DEBUG FILE TO '/home/c94236003/sp_depura_ctespendictayenAnalisis.out';
	--TRACE ON;	
	
	BEGIN    
		ON EXCEPTION SET vSqlerr
			IF vSqlerr <> 0 THEN
				LET vCodret = vSqlerr;
				LET cDescripcion = 'Error en cliente: ' || TRIM(cNumcte) || ' Registros Procesados: '|| sContCtes;
				IF sCont < 1000 and sCont >= 0 THEN
					COMMIT WORK;
				END IF;				
				RETURN vCodret   ;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		
		--- clientes en estatus 1y2-  
		SELECT a.numcte,status_alerta
		FROM "informix".si_bitacora_comparaciones a  inner join bdisitesp:se_ctessitespcte b on a.numcte=b.numcte
		where status_alerta in (1,2) and fecha_insert <= today-15 
		and b.situacion='U' and b.causa not in (62,61)
		into temp tmp_ctedict;
		
		--clasificar
		SELECT a.numcte,status_alerta
		FROM "informix".si_bitacora_comparaciones a  inner join bdisitesp:se_ctessitespcte b on a.numcte=b.numcte
		where status_alerta in (1,2) and fecha_insert <= today-15 
		and b.situacion='U' and b.causa=62
		into temp tmp_ctedictclas;
		
		
		select a.numcte,a.status_alerta, c.empresa from tmp_ctedictclas a
		inner join si_huella_linea b on a.numcte = b.numcte
		inner join si_huella_linea_resultado c on b.ticket =c.ticket
		where c.num_mensaje ='602'
		into temp tmp_ctedictclas_empr;

		insert into tmp_ctedictclas_empr 
		select  a.numcte,a.status_alerta, c.empresa from tmp_ctedictclas a
		inner join si_huella_linea b on a.numcte = b.numcte
		inner join si_huella_linea_resultado_hist c on b.ticket =c.ticket
		where c.num_mensaje ='602';
		
	
		BEGIN WORK;	

	
			
		
			FOREACH WITH HOLD	

				SELECT  numcte,status_alerta
				INTO cNumCte,cStatus
				FROM tmp_ctedict
							
					-- Se cambia estatus de alerta para no ser mostrada en aplicaciÃÂ³n de Dictamen
					UPDATE bdinteg:"informix".si_bitacora_comparaciones SET status_alerta='3' WHERE numcte = TRIM(cNumCte); 
					
					-- Llenar registros en tabla temporal para generar archivo de reporte
				INSERT INTO "informix".si_bitdepurasitesp(id,cliente,fecha_mod,status_ant,status_act)
				VALUES (sContCtes,cNumCte,TODAY,cStatus,'3');
					
				LET sCont = sCont + 1;
				LET sContCtes = sContCtes + 1;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
							
			END FOREACH;
				
				IF sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;

				
			--clientes en analisis y con diferencias en los match dictaminados
			FOREACH WITH HOLD		

					SELECT  numcte,empresa,status_alerta
					INTO cNumCte,Cempresa,cStatus
					from tmp_ctedictclas_empr						
			
					IF Cempresa IN(0,1,2,3) then
							-- Se cambia estatus de alerta para no ser mostrada en aplicaciÃÂ³n de Dictamen
							UPDATE bdinteg:"informix".si_bitacora_comparaciones SET status_alerta='3' WHERE numcte = TRIM(cNumCte); 
							
							-- Llenar registros en tabla temporal para generar archivo de reporte
							INSERT INTO "informix".si_bitdepurasitesp(id,cliente,fecha_mod,status_ant,status_act)
							VALUES (sContCtes,cNumCte,TODAY,cStatus,'3');
							
							-- Se actualiza la situaciÃÂ³n especial del cliente a U-65
							UPDATE bdisitesp:"informix".se_ctessitespcte 
							SET situacion = 'U', causa = 65,usrmodifica = USER ,fchmodifica = CURRENT, motivo_desmarcaje = 'Depuracion quincenal Prev Fraudes' 
							WHERE numcte = TRIM(cNumCte) AND empresa = '001';
							
														
							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
							SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
							INTO cNomCte
							FROM bdinteg:"informix".si_cliente
							WHERE numcte = cNumCte;
				
				 
				
							INSERT INTO bdisitesp:"informix".se_btccamsitespcte(numcte,situacionant, causaant,situacionact,causaact,nombresolicito,usrmodifica,fchmodifica,motivo_desmarcaje)
							VALUES(cNumCte, 'U', '62', 'U', '65', cNomCte,'informix',today , 'Depuracion quincenal Prev Fraudes');
							
							
 
 							
					END IF;
					
					
							
				LET sCont = sCont + 1;
				LET sContCtes = sContCtes + 1;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
							
			END FOREACH;		
					
			IF sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
					
			END IF;		
			
			RETURN vCodret;	

	END;
END PROCEDURE;