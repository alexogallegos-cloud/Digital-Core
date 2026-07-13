CREATE PROCEDURE "informix".ctefisico_pros_web( pEmpresa CHAR(3),
                                            pFuncion CHAR(1),
                                            pNumcte CHAR(20),
                                            pSucursal CHAR(4),
                                            pEjecutivo CHAR(8),
                                            pTp_persona CHAR (2),
                                            pTp_cliente CHAR(1),
                                            pPaterno CHAR (26),
                                            pMaterno CHAR (26),
                                            pNombre1 CHAR (26),
                                            pNombre2 CHAR (26),
                                            pRfc CHAR (13),
                                            pSector CHAR (2),
                                            pSegmento CHAR (3),
                                            pActividad_princ CHAR (3),
                                            pGrupo CHAR(3),
                                            pSubgrupo CHAR(3),
                                            pResidencia CHAR(1),
                                            pApell_casada CHAR(20),
                                            pNumcte_ref CHAR(20),
                                            pDistrito CHAR(2),
                                            pPuesto_ppes CHAR(1),
                                            pFamiliar_ppes CHAR(1),
                                            pActividad_esp CHAR(11),
                                            pFecha_nac DATE, -- Inician columnas de Ctepf
                                            pLugar_nac CHAR (2),
                                            pNacionalidad CHAR(3),
                                            pFm3 CHAR(18),
                                            pEstado_civil CHAR(1),
                                            pRegimen_mat CHAR(1),
                                            pProfesion CHAR (3),
                                            pSexo CHAR(1),
                                            pCurp CHAR(20),
                                            pCodidentif CHAR(2),
                                            pNumidentif CHAR(30),
                                            pNo_imss CHAR(12),
                                            pDependientes SMALLINT,
                                            pTutor CHAR(60),
                                            pEmail CHAR(60),
                                            pNom_conyuge CHAR(60),
                                            pSeguro_defunc CHAR(1),
                                            pEscolaridad CHAR(2),
                                            pHabita_en CHAR(20),
                                            pAnios_habita SMALLINT,
                                            pNombre_prop CHAR(60),
                                            pImphiporenta MONEY(14,2),
                                            pNumeroife CHAR(20),
                                            pNumerotutor CHAR(20),
                                            pNumeroconyuge CHAR(20),
                                            pEjecut_autoriza CHAR(8),
                                            pPromocion CHAR(2),
                                            pNumhabitantes CHAR(60),
                                            pTipoAlta CHAR(1),
											pFecha DATE,
											pEmp_CobAlta CHAR(8))

RETURNING CHAR(5),CHAR(20);

    DEFINE cCodret 				CHAR(5);
    DEFINE cCodret2 			CHAR(5);
    DEFINE dFecha 				DATE;
    DEFINE iSignumcte 			INT;
    DEFINE cExiste 				CHAR(1);
    DEFINE cEmpresa 			CHAR(3);
    DEFINE cNumcte 				CHAR(20);
    DEFINE cSucursal 			CHAR(4);
    DEFINE cEjecutivo 			CHAR(8);
    DEFINE cEjecut_autoriza 	CHAR(8);
    DEFINE cTp_persona 			CHAR (2);
    DEFINE cTp_cliente 			CHAR(1);
    DEFINE cPaterno 			CHAR (26);
    DEFINE cMaterno 			CHAR (26);
    DEFINE cNombre1 			CHAR (26);
    DEFINE cNombre2 			CHAR (26);
    DEFINE cRfc 				CHAR (13);
    DEFINE cSector 				CHAR (2);
    DEFINE cSegmento 			CHAR (3);
    DEFINE cAtividad_princ 		CHAR (3);
    DEFINE cGrupo 				CHAR(3);
    DEFINE cSubgrupo 			CHAR(3);
    DEFINE cResidencia 			CHAR(1);
    DEFINE cApell_casada 		CHAR(20);
    DEFINE cNumcte_referencia	CHAR(20);
    DEFINE cDistrito 			CHAR(2);
    DEFINE cPuesto_ppes 		CHAR(1);
    DEFINE cFamiliar_ppes 		CHAR(1);
    DEFINE cActividad_esp 		CHAR(11);
    DEFINE dFecha_nac 			DATE; -- Inician columnas de Ctepf
    DEFINE cLugar_nac 			CHAR (2);
    DEFINE cNacionalidad 		CHAR(3);
    DEFINE cFm3 				CHAR(18);
    DEFINE cEstado_civil 		CHAR(1);
    DEFINE cRegimen_mat 		CHAR(1);
    DEFINE cProfesion 			CHAR (3);
    DEFINE cSexo 				CHAR(1);
    DEFINE cCurp 				CHAR(20);
    DEFINE cCodidentif 			CHAR(2);
    DEFINE cNumidentif 			CHAR(20);
    DEFINE cNo_imss 			CHAR(12);
    DEFINE sDependientes 		SMALLINT;
    DEFINE cTutor 				CHAR(60);
    DEFINE cEmail 				CHAR(60);
    DEFINE cNom_conyuge 		CHAR(60);
    DEFINE cSeguro_defunc 		CHAR(1);
    DEFINE cEscolaridad 		CHAR(2);
    DEFINE cHabita_en 			CHAR(20);
    DEFINE sAnios_habita 		SMALLINT;
    DEFINE cNombre_prop 		CHAR(60);
    DEFINE mImphiporenta 		MONEY(14,2);
    DEFINE cNumeroife 			CHAR(20);
    DEFINE cNumerotutor 		CHAR(20);
    DEFINE cNumeroconyuge 		CHAR(20);
    DEFINE cTppersona 			CHAR(2);
    DEFINE sCont 				SMALLINT;
    DEFINE cEsfisica 			CHAR(1);
    DEFINE sLongitud		    SMALLINT;
    DEFINE sLong_cte 			SMALLINT;
    DEFINE iSqlerr				INTEGER;
    DEFINE iIsamerr 			INTEGER;
    DEFINE cStatus_cte 			CHAR(2);
    DEFINE dFecha_alta 			DATE;
    DEFINE cRazon_soc 			CHAR(40);
    DEFINE sDiferencia			SMALLINT;
    DEFINE sI 					SMALLINT;
    DEFINE cNumcte_ref 			CHAR(20);
    DEFINE cNumhabitantes 		CHAR(60);
    DEFINE cSucursalCajaUnica 	CHAR(1);
    DEFINE iOrigen 				INTEGER;
    DEFINE cTipoRel 			CHAR(1);
	DEFINE iID_empCob			INTEGER;
	DEFINE cDescripcion_status	CHAR(40);

	DEFINE cExisteCliente 		CHAR(1);
	DEFINE cCountExistente		INTEGER;

	DEFINE rfc_duplicado		INTEGER;
	
    LET cCodret 			= "00000";
    LET cCodret2 			= '00000';
    LET cEmpresa 			= pEmpresa;
    LET cNumcte 			= " ";
    LET cSucursal 			= pSucursal;
    LET cTppersona 			= pTp_persona;
    LET cNumcte_ref 		= " ";
    LET cEjecut_autoriza 	= pEjecut_autoriza;
    LET iOrigen 			= 0; --sin informacion
    LET cTipoRel			='0';
    LET iID_empCob			= 0;
	LET cDescripcion_status = "";

	LET cExisteCliente 		= '0';
	LET cCountExistente		= 0;
	LET rfc_duplicado		= 0;

    BEGIN

    ON EXCEPTION SET iSqlerr, iIsamerr
        IF iSqlerr != 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret, cNumcte;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/tmp/ctefisico_pros.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO dFecha
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;

    -- 
    IF pSucursal    IS NULL  OR  pEjecutivo       IS NULL  OR  pTp_persona    IS NULL  OR  pTp_cliente   IS NULL  OR
       pPaterno     IS NULL  OR  pNombre1         IS NULL  OR  pRfc           IS NULL  OR  pSector       IS NULL  OR
       pSegmento    IS NULL  OR  pActividad_princ IS NULL  OR  pGrupo         IS NULL  OR  pSubgrupo     IS NULL  OR
       pResidencia  IS NULL  OR  pPuesto_ppes     IS NULL  OR  pFamiliar_ppes IS NULL  OR  pFecha_nac    IS NULL  OR
       pLugar_nac   IS NULL  OR  pNacionalidad    IS NULL  OR  pEstado_civil  IS NULL  OR  pProfesion    IS NULL  OR
       pSexo        IS NULL  OR  pDependientes    IS NULL  OR  pEscolaridad   IS NULL  OR  pHabita_en    IS NULL THEN
        LET cCodret = "00110";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT es_fisica
      INTO cEsfisica
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = pTp_persona;

    IF UPPER(cEsfisica) != "S" THEN
        LET cCodret = "00120";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal = pSucursal;

    IF cExiste IS NULL THEN
        LET cCodret = "00111";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_ejecut
     WHERE ejecutivo = pEjecutivo;

    IF cExiste IS NULL THEN
        LET cCodret = "00112";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector = pSector;

    IF cExiste IS NULL THEN
        LET cCodret = "00113";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_segment
     WHERE segmento = pSegmento;

    IF cExiste IS NULL THEN
        LET cCodret = "00114";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_grupos
     WHERE grupo = pGrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "00115";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_subgpos
     WHERE subgrupo = pSubgrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "00116";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_nacion
     WHERE nacion = pNacionalidad;

    IF cExiste IS NULL THEN
        LET cCodret = "00124";
        RETURN cCodret, cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_profesion
     WHERE profesion = pProfesion;

    IF cExiste IS NULL THEN
       -- LET cCodret = "126";
       -- RETURN cCodret, cNumcte;.
       LET pProfesion = '';
    END IF;

    LET pRfc = TRIM(pRfc);

    SELECT 1, numcte_pros
      INTO cExiste, cNumcte
      FROM "informix".pr_cliente
      WHERE rfc = pRfc;

    IF NOT cExiste IS NULL AND (pFuncion = "A" or pFuncion = "C" ) THEN
        LET cExisteCliente = '1';
		--LET cCodret = "106";
        --RETURN cCodret,cNumcte;
    END IF

    IF pTp_cliente = "M" THEN
        IF pTutor IS NULL OR pTutor = "" THEN
            LET cCodret = "00144";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

	IF (cExisteCliente = '0') THEN

		IF pNumcte IS NULL OR pNumcte = " " THEN
			SELECT valor
			  INTO sLong_cte
			  FROM bdinteg:"informix".si_param
			 WHERE cod_param = 190
			   AND empresa = pEmpresa;

			IF sLong_cte IS NULL THEN
				LET cCodret = "00105";
				RETURN cCodret,cNumcte;
			ELSE
				SELECT valor
				  INTO iSignumcte
				  FROM bdinteg:"informix".si_param
				 WHERE empresa = pEmpresa
				   AND cod_param = 191;

				IF iSignumcte IS NULL OR iSignumcte = 0 THEN
					LET iSignumcte = 1;
				END IF

				LET cNumcte = iSignumcte;
				LET iSignumcte = iSignumcte + 1;

				UPDATE bdinteg:"informix".si_param
				   SET (valor) = (iSignumcte)
				 WHERE empresa = pEmpresa
				   AND cod_param = 191;

				LET sDiferencia = sLong_cte - LENGTH(cNumcte);

				IF sDiferencia > 0 THEN
					FOR sI = 1 TO sDiferencia
						LET cNumcte = "0" || cNumcte;
					END FOR;
				END IF

				LET cNumcte = 'P' || cNumcte;
			END IF;
		ELSE
			LET cNumcte = pNumcte;
		END IF;

	END IF;

    -- ****************** Actualizacion de Parametros *****************
    IF pFuncion = "A" or pFuncion = "C" THEN
        IF (cExisteCliente = '0') THEN
			SELECT 1
			  INTO cExiste
			  FROM "informix".pr_cliente
			 WHERE numcte_pros = cNumcte;

			IF cExiste = "1" THEN
				LET cCodret = "00118";
				RETURN cCodret, cNumcte;
			END IF;
		END IF;

	-- Consulta la tabla bdisolic: ss_status_sol para obtener la descripcion del status.
		SELECT descripcion
		INTO cDescripcion_status
		FROM "informix".pr_status_sol
		WHERE empresa = '001'
		AND status_solicitud = 'PC';

	-- Agrega registros en la tabla pr_autorizacion con status PC.
		SELECT COUNT(*)
			INTO cCountExistente
		FROM "informix".pr_autorizacion 
		WHERE empresa = '001' 
		AND num_solicitud = cNumcte 
		AND status_solicitud = 'PC' 
		AND fecha_entrada = dFecha;
		
		IF cCountExistente>0 THEN
			DELETE FROM "informix".pr_autorizacion WHERE num_solicitud = cNumcte;
		END IF;

		UPDATE "informix".pr_autorizacion SET fecha_salida = dFecha WHERE num_solicitud = cNumcte AND fecha_salida IS NULL;

		INSERT INTO "informix".pr_autorizacion
			(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora)
			VALUES
			('001',pEjecutivo,cNumcte,'PC',cDescripcion_status,'',dFecha,'',pEjecutivo,CURRENT,0,CURRENT HOUR TO SECOND);

	-- Consulta la tabla pr_monitorconcilia para obtener id_empcob por numero de empleado de cobranza y fecha
		SELECT id_empcob
		INTO iID_empCob
		FROM "informix".pr_monitorconcilia
		WHERE fecha_solmasivas = pFecha
		AND empleado_cob = pEjecut_autoriza;

        BEGIN
		
		IF pSucursal = '0800' THEN
			LET pEmp_CobAlta = pEjecutivo;
			
		END IF;
		
		

			IF cExisteCliente = '1' THEN
					UPDATE "informix".pr_cliente SET empresa = pEmpresa, id_empcob = NVL(iID_empCob,0), status_cte = "AL",
					sucursal = pSucursal, ejecutivo = pEjecutivo, tpo_persona = pTp_persona, tipo_cliente = pTp_cliente, apell_paterno = apell_paterno,
					apell_materno = apell_materno, nombre1 = pNombre1, nombre2 = pNombre2, razon_social = " ", rfc = pRfc, sectOR = pSector,
					segmento = pSegmento, actividad_princ = actividad_princ, grupo = pGrupo, subgrupo = pSubgrupo, residencia = pResidencia,
					fecha_alta = dFecha, apell_casada = pApell_casada, distrito = pDistrito, numcte_ref = pNumcte_ref, string1 = "", string2 = pNumhabitantes,
			          numeric1 = 0, numeric2 = 0, money1 = 0, DATE1 = "", puesto_ppes = pPuesto_ppes, familiar_ppes = pFamiliar_ppes,
					  actividad_esp = pActividad_esp, ejecut_autoriza = pEjecut_autoriza, emp_cob_alta = NVL(pEmp_CobAlta,''),user_insert = pEjecutivo,
					  fecha_insert = dFecha, estado = '0', estado_os = '0', envio_parametrico = NULL, status_numcte_pros = 'PC', numcte = '', tipo_alta = pTipoAlta
					  WHERE numcte_pros = cNumcte;

					  UPDATE "informix".pr_ctepf SET fecha_nac = pFecha_nac, lugar_nac = pLugar_nac, nacionalidad = pNacionalidad,
					  no_fm3 = pFm3, estado_civil = pEstado_civil, regim_matrimonio = pRegimen_mat, profesion = pProfesion, sexo = pSexo, curp = pCurp,
					  codidentifi = pCodidentif, numidentifi = pNumidentif, no_imss = pNo_imss, dependientes = pDependientes, tutor = pTutor,
					  nom_conyuge = pNom_conyuge, empresa = pEmpresa, seguro_defunc = pSeguro_defunc, escolaridad = pEscolaridad, habita_en = pHabita_en,
					  anios_habita = pAnios_habita, nombre_prop = pNombre_prop, imp_hipo_renta = pImphiporenta, string1 = pPromocion
					  WHERE numcte_pros = cNumcte;
			ELSE
			        
					IF pSucursal = '0800' THEN
						--- Se agrega validaciÃ³n para CANCELAR solicitud cuando un RFC este DUPLICADO, Folio: 30358 - 07/03/2019 JLM
						SELECT COUNT(*)
							INTO rfc_duplicado
								FROM "informix".pr_cliente
									WHERE rfc = pRfc;
					
						IF rfc_duplicado > 0 THEN 
							LET cCodret = "00118";
							RETURN cCodret, cNumcte;
						END IF;
						--- Termina validaciÃ³n, Folio: 30358 - 07/03/2019 JLM
						
						INSERT INTO "informix".pr_cliente
						( empresa, id_empcob, numcte_pros, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
						  rfc, sectOR, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2,
						  numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, emp_cob_alta,user_insert, fecha_insert, estado, estado_os, status_numcte_pros, numcte, tipo_alta)
						VALUES
						( pEmpresa, NVL(iID_empCob,0), cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
						  pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
						  0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, NVL(pEjecutivo,''),pEjecutivo, dFecha, '0','0','PC','', pTipoAlta);

						INSERT INTO "informix".pr_ctepf
						( numcte_pros, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
						  dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1 )
						VALUES
						( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
						  pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion );
					
					ELSE
					
						INSERT INTO "informix".pr_cliente
						( empresa, id_empcob, numcte_pros, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
						  rfc, sectOR, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2,
						  numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, emp_cob_alta,user_insert, fecha_insert, estado, estado_os, status_numcte_pros, numcte, tipo_alta)
						VALUES
						( pEmpresa, NVL(iID_empCob,0), cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
						  pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
						  0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, NVL(pEmp_CobAlta,''),pEjecutivo, dFecha, '0','0','PC','', pTipoAlta);

						INSERT INTO "informix".pr_ctepf
						( numcte_pros, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
						  dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1 )
						VALUES
						( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
						  pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion );
					
					END IF;
					  
			END IF;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos_pros( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;

        RETURN cCodret, cNumcte;
    ELSE
     -- Se elimina a peticion del cliente. Folio: 1468 - 03/12/2014
	 /*
		SELECT 1
          INTO cExiste
          FROM "informix".pr_cliente --antes: si_cliente
         WHERE numcte_pros = cNumcte;

        IF cExiste IS NULL THEN
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF;
	*/
        BEGIN

        UPDATE "informix".pr_cliente
           SET ( ejecutivo, tpo_persona, tipo_cliente, sector, segmento, actividad_esp,
                 grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2, estado, estado_os, envio_parametrico, numcte ) =
               ( pEjecutivo, pTp_persona, pTp_cliente, pSector, pSegmento, pActividad_esp,
                 pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes, '0', '0', NULL, '')
        WHERE numcte_pros = cNumcte;

        UPDATE "informix".pr_ctepf
           SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
                 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
                 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta ) =
               ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
                 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
                 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta )
        WHERE numcte_pros = cNumcte;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos_pros( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;
    END IF;

		RETURN cCodret, cNumcte;

    END;
END PROCEDURE
;