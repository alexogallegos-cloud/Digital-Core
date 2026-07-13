CREATE PROCEDURE "informix".sp_inicremesas()
RETURNING CHAR(5), CHAR(80);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cMensaje			CHAR(150);
	DEFINE vCuenta			INTEGER;
	DEFINE vFechaInicio		DATE;
	DEFINE vFechaFinal		DATE;
	DEFINE vFechaHoy		DATE;
	DEFINE cSql				CHAR(1000);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iV_old 			INTEGER;
	DEFINE iV_sre 			INTEGER;
	DEFINE iV_tot 			INTEGER;
	DEFINE iV_fin 			INTEGER;
	DEFINE vStatus			INTEGER;
	
	--Registro de sac_remesas_estadistica
	DEFINE v_numcategoria	CHAR(2);
	DEFINE v_numconvenio	CHAR(5);
	DEFINE v_id_sucursal	CHAR(4);
	DEFINE v_referencia     CHAR(40);
	DEFINE v_importe_pago   MONEY;
	DEFINE v_usuario        CHAR(8);
	DEFINE v_folio_suc      CHAR(16);
	DEFINE v_fecha_pago     DATE;
	DEFINE v_origen         VARCHAR(2);
	DEFINE v_nombre1        VARCHAR(40);
	DEFINE v_nombre2        VARCHAR(40);
	DEFINE v_appaterno      VARCHAR(40);
	DEFINE v_apmaterno      VARCHAR(40);
	DEFINE v_fecha_nac      DATE;
	DEFINE v_rfc            VARCHAR(13);
	DEFINE v_moneda_origen  VARCHAR(3);
	DEFINE v_cuenta_benef   VARCHAR(30);
	DEFINE v_importe_origen MONEY;
	DEFINE v_status_cancelado	CHAR(1);

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	
	--SET DEBUG FILE TO '/informix/RPT/inicremesas/exec_sp_inicremesas.out';
	--TRACE ON;

    BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_inicremesas");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		LET vFechaHoy = TODAY;
		LET cRutaArch = '/RESPALDOSNEW/remesas_estadisticas';
		
		--Determino periodos
		
		IF MONTH(vFechaHoy) != 1 THEN
			LET vFechaInicio		= MDY(MONTH(vFechaHoy)-1,1,YEAR(vFechaHoy));
			LET vFechaFinal			= MDY(MONTH(vFechaHoy),1,YEAR(vFechaHoy))-1;
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl SELECT numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado FROM	bdisac:"informix".sac_remesas_estadistica WHERE	fecha_pago >= MDY(MONTH(today)-1,1,YEAR(today)) AND fecha_pago <= MDY(MONTH(today),1,YEAR(today))-1 ORDER BY fecha_pago ASC;" > ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
		ELSE
			LET vFechaInicio		= MDY(12,1,YEAR(vFechaHoy)-1);
			LET vFechaFinal			= MDY(12,31,YEAR(vFechaHoy)-1);
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl SELECT numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado FROM	bdisac:"informix".sac_remesas_estadistica WHERE	fecha_pago >= MDY(12,1,YEAR(today)-1) AND fecha_pago <= MDY(12,31,YEAR(today)-1) ORDER BY fecha_pago ASC;" > ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
		END IF;
		
		LET vStatus = 0;
		
		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P1' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
			--Paso 1--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P1', today, '0', 'informix', 'sp_inicremesas', 'Descarga los datos de sac_remesas_estadisticas');
			
			--Obtengo datos para bajarlos en un UNL desde la tabla sac_remesas_estadistica
			LET cSql = '';
			LET cSql = 'chmod 777 ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
			LET cSql = '';
			LET cSql = 'dbaccess bdisac ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
			LET cSql = "";
			LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;

			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj(1, 'INS_REMEST_OLD_P1', today, '1', 'informix', 'sp_inicremesas', 'Descarga los datos de sac_remesas_estadisticas');	
			--Paso 1 fin------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
		END IF;
		
		LET vStatus = 0;

		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P2' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
			--Comienza la carga de datos a la tabla sac_remesas_estadistica_old
			
			--Aqui va la validacion de si el proceso es 0 (buscar con un count un resultado con status 0) eliminar todo de la old con rangos de fechas, si no, nada
			LET vStatus = 0;
			
			SELECT COUNT(*)
			INTO vStatus 
			FROM sac_procesos_jobs 
			WHERE proceso = 'INS_REMEST_OLD_P2' 
			AND status = 0
			AND fecha_proceso >= vFechaFinal;
			
			IF vStatus <> 0 THEN
			
				--Eliminamos el proceso con status 0 para que siga flujo normal
				DELETE
				FROM sac_procesos_jobs 
				WHERE proceso = 'INS_REMEST_OLD_P2' 
				AND status = 0
				AND fecha_proceso >= vFechaFinal;
			
				LET vCuenta = 0;
		
				BEGIN WORK;
					FOREACH WITH HOLD
						SELECT 	numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,
								appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado
						INTO	v_numcategoria, v_numconvenio, v_id_sucursal, v_referencia, v_importe_pago, v_usuario, v_folio_suc, v_fecha_pago, v_origen, v_nombre1, v_nombre2,
								v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cuenta_benef, v_importe_origen, v_status_cancelado
						FROM	bdisac:"informix".sac_remesas_estadistica_old
						WHERE	fecha_pago                 >= vFechaInicio
						AND		fecha_pago                 <= vFechaFinal
						ORDER BY fecha_pago
									
						DELETE FROM bdisac:"informix".sac_remesas_estadistica_old
						WHERE  numcategoria = v_numcategoria
						AND    numconvenio  = v_numconvenio
						AND    id_sucursal  = v_id_sucursal
						AND    referencia   = v_referencia
						AND    folio_suc    = v_folio_suc;
									
						--Hago commit y vuelvo a iniciar
						LET vCuenta = vCuenta + 1;
						
						IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
						
					END FOREACH;
					
					--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;
			
			END IF;
			-----------------------------------------------------------------------------------------
			SELECT COUNT(*)
			INTO iV_old
			FROM sac_remesas_estadistica_old;
			
			SELECT COUNT(*) 
			INTO iV_sre
			FROM sac_remesas_estadistica 
			WHERE	fecha_pago >= vFechaInicio
			AND fecha_pago <= vFechaFinal;
			
			LET iV_tot = iV_old + iV_sre;
			--LET iV_tot = iV_tot - 1;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P2', today, '0', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
			
			LET cSql = ''; 
			LET cSql = ' echo "FILE ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl DELIMITER '|| "'" || '|' || "'" || ' 19;' || '">' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;

			LET cSql = ''; 
			LET cSql = ' echo "INSERT INTO "informix".sac_remesas_estadistica_old;' || '">> ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;
			
			LET cSql = ''; 
			LET cSql = 'chmod 777 ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;
			
			LET cSql = ''; 
			LET cSql = 'dbload -d bdisac -c ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql' || ' -l ' || TRIM(cRutaArch) || '/remesas_estadisticas.log' || ' -n 1000 -r'; 
			SYSTEM cSql;
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P2', today, '1', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
			
			SELECT COUNT(*)
			INTO iV_fin
			FROM sac_remesas_estadistica_old;
			
			
			IF iV_tot = iV_fin THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P2', today, '1', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
				LET cSql = "";
				LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
				SYSTEM cSql;
				
				LET cSql = "";
				LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl';
				SYSTEM cSql;
				
			ELSE 
				LET cCodRet            	= "00001";
				LET cMensaje			= 'Error en la carga de datos.';
				RETURN cCodRet, cMensaje;
			END IF; 
			
			
		END IF;
		
		--Eliminamos los datos de la tabla sac_remesas_estadistica
		
		LET vStatus = 0;

		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P3' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
		
			LET vStatus = 0;

			SELECT COUNT(*)
			INTO vStatus 
			FROM sac_procesos_jobs 
			WHERE proceso = 'INS_REMEST_OLD_P3' 
			AND status = 0
			AND fecha_proceso >= vFechaFinal;
		
			IF vStatus <> 0 THEN
		
				DELETE
				FROM sac_procesos_jobs 
				WHERE proceso = 'INS_REMEST_OLD_P3' 
				AND status = 0
				AND fecha_proceso >= vFechaFinal;
		
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P3', today, '0', 'informix', 'sp_inicremesas', 'Depuracion de la tabla sac_remesas_estadisticas');
			LET vCuenta = 0;
			
			BEGIN WORK;
				FOREACH WITH HOLD
					SELECT 	numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,
							appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado
					INTO	v_numcategoria, v_numconvenio, v_id_sucursal, v_referencia, v_importe_pago, v_usuario, v_folio_suc, v_fecha_pago, v_origen, v_nombre1, v_nombre2,
							v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cuenta_benef, v_importe_origen, v_status_cancelado
					FROM	bdisac:"informix".sac_remesas_estadistica
					WHERE	fecha_pago                 >= vFechaInicio
					AND		fecha_pago                 <= vFechaFinal
					ORDER BY fecha_pago
								
					DELETE FROM bdisac:"informix".sac_remesas_estadistica
					WHERE  numcategoria = v_numcategoria
					AND    numconvenio  = v_numconvenio
					AND    id_sucursal  = v_id_sucursal
					AND    referencia   = v_referencia
					AND    folio_suc    = v_folio_suc;
								
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;
					
				END FOREACH;
				
				--Hago commit work de ser necesario
				IF vCuenta < 1000 and vCuenta >= 0 THEN
					COMMIT WORK;
				END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P3', today, '1', 'informix', 'sp_inicremesas', 'Depuracion de la tabla sac_remesas_estadisticas');
		END IF;
	--Actualizo estadisticas para la tabla sac_remesas_estadistica
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_remesas_estadistica;

		RETURN cCodRet, cMensaje;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de guardar informaciÃ³n al historico, asimismo truncar la tabla sac_remesas_estadistica',
'FECHA CREACION : 15 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_sac_valida_ctesremesas(pNumCte CHAR(20), pNombre1 CHAR(26), pNombre2 CHAR(26), pApell_paterno CHAR(26), pApell_materno CHAR(26), pFecha_nac CHAR(20), pNumIdentificacion CHAR(30))
RETURNING  
            CHAR(5) AS cCodRet,
            CHAR(20) AS cNumcte,
            CHAR(1) AS iTipoCliente,
            CHAR(5) AS cValIne,
            CHAR(5) AS cListaNegra,
            CHAR(5) AS cSespecial,
            CHAR(13) AS cRfc;

            DEFINE cCodRet CHAR(5);
            DEFINE cNumcte CHAR(20);
            DEFINE iTipoCliente CHAR(1);
            DEFINE cValIne CHAR(5);
            DEFINE cResultINE CHAR(50);
            DEFINE cListaNegra CHAR(5);
            DEFINE cSespecial CHAR(5);
            DEFINE cStatuscte CHAR(1);
            DEFINE cRfc CHAR(13);
            DEFINE cCodRetRfc CHAR(5);

            DEFINE iSqlErr INTEGER;
            DEFINE iIsamErr INTEGER;
            DEFINE cInfoErr CHAR(10);

            DEFINE icontEsp INTEGER;
            DEFINE iContList INTEGER;

            DEFINE cSituacion CHAR(5);
            DEFINE cCausa CHAR(5);
            DEFINE iContListRfc INTEGER;
            DEFINE cRfcCte CHAR(13);
            DEFINE pNombre3 CHAR(40);

            LET cCodRet = "00000";
            LET cNumcte = "";
            LET iTipoCliente = "";
            LET cValIne = "";
            LET cListaNegra = "";
            LET cSespecial = "";
            LET cStatuscte = "";
            LET cRfc = "";

            LET icontEsp = 0;
            LET iContList = 0;

            LET pNumIdentificacion = TRIM(pNumIdentificacion);

            LET cSituacion = '';
            LET cCausa = '';
            LET cRfc = '';
            LET iContListRfc = 0;
            LET cRfcCte = "";
            LET pNombre3 = "";

          --SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_valida_ctesremesas.out';
          --TRACE ON;

BEGIN 
            ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr::CHAR(5);
                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                END IF;
	        END EXCEPTION;	

            SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
          ----------------------------BUSEQUEDA POR NUM CTE-----------------------------------
        IF  NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = ""AND NVL(pFecha_nac::DATE, "") = "" and NVL(pNumIdentificacion, "") = ""  THEN

            SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
            FROM bdinteg :"informix".si_cliente cte
                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
            WHERE cte.numcte = pNumCte;
                
                IF NVL(cNumcte, "") = "" THEN
                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                    FROM bdinteg :"informix".si_cliente cte
                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                    WHERE cte.numcte = pNumCte
                    AND cte.tipo_cliente in("1", "2");
                            
                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                        LET iTipoCliente = "3";
                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                    END IF;
                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                        END IF;
                END IF;
                    ----------------------------BUSEQUEDA POR NUM DE IDENTIFICACION----------------------------
                        ELSE 
                            IF NVL(pNumCte, "") = ""AND NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = "" AND NVL(pFecha_nac::DATE, "") = "" THEN
                                SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
                                FROM bdinteg :"informix".si_cliente cte
                                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                WHERE ctepf.numidentifi = pNumIdentificacion;

                                IF NVL(cNumcte, "") = "" THEN
                                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                                    FROM bdinteg :"informix".si_cliente cte
                                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                                    WHERE ctepf.numidentifi = pNumIdentificacion
                                    AND cte.tipo_cliente in("1", "2");

                                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                                        LET iTipoCliente = "3";
                                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                    END IF;
                                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                END IF;
                            END IF;
                            -----------------------------------BUSEQUEDA POR NUM nombre y fecha de nacimiento-----------------------------------
                                ELSE 
                                    IF  NVL(pNumCte, "") = "" AND NVL(pNumIdentificacion, "") = "" THEN 
                                        LET pNombre3 = TRIM(pNombre1)||' '||TRIM(pNombre2);
                                        LET pNombre1 = TRIM(pNombre1);
                                        LET pNombre2 = TRIM(pNombre2);
                                        LET pApell_paterno = TRIM(pApell_paterno);
                                        LET pApell_materno = TRIM(pApell_materno);	
                                        EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApell_paterno,pApell_materno,pNombre3,pFecha_nac::DATE) INTO cCodRetRfc, cRfc;
                                        IF NVL(cCodRetRfc,'') <> '00000' THEN
                                            LET cCodRet = cCodRetRfc;
                                        END IF;
                                        
                                        SELECT     cterem.numcte, "1", cterem.status_cte
                                        INTO       cNumcte, iTipoCliente, cStatuscte
                                            FROM       bdinteg:"informix".si_cliente cte 
                                        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                        INNER JOIN bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                            WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                        AND		   TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                        AND        TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                        AND        TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                        AND        TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                        OR         cte.rfc = cRfc ;

                                            IF NVL(cNumcte,"") = "" THEN
                                                SELECT      cte.numcte, "2"
                                                INTO        cNumcte, iTipoCliente
                                                FROM        bdinteg:"informix".si_cliente cte 
                                                INNER JOIN  bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
                                                WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                                AND			TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                                AND         TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                                AND        	TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                                AND        	TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                                OR          cte.rfc = cRfc  
                                                AND         cte.tipo_cliente in("1","2");

                                                IF NVL(cNumcte,"") = "" THEN
                                                    LET cNumcte = "000000000";
                                                    LET iTipoCliente = "3";
                                                    SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
                                                    LET iContList = iContList + iContListRfc;
                                                    IF iContList > 0 THEN
                                                        LET cListaNegra = "True";
                                                        LET iTipoCliente = "2";
                                                        LET cNumcte = "000000001";
                                                    END IF;
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;

                                            ELSE
                                                IF TRIM(cStatuscte) <> "A" THEN
                                                    LET cCodRet = "00003";
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;
                                END IF;
                         END IF;
                END IF;
        END IF;
                -----------------------------------Validacion de INE -----------------------------------
                    SELECT resultado INTO cResultINE
                    FROM bdinteg :"informix".si_bitacora_ife
                    WHERE numcte = cNumcte
                    AND fecha = (SELECT MAX(fecha)FROM bdinteg :"informix".si_bitacora_ife WHERE numcte = cNumcte);
                    IF ((TRIM(NVL(cResultINE, "")) = "") AND (iTipoCliente = 1 OR iTipoCliente = 2))
                        OR (UPPER(TRIM(cResultINE)) = "VERDADERO")
                        OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN LET cValIne = "True";
                        ELIF (TRIM(NVL(cResultINE, "")) = "") AND iTipoCliente = 3 THEN 
                        LET cValIne = "";
                            ELIF (UPPER(TRIM(cResultINE)) = "FALSO")
                            OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN LET cValIne = "False";
                    END IF;
                    ----------------------------------Validacion LISTA NEGRA  -----------------------------------
                        SELECT COUNT(*) INTO iContList
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE numcte = cNumCte;

                        SELECT COUNT(*) INTO iContListRfc
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE rfc = cRfc;
                        LET iContList = iContList + iContListRfc;

                        IF iContList > 0 THEN LET cListaNegra = "True";
                            ELSE LET cListaNegra = "False";
                        END IF;
                        -----------------------------------Validacion SITUACION ESPECIAL -----------------------------------
                            SELECT COUNT(*) INTO icontEsp
                            FROM bdisitesp :"informix".se_ctessitespcte
                            where numcte = cNumCte;

                            IF icontEsp > 0 THEN
                                SELECT situacion,causa INTO cSituacion,cCausa
                                FROM bdisitesp :"informix".se_ctessitespcte
                                where numcte = cNumCte;
                                LET cSituacion = TRIM(cSituacion) || TRIM(cCausa);

                                IF cSituacion IN ('F42', 'P72', 'P108', 'U60') THEN LET cSespecial = "True";
                                    ELSE LET cSespecial = "False";
                                END IF;
        
                                ELSE LET cSespecial = "False";
                            END IF;
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Valida datos cliente (INE, Lista negra y Situacion especial) por numero de clietne , numero de identificacion o nombre ',
'AUTOR: Edgar Navarro',
'SUSTENTO: RQM 10 1534 Envio de remesas outbound',
'FECHA DE MOFICACION: 01/08/2022',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------',
'FOLIO: 433',
'DESCRIPCION: Actualiza informacion de usuario de remesas',
'AUTOR: MARCO RIVERA',
'SUSTENTO: 433 REQ. Base de datos para el alta de usuarios de remesas',
'FECHA DE CREACION: 21/08/2018',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_valida_ctehuella_comp(pNumCte CHAR(20))
    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(942),CHAR(942);
    
    --DEFINICION DE VARIABLES--
    DEFINE iSql_err INTEGER;
    DEFINE cCodRet  CHAR(5);
    DEFINE cHuellaD CHAR(942);
    DEFINE cHuellaI CHAR(942);
   	DEFINE existe INTEGER;
    
    --SET DEBUG FILE TO "/informix/jfponce/gabriel/err/sp_generahuellalinea.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET iSql_err = 0;
    LET cCodRet  = '00000';
    LET cHuellaD = "";
    LET cHuellaI = "";
   	let existe = 0;

BEGIN
    ON EXCEPTION SET iSql_err
        IF iSql_err    <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, cHuellaD,cHuellaI;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT 1, dmapa, imapa
    INTO existe, cHuellaD, cHuellaI
    FROM bdinteg:"informix".si_cte_huella
    WHERE numcte = pNumcte AND estado ="A";

    IF existe IS NULL THEN
        LET cCodRet="00001";
        RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
    END IF;
   
    RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
END;
END PROCEDURE;