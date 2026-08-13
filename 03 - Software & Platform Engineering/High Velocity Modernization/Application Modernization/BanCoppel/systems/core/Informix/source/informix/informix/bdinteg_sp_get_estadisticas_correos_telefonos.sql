CREATE PROCEDURE "informix".sp_get_estadisticas_correos_telefonos()
	RETURNING 
	CHAR(6), 
	CHAR(100);
	--VARIABLES DE ERROR
	DEFINE cVarDataErr      			CHAR(100);
	DEFINE iSqlErr          			INTEGER;
	DEFINE iSamErr          			INTEGER;
	DEFINE vCodRet          			CHAR(6);
	DEFINE cCodRetSP          			CHAR(6);
	--DEFINE cVarDataErrSP      			CHAR(100);

	--DEFINICION DE VARIABLES				
	DEFINE dFechaproceso				DATE;

	DEFINE cProceso						CHAR(100);
	DEFINE cEvento						CHAR(100);

	--si_tmp_alta_ctes_titulares
	DEFINE cSqlStmt						CHAR(200);
	DEFINE cNombreProceso				CHAR(100);
	DEFINE cRutinaBD					CHAR(100);
	DEFINE cTipoRp						CHAR(2);
	DEFINE iIdRp						INTEGER;
	DEFINE cFlag						CHAR(1);
	DEFINE bErrores						BOOLEAN;
	DEFINE iCont 						INTEGER;
	DEFINE iRegCommit 					INTEGER;
	DEFINE cSucursal 					char(4);
	DEFINE cNumcte 						char(20);
	DEFINE cUsuario 					char(8);
	DEFINE dFecha_alta 					date;

	--si_tmp_telefonos
	DEFINE cEmpresa						char(3);
	DEFINE cTelefono					char(13);
	DEFINE sTipo_tel					smallint;
	DEFINE cStatus_tel					char(1);
	DEFINE sSecuencia					smallint;
	DEFINE cExtension					char(5);
	DEFINE sCarrier						smallint;
	DEFINE sCanal						smallint;
	DEFINE sContacto					smallint;
	DEFINE cCofetel						char(1);
	DEFINE dFecha_hora					datetime year to second;
	DEFINE cUser_insert					char(8);
	DEFINE cMovil_fijo					char(1);
	DEFINE cStatus_stel					char(1);
	DEFINE cTel_confirmado				char(1);
	DEFINE dFech_confirmado				datetime year to second;
	DEFINE cVerificado					char(1);
	DEFINE cMarcatel					char(1);
	DEFINE dFecha_actualiza				date;
	DEFINE dFecha						date;
	DEFINE dFecha_hora_inicio			datetime year to second;
	DEFINE dFecha_hora_fin				datetime year to second;
	DEFINE cFechaProceso          		CHAR(11);

	--si_tmp_mantto_ctes_titulares
	DEFINE cNumemp 						char(8);
	
	--si_tmp_sucursal_ejecut
	DEFINE cNom_suc 					char(40);
	DEFINE cEjecutivo 					char(8);
	DEFINE cNom_emp 					char(45);

	DEFINE cNumcte_aux 					char(20);


	--ASIGNACION DE VARIABLES ERROR
	LET vCodRet = '000000';
	LET cVarDataErr = 'EL REPORTE DE ESTADISTICAS, FUE GENERADO SATISFACTORIAMENTE';

	--ASIGNACION DE VARIABLES
	LET dFechaproceso = (CURRENT::DATE) - 1 UNITS DAY;

	LET cProceso 					= '';
	LET cEvento 					= '';

	--si_tmp_alta_ctes_titulares
	LET cSqlStmt = '';
	LET cNombreProceso = '';
	LET cRutinaBD = '';
	LET cTipoRp = '';
	LET iIdRp = 0;
	LET cFlag = '';
	LET bErrores = 'f';
	LET iCont = 0;
	LET iRegCommit = 500;
	LET cSucursal = '';
	LET cNumcte = '';
	LET cUsuario = '';
	LET dFecha_alta = null;
	
	--si_tmp_telefonos
	LET cEmpresa		='';
	LET cTelefono		='';
	LET sTipo_tel		=0;
	LET cStatus_tel		='';
	LET sSecuencia		=0;
	LET cExtension		='';
	LET sCarrier		=0;
	LET sCanal			=0;
	LET sContacto		=0;
	LET cCofetel		='';
	LET dFecha_hora		=null;
	LET cUser_insert	='';
	LET cMovil_fijo		='';
	LET cStatus_stel	='';
	LET cTel_confirmado	='';
	LET dFech_confirmado=null;
	LET cVerificado		='';
	LET cMarcatel		='';
	LET dFecha_actualiza=null;
	LET dFecha			=null;

	--si_tmp_mantto_ctes_titulares
	LET cNumemp			='';

	--si_tmp_sucursal_ejecut
	LET cNom_suc 		='';
	LET cEjecutivo 		='';
	LET cNom_emp 		='';
	
	LET cNumcte_aux		='';
	
	LET dFecha_hora_inicio 	= EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND;
	LET dFecha_hora_fin 	= EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND;
	LET cFechaProceso 		= (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';


	--SET DEBUG FILE TO '/home/e10000758/csr/sp_get_estadisticas_correos_telefonos/sp_get_estadisticas_correos_telefonos.out';
	--TRACE ON;
	BEGIN
		--Manejo del error
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET vCodret=iSqlErr;
							
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, vCodret, cVarDataErr);
				
				RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
			END IF;
		END EXCEPTION;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cProceso = 'GENERACION DE INDICADORES DE SUCURSAL';
		
		LET cEvento	= 'GENERACION DE INFORMACION TEMPORAL DE CTES TITULARES NVOS';
		TRUNCATE TABLE "informix".si_tmp_alta_ctes_titulares;
		
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
			SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} b.sucursal, a.numcte, b.usuario, b.fecha_alta
			INTO cSucursal, cNumcte, cUsuario, dFecha_alta
			FROM "informix".si_cliente a, "informix".si_cte_huella b 
			WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaproceso 
			AND a.tipo_cliente='1'

			LET iCont = iCont + 1;

			--Se realiza el INSERT
			INSERT INTO "informix".si_tmp_alta_ctes_titulares
				(sucursal, numcte, numemp, fecha_alta)
			VALUES
				(cSucursal, cNumcte, cUsuario, dFecha_alta)
			;
		
			--Se limpian las variables
			LET cSucursal = '';
			LET cNumcte = '';
			LET cUsuario = '';
			LET dFecha_alta = null;
		
			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;

		LET cEvento = 'GENERACION DE INFORMACION TEMPORAL DE TELEFONOS';
		
		TRUNCATE TABLE "informix".si_tmp_telefonos;
		
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
		
			SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} 
			empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal
			, contacto, cofetel, fecha_hora, user_insert, movil_fijo
			, status_stel, tel_confirmado, fech_confirmado
			, verificado, marcatel, fecha_actualiza, dFechaproceso::DATE
			INTO
			cEmpresa, cNumcte, cTelefono, sTipo_tel, cStatus_tel, sSecuencia, cExtension, sCarrier, sCanal
			, sContacto, cCofetel, dFecha_hora, cUser_insert, cMovil_fijo
			, cStatus_stel, cTel_confirmado, dFech_confirmado
			, cVerificado, cMarcatel, dFecha_actualiza, dFecha
			FROM "informix".si_telefonos
			WHERE fecha_hora BETWEEN dFecha_hora_inicio AND dFecha_hora_fin
		
			LET iCont = iCont + 1;
			--Se realiza el INSERT
			INSERT INTO "informix".si_tmp_telefonos
				(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal
				, contacto, cofetel, fecha_hora, user_insert, movil_fijo
				, status_stel, tel_confirmado, fech_confirmado
				, verificado, marcatel, fecha_actualiza, fecha)
			VALUES
				(cEmpresa, cNumcte, cTelefono, sTipo_tel, cStatus_tel, sSecuencia, cExtension, sCarrier, sCanal
				, sContacto, cCofetel, dFecha_hora, cUser_insert, cMovil_fijo
				, cStatus_stel, cTel_confirmado, dFech_confirmado
				, cVerificado, cMarcatel, dFecha_actualiza, dFecha)
			;

			--Se limpian las variables
			LET cEmpresa		='';
			LET cNumcte 		= '';
			LET cTelefono		='';
			LET sTipo_tel		=0;
			LET cStatus_tel		='';
			LET sSecuencia		=0;
			LET cExtension		='';
			LET sCarrier		=0;
			LET sCanal			=0;
			LET sContacto		=0;
			LET cCofetel		='';
			LET dFecha_hora		=null;
			LET cUser_insert	='';
			LET cMovil_fijo		='';
			LET cStatus_stel	='';
			LET cTel_confirmado	='';
			LET dFech_confirmado=null;
			LET cVerificado		='';
			LET cMarcatel		='';
			LET dFecha_actualiza=null;
			LET dFecha			=null;
		
			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;
		
		LET cEvento = 'GENERACION DE INFORMACION TEMPORAL DE CTES TITULARES MANTTO';
		
		TRUNCATE TABLE "informix".si_tmp_mantto_ctes_titulares;

		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD		
			
			SELECT {+INDEX ("informix".si_tmp_telefonos "informix".idx_si_tmp_telefonos_01)} DISTINCT user_insert, numcte
			INTO cNumemp, cNumcte
			FROM bdinteg:"informix".si_tmp_telefonos  
			WHERE fecha = dFechaproceso
			AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
			
			SELECT
			b.numcte
			INTO cNumcte_aux
			FROM bdinteg:"informix".si_cliente b
			INNER JOIN bdinteg:"informix".si_cte_huella d ON b.numcte = d.numcte AND d.secuencia = 1 AND dFechaproceso > d.fecha_alta
			WHERE b.numcte=cNumcte
			AND b.tipo_cliente = '1'
			;
			
			IF cNumcte_aux IS NOT NULL AND cNumcte_aux != '' THEN
				SELECT
				c.sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut c 
				WHERE c.ejecutivo=cNumemp
				;
				
				IF cSucursal IS NOT NULL AND cSucursal != '' THEN
					LET iCont = iCont + 1;
					--Se realiza el INSERT
					INSERT INTO "informix".si_tmp_mantto_ctes_titulares
						(numcte, numemp, sucursal, fecha_alta)
					values
						(cNumcte, cNumemp, cSucursal, dFechaproceso)
					;

					--Se limpian las variables
					LET cNumcte			='';
					LET cNumemp			='';
					LET cSucursal		='';
					LET cNumcte_aux		='';

				
					IF iCont >= iRegCommit THEN
						LET iCont = 0;
						COMMIT WORK;
						BEGIN WORK;
					END IF;
				END IF;
			END IF;
		END FOREACH;
		COMMIT WORK;
		
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
			SELECT 
			{+INDEX ("informix".si_correos "informix".idx_corr_cte_fhr_sec)}
			DISTINCT user_insert, numcte
			INTO cNumemp, cNumcte
			FROM bdinteg:"informix".si_correos 
			WHERE fecha_hora like cFechaProceso
			AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
			
			SELECT
			b.numcte
			INTO cNumcte_aux
			FROM bdinteg:"informix".si_cliente b
			INNER JOIN bdinteg:"informix".si_cte_huella d ON b.numcte = d.numcte AND d.secuencia = 1 AND dFechaproceso > d.fecha_alta
			WHERE b.numcte=cNumcte
			AND b.tipo_cliente = '1'
			;
			
			IF cNumcte_aux IS NOT NULL AND cNumcte_aux != '' THEN
				SELECT
				c.sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut c 
				WHERE c.ejecutivo=cNumemp
				;
				
				IF cSucursal IS NOT NULL AND cSucursal != '' THEN
					LET iCont = iCont + 1;
					--Se realiza el INSERT
					INSERT INTO "informix".si_tmp_mantto_ctes_titulares
						(numcte, numemp, sucursal, fecha_alta)
					values
						(cNumcte, cNumemp, cSucursal, dFechaproceso)
					;

					--Se limpian las variables
					LET cNumcte			='';
					LET cNumemp			='';
					LET cSucursal		='';
					LET cNumcte_aux		='';

				
					IF iCont >= iRegCommit THEN
						LET iCont = 0;
						COMMIT WORK;
						BEGIN WORK;
					END IF;
				END IF;
			END IF;
			
		END FOREACH;
		COMMIT WORK;
		
		
		TRUNCATE TABLE "informix".si_tmp_sucursal_ejecut;

		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
		
			SELECT 
			{+INDEX ("informix".si_tmp_alta_ctes_titulares "informix".idx_si_tmp_alta_ctes_titulares_numemp)}
			DISTINCT a.sucursal, a.nombre, b.ejecutivo, b.nombre
			INTO cSucursal, cNom_suc, cEjecutivo, cNom_emp
			FROM "informix".si_sucursales a, "informix".si_ejecut b, "informix".si_tmp_alta_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
		
			LET iCont = iCont + 1;
			--Se realiza el INSERT
			INSERT INTO "informix".si_tmp_sucursal_ejecut
				(sucursal, nom_suc, ejecutivo, nom_emp)
			values
				(cSucursal, cNom_suc, cEjecutivo, cNom_emp)
			;

			--Se limpian las variables
			
			LET cSucursal		='';
			LET cNom_suc 		='';
			LET cEjecutivo 		='';
			LET cNom_emp 		='';

			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;

						
		LET cEvento = 'CONSULTA DE INDICADORES ACTIVOS';
		FOREACH WITH HOLD
			SELECT tipo, identificador, nombre_proceso, rutina
			INTO cTipoRp, iIdRp, cNombreProceso, cRutinaBD
			FROM "informix".si_proc_indicadores
			WHERE estatus_proceso='A'
			AND tipo = 'IN'
			ORDER BY identificador
			
			ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
				IF iSqlErr <> 0 THEN
					LET vCodret=iSqlErr;
					LET bErrores = 't';
					
					INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
					VALUES (dFechaProceso, cProceso, cEvento, vCodret, cVarDataErr);
					
					CONTINUE FOREACH;				
				END IF;
			END EXCEPTION WITH RESUME;
			
			IF NVL(TRIM(cRutinaBD),'') = '' THEN
				CONTINUE FOREACH;
			ELSE
				
				LET cEvento = 'CONSULTA ESTATUS EN SI_CONTROLPROC_INDICADORES';
				SELECT flagfinalizado INTO  cFlag
				FROM  "informix".si_controlproc_indicadores 
				WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;
				
				LET cEvento = 'VALIDA ESTATUS EN SI_CONTROLPROC_INDICADORES';
				IF NVL(cFlag,'') = 'V' THEN
					CONTINUE FOREACH;
				ELIF NVL(cFlag,'') = '' THEN
					INSERT INTO "informix".si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
					VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cNombreProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
				ELIF cFlag = 'F' THEN
					UPDATE "informix".si_controlproc_indicadores
					SET fecha_cargaini = current
					WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso; 
				END IF;
				LET cEvento = 'EJECUTA RUTINA PARA CALCULAR INDICADOR';

				LET cSqlStmt = "EXECUTE PROCEDURE bdinteg:"|| TRIM(cRutinaBD) || "('"|| dFechaproceso ||"','"||cTipoRp||"',"||iIdRp||");";
				EXECUTE IMMEDIATE cSqlStmt;
				
				LET cEvento = 'CONSULTA RESULTADO DE LA RUTINA';
				SELECT coderror INTO cCodRetSP
				FROM "informix".si_controlproc_indicadores 
				WHERE tipo = cTipoRp 
					AND id_proc = iIdRp 
					AND fecha_procesoIni = dFechaProceso 
					AND fecha_procesoFin = dFechaProceso; 

				IF cCodRetSP::INTEGER <> 0 THEN
					LET bErrores = 't';
				END IF;
			END IF;		
		END FOREACH;
		IF bErrores = 't' THEN
			LET vCodRet = '000001';
			LET cVarDataErr = 'UNO O MAS REPORTES NO SE GENERARON CORRECTAMENTE';
		END IF;
		RETURN vCodRet,cVarDataErr;		
	END;
END PROCEDURE;