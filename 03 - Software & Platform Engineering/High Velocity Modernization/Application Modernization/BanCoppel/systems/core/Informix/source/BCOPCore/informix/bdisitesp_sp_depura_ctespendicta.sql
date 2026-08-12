CREATE PROCEDURE "informix".sp_depura_ctespendicta(pEmpresa CHAR(3))
RETURNING CHAR(6), CHAR(100);

	--DEFINICION DE VARIABLES
	DEFINE vCodret		 CHAR(6);
	DEFINE vSqlerr		 INTEGER;
	DEFINE cNumCte		 CHAR(20);
	DEFINE sCont		 SMALLINT;
	DEFINE sContCtes	 INTEGER;
	DEFINE cDescripcion  CHAR(100);

	
	--DEFINICION DE VARIABLES REPORTE
	DEFINE vsSQL 		CHAR(2204);
	DEFINE vsSQL1 		CHAR(100);
	DEFINE vsSQL2 		CHAR(2004);
	DEFINE vsRepositorio CHAR(100);	
	DEFINE vsArchTemp	CHAR(50);
	DEFINE vsArch    	CHAR(50);
	DEFINE vsSQL3 		CHAR(100);
	
	DEFINE cNomCte		CHAR(104);
	DEFINE dFechaEnv	DATETIME YEAR to SECOND;
	
	
	LET vCodret		= '00000';
	LET vSqlerr		= 0;
	LET cNumCte		= '';
	LET sCont		= 0;
	LET sContCtes	= 0;
	LET cDescripcion = '';
	LET vsSQL3 		= '';
	LET vsArchTemp	= 'reportedepurasitesp.sql';
	LET vsArch		= 'reportedepurasitesp.csv';
	
	LET cNomCte		= '';
	LET dFechaEnv	= DATE(1);
	



	--SET DEBUG FILE TO '/informix/cristo/sp_depura_ctespendicta.out';
	--TRACE ON;	
	
	BEGIN    
		ON EXCEPTION SET vSqlerr
			IF vSqlerr <> 0 THEN
				LET vCodret = vSqlerr;
				LET cDescripcion = 'Error en cliente: ' || TRIM(cNumcte) || ' Registros Procesados: '|| sContCtes;
				IF sCont < 1000 and sCont >= 0 THEN
					COMMIT WORK;
				END IF;				
				RETURN vCodret, cDescripcion  ;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		-- Se depura tabla de paso
		TRUNCATE TABLE "informix".tmp_repdepuractes;
		
		-- Se insertan encabezados de reporte
		INSERT INTO "informix".tmp_repdepuractes(id,consecutivo,cliente,nombre,fecha_env,fecha_mod,sit_ant,sit_act)
		VALUES (sContCtes,'Consecutivo','Cliente','Nombre','Fecha enviado','Fecha cambio Estatus','Estatus Previo','Estatus Actual');

	
		BEGIN WORK;	

			IF NVL(pEmpresa,'') = '' THEN		  
				LET vCodret  = '00001';
				LET cDescripcion = 'Parametro Empresa vacio';
			END IF;	
			
			FOREACH WITH HOLD
			
				SELECT {+AVOID_FULL("informix".se_ctessitespcte)} numcte,fchalta
				INTO cNumCte,dFechaEnv
				FROM "informix".se_ctessitespcte
				WHERE situacion = 'U' AND causa = 62
				
				-- Se actualiza la situaciÃ³n especial del cliente a U-65
				UPDATE "informix".se_ctessitespcte 
				SET situacion = 'U', causa = 65,usrmodifica = USER ,fchmodifica = CURRENT, motivo_desmarcaje = 'Depuracion U-62 Prev Fraudes' 
				WHERE numcte = TRIM(cNumCte) AND empresa = pEmpresa;
				
				-- Se cambia estatus de alerta para no ser mostrada en aplicaciÃ³n de Dictamen
				UPDATE bdinteg:"informix".si_bitacora_comparaciones SET status_alerta='4' WHERE numcte = TRIM(cNumCte);
				
				
				LET sCont = sCont + 1;
				LET sContCtes = sContCtes + 1;
				
				
				-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomCte
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = cNumCte;
				
				-- Llenar registros en tabla temporal para generar archivo de reporte
				INSERT INTO "informix".tmp_repdepuractes(id,consecutivo,cliente,nombre,fecha_env,fecha_mod,sit_ant,sit_act)
				VALUES (sContCtes,sContCtes,cNumCte,cNomCte,dFechaEnv,TODAY,'U-62','U-65');
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
							
			END FOREACH;			
		
			IF sCont < 1000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Consulta de parametro de ruta del reporte
			SELECT valor INTO vsRepositorio 
			FROM bdinteg:"informix".si_param 
			WHERE cod_param='335' AND empresa='001';
			
			--SE DESCARGA LA INFORMACION DE REPORTE DE DEPURACION DEL SISTEMA
		
			LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) ||TRIM(vsArch)|| ' DELIMITER ' || ''',''';
		    LET vsSQL2 =" SELECT consecutivo,cliente,nombre,fecha_env,fecha_mod,sit_ant,sit_act"
						||" FROM 'informix'.tmp_repdepuractes"
						||" ORDER BY id ASC;";
						
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || TRIM(vsArchTemp);
			
			LET vsSQL = TRIM(vsSQL1) ||' ' ||TRIM(vsSQL2)||TRIM(vsSQL3);
			
			--Verifica que no este vacia la consulta.
			IF ( vsSQL <> '' ) THEN
				SYSTEM vsSQL;
				--Permiso para la creacion de archivo.
				LET vsSQL = '' ;
				LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || TRIM(vsArchTemp) ;
				SYSTEM vsSQL ;

				LET vsSQL = '' ;
				LET vsSQL = 'dbaccess bdisitesp < ' || TRIM(vsRepositorio) || TRIM(vsArchTemp) ;
				SYSTEM vsSQL ;
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp);
				SYSTEM vsSQL;
				
			ELSE
				--No fue posible generar el archivo.
				LET vCodret = '00002';
				LET cDescripcion = 'No fue posible generar el archivo';
			END IF ;
				
				
			IF TRIM(vCodret) = '00000' THEN LET cDescripcion=  'Registros Procesados: '|| sContCtes  ; END IF
			RETURN vCodret, cDescripcion;	

	END;
END PROCEDURE
