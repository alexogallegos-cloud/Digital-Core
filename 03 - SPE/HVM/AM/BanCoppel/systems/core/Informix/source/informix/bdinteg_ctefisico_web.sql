CREATE PROCEDURE "informix".ctefisico_web(
	pEmpresa			CHAR(3),
	pFuncion			CHAR(1),
	pNumcte				CHAR(20),
	pSucursal			CHAR(4),
	pEjecutivo			CHAR(8),
	pTp_persona			CHAR (2),
	pTp_cliente			CHAR(1),
	pPaterno			CHAR (26),
	pMaterno			CHAR (26),
	pNombre1			CHAR (26),
	pNombre2			CHAR (26),
	pRfc				CHAR (13),
	pSector				CHAR (2),
	pSegmento			CHAR (3),
	pActividad_princ	CHAR (3),
	pGrupo				CHAR(3),
	pSubgrupo			CHAR(3),
	pResidencia			CHAR(1),
	pApell_casada		CHAR(20),
	pNumcte_ref			CHAR(20),
	pDistrito			CHAR(2),
	pPuesto_ppes		CHAR(1),
	pFamiliar_ppes		CHAR(1),
	pActividad_esp		CHAR(11),
	pFecha_nac			DATE, -- Inician columnas de Ctepf
	pLugar_nac			CHAR (2),
	pNacionalidad		CHAR(3),
	pFm3				CHAR(18),
	pEstado_civil		CHAR(1),
	pRegimen_mat		CHAR(1),
	pProfesion			CHAR (3),
	pSexo				CHAR(1),
	pCurp				CHAR(20),
	pCodidentif			CHAR(2),
	pNumidentif			CHAR(30),
	pNo_imss			CHAR(12),
	pDependientes		SMALLINT,
	pTutor				CHAR(60),
	pEmail				CHAR(60),
	pNom_conyuge		CHAR(60),
	pSeguro_defunc		CHAR(1),
	pEscolaridad		CHAR(2),
	pHabita_en			CHAR(20),
	pAnios_habita		SMALLINT,
	pNombre_prop		CHAR(60),
	pImphiporenta 		MONEY(14,2),
	pNumeroife			CHAR(20),
	pNumerotutor		CHAR(20),
	pNumeroconyuge		CHAR(20),
	pEjecut_autoriza	CHAR(8),
	pPromocion			CHAR(2),
	pNumhabitantes		CHAR (60),
	pIdPais				CHAR(3) 
)

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
	DEFINE cPaterno 			CHAR(26);
	DEFINE cMaterno 			CHAR(26);
	DEFINE cNombre1 			CHAR(26);	
	DEFINE cNombre2 			CHAR(26);
	DEFINE cRfc 				CHAR(13);
	DEFINE cSector 				CHAR(2);
	DEFINE cSegmento 			CHAR(3);
	DEFINE cAtividad_princ 		CHAR(3);
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
	DEFINE cLugar_nac 			CHAR(2);
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
	DEFINE cCodRet3             CHAR(6);
	DEFINE cMensajeRet          CHAR(80);

	-- Valida referencia Coppel JOM 20/Abr/2014 INI
	DEFINE v_codret_cc          CHAR(5);
	DEFINE v_result_cc			CHAR(1);
	-- Valida referencia Coppel JOM 20/Abr/2014 FIN
	--variable para guardar resultado de consulta
	DEFINE nRes					INTEGER;
	DEFINE nRes2				INTEGER;											 					

	LET nRes 				= 0;
	LET nRes2 				= 0;								 
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
	LET cCodRet3            = "00000";
	LET cMensajeRet         = "Se realizÃ³ la consulta correctamente";

	-- Valida referencia Coppel JOM 20/Abr/2014 INI
	LET v_codret_cc      = "00000";
	LET v_result_cc		= '';
-- Valida referencia Coppel JOM 20/Abr/2014 FIN

BEGIN
	ON EXCEPTION SET iSqlerr,iIsamerr
		IF iSqlerr != 0 THEN
			LET cCodret=iSqlerr;
			RETURN cCodret,cNumcte;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/claudio/ctefisico.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dFecha
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = pEmpresa;

    IF pFuncion = "B" THEN
        LET cNumcte = pNumcte;
        SELECT tpo_persona INTO cTppersona
          FROM bdinteg:"informix".si_cliente
         WHERE numero = pnumero;
        IF cTppersona IS NULL THEN
            LET cNumcte = pNumcte;
            LET cCodret = "00104";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT es_fisica
              INTO cEsfisica
              FROM bdinteg:"informix".si_tipper
             WHERE tpo_persona = cTppersona;

            IF UPPER(cEsfisica) != "S" THEN
                LET cCodret = "00120";
                RETURN cCodret,cNumcte;
            END IF;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicheq:"informix".sc_maechq
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "00121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdisolic:"informix".ss_solicitudes
         WHERE empresa="00001"
           AND numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "00121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "00121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdinvers:"informix".sv_maeinv
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "00121";
            RETURN cCodret,cNumcte;
        END IF

        BEGIN
			DELETE FROM bdinteg:"informix".si_direcciones WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_refcomer WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_refbancarias WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_refper WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_ingresos WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_cterelacionado WHERE empresa = "001" AND numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_cteppes WHERE numcte = pNumcte;
			DELETE FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
        END;

        RETURN cCodret,cNumcte;
    END IF

    IF pFuncion = "C" THEN
        LET cNumcte = pNumcte;

        SELECT empresa,     numcte,       status_cte,     sucursal,     ejecutivo,
               tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
               nombre1,     nombre2,      razon_social,   rfc,
               sectOR,      segmento,     actividad_princ,grupo,
               subgrupo,    residencia,   fecha_alta,     apell_casada,
               distrito,    numcte_ref,   puesto_ppes,    familiar_ppes,
               actividad_princ,ejecut_autoriza, string2
          INTO cEmpresa,   cNumcte,      cStatus_cte,    cSucursal,   cEjecutivo,
               cTppersona,  cTp_cliente,  cPaterno,       cMaterno,
               cNombre1,    cNombre2,     cRazon_soc,     cRfc,
               cSector,     cSegmento,    cAtividad_princ,cGrupo,
               cSubgrupo,   cResidencia,  dFecha_alta,    cApell_casada,
               cDistrito,   cNumcte_ref,  cPuesto_ppes,   cFamiliar_ppes,
               cActividad_esp,cEjecut_autoriza, cNumhabitantes
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pNumcte;


        IF cNumcte IS NULL THEN
            LET cCodret = "00104";
            RETURN cCodret,cNumcte;
        END IF

        IF pEmpresa IS NULL OR pEmpresa = " " THEN
            LET pEmpresa = cEmpresa;
        END IF

        IF pSucursal IS NULL OR pSucursal = " " THEN
            LET pSucursal=cSucursal;
        END IF;

        IF pEjecutivo IS NULL OR pEjecutivo = " " THEN
            LET pEjecutivo=cEjecutivo;
        END IF;

        IF pTp_persona IS NULL OR pTp_persona = " " THEN
            LET pTp_persona=cTppersona;
        END IF;

        IF pTp_cliente IS NULL OR pTp_cliente = " " THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pTp_cliente = '2' AND cTp_cliente = '1' THEN
            LET pTp_cliente = cTp_cliente;
        END IF;

        IF pPaterno IS NULL OR pPaterno = " " THEN
            LET pPaterno=cPaterno;
        END IF;

        IF pMaterno IS NULL OR pMaterno = " " THEN
            LET pMaterno=cMaterno;
        END IF;

        IF pNombre1 IS NULL OR pNombre1 = " " THEN
            LET pNombre1=cNombre1;
        END IF;

        IF pNombre2 IS NULL OR pNombre2 = " " THEN
            LET pNombre2=cNombre2;
        END IF;

        IF pRfc IS NULL OR pRfc = " " THEN
            LET pRfc=cRfc;
        END IF;

        IF pSector IS NULL OR pSector = " " THEN
            LET pSector=cSector;
        END IF;

        IF pSegmento IS NULL OR pSegmento = " " THEN
            LET pSegmento=cSegmento;
        END IF;

        IF pActividad_princ IS NULL OR pActividad_princ = " " THEN
            LET pActividad_princ=cAtividad_princ;
        END IF;

        IF pGrupo IS NULL OR pGrupo = " " THEN
            LET pGrupo=cGrupo;
        END IF;

        IF pSubgrupo IS NULL OR pSubgrupo = " " THEN
            LET pSubgrupo=cSubgrupo;
        END IF;

        IF pResidencia IS NULL OR pResidencia = " " THEN
            LET pResidencia=cResidencia;
        END IF;

        IF pApell_casada IS NULL OR pApell_casada = " " THEN
            LET pApell_casada = cApell_casada;
        END IF;

        IF pDistrito IS NULL OR pDistrito = " " THEN
            LET pDistrito=cDistrito;
        END IF;

        IF pNumcte_ref IS NULL OR pNumcte_ref = " " THEN
            LET pNumcte_ref=cNumcte_ref;
        END IF;

        IF pPuesto_ppes IS NULL OR pPuesto_ppes = " " THEN
            LET pPuesto_ppes=cPuesto_ppes;
        END IF;

        IF pFamiliar_ppes IS NULL OR pFamiliar_ppes = " " THEN
            LET pFamiliar_ppes=cFamiliar_ppes;
        END IF;

        IF pActividad_esp IS NULL OR pActividad_esp = " " THEN
            LET pActividad_esp=cActividad_esp;
        END IF;

        IF pEjecut_autoriza IS NULL OR pEjecut_autoriza = " " THEN
            LET pEjecut_autoriza=cEjecut_autoriza;
        END IF;

        SELECT numcte,         fecha_nac,       lugar_nac,        nacionalidad,
               no_fm3,         estado_civil,    regim_matrimonio, profesion,
               sexo,           curp,            codidentifi,      numidentifi,
               no_imss,        dependientes,    tutor,
               nom_conyuge,    seguro_defunc,   escolaridad,      habita_en,
               anios_habita,   nombre_prop,     imp_hipo_renta,   numeroife,
               numerotutor,    numeroconyuge
          INTO cNumcte,        dFecha_nac,      cLugar_nac,       cNacionalidad,
               cFm3,           cEstado_civil,   cRegimen_mat,     cProfesion,
               cSexo,          cCurp,           cCodidentif,      cNumidentif,
               cNo_imss,       sDependientes,   cTutor,
               cNom_conyuge,   cSeguro_defunc,  cEscolaridad,     cHabita_en,
               sAnios_habita,  cNombre_prop,    mImphiporenta,    cNumeroife,
               cNumerotutor,   cNumeroconyuge
        FROM bdinteg:"informix".si_ctepf
        WHERE numcte = pNumcte;

        SELECT correo_elec
          INTO cEmail
        FROM "informix".si_correos
        WHERE numcte = pNumcte
           AND tipo_correo = 1
           AND status_correo = 'A'
		   and secuencia = (
			select max(secuencia)
			from "informix".si_correos
			where numcte = pNumcte AND status_correo = 'A' AND tipo_correo = 1);

        IF pFecha_nac IS NULL OR pFecha_nac = " " THEN
            LET pFecha_nac=dFecha_nac;
        END IF;

        IF pLugar_nac IS NULL OR pLugar_nac = " " THEN
            LET pLugar_nac=cLugar_nac;
        END IF;

        IF pNacionalidad IS NULL OR pNacionalidad = " " THEN
            LET pNacionalidad=cNacionalidad;
        END IF;

		-->> 29/10/2014
        --IF pFm3 IS NULL OR pFm3 = " " THEN
        --    LET pFm3 = cFm3;
        --END IF; << 29/10/2014

        IF pEstado_civil IS NULL OR pEstado_civil = " " THEN
            LET pEstado_civil=cEstado_civil;
        END IF;

        IF pRegimen_mat IS NULL OR pRegimen_mat = " " THEN
            LET pRegimen_mat=cRegimen_mat;
        END IF;

        IF pProfesion IS NULL OR pProfesion = " " THEN
            LET pProfesion = cProfesion;
        END IF;

        IF pSexo IS NULL OR pSexo = " " THEN
            LET pSexo=cSexo;
        END IF;

		--SE VALIDA QUE LA CURP NO VENGA VACIA
		IF(pCurp <> '') THEN														  
			IF SUBSTRING(cRfc FROM 1 FOR 10) <> SUBSTRING(pCurp FROM 1 FOR 10) THEN
				INSERT INTO bdinteg:"informix".si_bitacora_cambio_curp
                ( numcte, rfc, curp, resultado, fecha )
				VALUES
                ( pNumcte, cRfc, pCurp, '03', CURRENT );

				--LET pCurp = cCurp;
			END IF;		  
        END IF;

        IF pCodidentif IS NULL OR pCodidentif = " " THEN
            LET pCodidentif = cCodidentif;
        END IF

        IF pNumidentif IS NULL OR pNumidentif = " " THEN
            LET pNumidentif = cNumidentif;
        END IF

        IF pNo_imss IS NULL OR pNo_imss = " " THEN
            LET pNo_imss = cNo_imss;
        END IF

        IF pDependientes IS NULL OR pDependientes = " " THEN
            LET pDependientes = sDependientes;
        END IF

        IF pTutor IS NULL OR pTutor = " " THEN
            LET pTutor = cTutor;
        END IF

        IF pEmail IS NULL OR pEmail = " " THEN
            LET pEmail = cEmail;
        END IF

        IF pNom_conyuge IS NULL OR pNom_conyuge = " " THEN
            LET pNom_conyuge = cNom_conyuge;
        END IF

        /* #####################################################
        IF pseguro_definc IS NULL OR pSeguro_defunc = " " THEN
            LET pSeguro_defunc = cSeguro_defunc;
        END IF
        ##################################################### */

        IF pEscolaridad IS NULL OR pEscolaridad = " " THEN
            LET pEscolaridad = cEscolaridad;
        END IF

        IF pHabita_en IS NULL OR pHabita_en = " " THEN
            LET pHabita_en = cHabita_en;
        END IF

        IF pAnios_habita IS NULL THEN
            LET pAnios_habita = sAnios_habita;
        END IF

        IF pNombre_prop IS NULL OR pNombre_prop = " " THEN
            LET pNombre_prop = cNombre_prop;
        END IF

        IF pImphiporenta IS NULL THEN
            LET pImphiporenta = mImphiporenta;
        END IF

        IF pNumeroife IS NULL OR pNumeroife = " " THEN
            LET pNumeroife = cNumeroife;
        END IF

        IF pNumerotutor IS NULL OR pNumerotutor = " " THEN
            LET pNumerotutor = cNumerotutor;
        END IF

        IF pNumeroconyuge IS NULL OR pNumeroconyuge = " " THEN
            LET pNumeroconyuge = cNumeroconyuge;
        END IF
    END IF

	-- DSB 19/10/2014 >>
	IF NVL(pFuncion,'') = "S" THEN
		IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pEscolaridad,'') = '' THEN
			LET cCodret = "00200";
			RETURN cCodret,cNumcte;
		ELSE
			SELECT 1 INTO cExiste
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa AND numcte = pNumcte;

		   IF NVL(cExiste,'') = '1' THEN
				SELECT 1 INTO cExiste
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa AND numcte = pNumcte;

				IF NVL(cExiste,'') = '1' THEN
					UPDATE bdinteg:"informix".si_ctepf
					SET escolaridad = pEscolaridad
					WHERE empresa = pEmpresa AND numcte = pNumcte;
					RETURN cCodret,cNumcte;
				ELSE
					LET cCodret = "00220";
					RETURN cCodret,cNumcte;
			   END IF
			ELSE
				LET cCodret = "00210";
				RETURN cCodret,cNumcte;
		   END IF
		END IF;
	END IF -- << DSB 19/10/2014

    --- Verifica recepcion correcta de datos
    IF pSucursal IS NULL OR pEjecutivo IS NULL OR
       pTp_persona IS NULL OR pTp_cliente IS NULL OR
       pPaterno IS NULL OR pNombre1 IS NULL OR pRfc IS NULL OR
       pSector IS NULL OR pSegmento IS NULL OR
       pActividad_princ IS NULL OR pGrupo IS NULL OR
       pSubgrupo IS NULL OR pResidencia IS NULL OR
       pPuesto_ppes IS NULL OR pFamiliar_ppes IS NULL OR
       pFecha_nac IS NULL OR pLugar_nac IS NULL OR
       pNacionalidad IS NULL OR pEstado_civil IS NULL OR
       pProfesion IS NULL OR pSexo IS NULL OR
       pCodidentif IS NULL OR pNumidentif IS NULL OR
       pDependientes IS NULL OR pEscolaridad IS NULL OR
       pHabita_en IS NULL THEN
        LET cCodret = "00110";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT es_fisica
      INTO cEsfisica
    FROM bdinteg:"informix".si_tipper
    WHERE tpo_persona = pTp_persona;

    IF UPPER(cEsfisica) != "S" THEN
        LET cCodret = "00120";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal=pSucursal;

    IF cExiste IS NULL THEN
        LET cCodret = "00111";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_ejecut
     WHERE ejecutivo=pEjecutivo;

    IF cExiste IS NULL THEN
        FOREACH
            SELECT limit 1 1
                INTO cExiste
            FROM bdinteg:"informix".si_usuario_movil
            WHERE ejecutivo=pEjecutivo
        END FOREACH;

        IF cExiste IS NULL THEN
            LET cCodret = "00112";
            RETURN cCodret,cNumcte;
        END IF;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector=pSector;

    IF cExiste IS NULL THEN
        LET cCodret = "00113";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_segment
     WHERE segmento=pSegmento;

    IF cExiste IS NULL THEN
        LET cCodret = "00114";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_grupos
     WHERE grupo=pGrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "00115";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_subgpos
     WHERE subgrupo=pSubgrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "00116";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_nacion
     WHERE nacion=pNacionalidad;

    IF cExiste IS NULL THEN
        LET cCodret = "00124";
        RETURN cCodret,cNumcte;
    END IF;

    /* ############################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_actesp
     WHERE codigo=pActividad_esp;

    IF cExiste IS NULL THEN
        LET cCodret="125";
        RETURN cCodret,cNumcte;
    END IF;
    ############################ */

	-- DSB 29/10/2014
    /* SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_profesion
     WHERE profesion = pProfesion;

    IF cExiste IS NULL THEN
        LET cCodret = "126";
        RETURN cCodret,cNumcte;
    END IF; */

    LET pRfc = TRIM(pRfc);

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_cliente
     WHERE rfc = pRfc;

    IF NOT cExiste IS NULL AND pFuncion = "A" THEN
        LET cCodret = "00106";
        RETURN cCodret,cNumcte;
    END IF

    /* #################################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_escolaridad
     WHERE escolaridad = pEscolaridad;

    IF cExiste IS NULL THEN
        LET cCodret="135";
        RETURN cCodret,cNumcte;
    END IF;
    ################################# */

    IF TRIM(pCodidentif) <> "" THEN
        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_tipoidentif
         WHERE codidentif = pCodidentif;

        IF cExiste IS NULL THEN
            LET cCodret = "00133";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    /* ##############################
    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_habitaen
     WHERE habita_en = pHabita_en;

    IF cExiste IS NULL THEN
        LET cCodret="117";
        RETURN cCodret,cNumcte;
    END IF; --- Revisar MAC
    ############################## */

    IF pTp_cliente = "M" THEN ---MenOR de edad
        IF pTutor IS NULL OR pTutor = "" THEN
            LET cCodret = "00144";
            RETURN cCodret,cNumcte;
        END IF

        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pTutor;

        IF cExiste IS NULL THEN
            LET cCodret = "00145";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    IF pNumcte IS NULL OR pNumcte = " " THEN
        SELECT valor
          INTO sLong_cte
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 7
           AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "00105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte=iSignumcte;
            LET iSignumcte=iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            LET sDiferencia = sLong_cte - LENGTH(cNumcte);

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;
    ELSE
        LET cNumcte = pNumcte;
    END IF;

    -- ****************** Actualizacion de Parametros *****************
    IF pFuncion = "A" THEN
        SELECT 1 INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste = "1" THEN
            LET cCodret = "00118";
            RETURN cCodret, cNumcte;
        END IF;

        IF NVL(pNumcte_ref,'') <> '' THEN
-- Valida referencia Coppel JOM 20/Abr/2014 INI
            EXECUTE PROCEDURE bdinteg:"informix".sp_cons_ref_cop(pEmpresa, pSucursal, pEjecutivo, cNumcte, pNumcte_ref, pPaterno, pMaterno, pNombre1 ,pNombre2, pRfc)
                         INTO v_codret_cc, v_result_cc;

            IF ( v_result_cc = '1' ) THEN
                LET pNumcte_ref = '';
            END IF;
         END IF;
-- Valida referencia Coppel JOM 20/Abr/2014 FIN

        BEGIN

        INSERT INTO bdinteg:"informix".si_cliente
        ( empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
          rfc, sectOR, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2,
          numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, user_insert, fecha_insert) --, id_pais ) -- DSB230162JERV1694 id_pais
        VALUES
        ( pEmpresa, cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
          pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
          0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, pEjecutivo, dFecha); --, pIdPais); -- DSB230162JERV1694 pIdPais

        INSERT INTO bdinteg:"informix".si_ctepf
        ( numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
          dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel, id_pais ) -- DSB230162JERV1694 id_pais
        VALUES
        ( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
          pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0', pIdPais); -- DSB230162JERV1694 pIdPais

        SELECT NVL(cajaunica, '')
          INTO cSucursalCajaUnica
          FROM bditarjcop:"informix".sucursalescajaunica
         WHERE cvesucursal = pSucursal;

        IF cSucursalCajaUnica = 'V' THEN
            UPDATE bdinteg:"informix".si_cliente
               SET string1 = '1'
             WHERE numcte = cNumcte;
        END IF;

        IF NVL(pNumcte_ref,"") <> "" THEN ---JMAH se realiza validacion para relacionar al cliente Bancoppel con un Cliente Coppel
			LET iOrigen = 2; --relacion por alta de cliente ; ---JMAH
			LET cTipoRel ='1';
		END IF;		--se agrega llamado para crear relacion de clientes bancoppel-coppel.

		EXECUTE PROCEDURE bdinteg:"informix".sp_relacion_generarelacion (cNumcte,pNumcte_ref,'',cTipoRel,iOrigen)
        INTO cCodRet3,cMensajeRet;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;

        RETURN cCodret, cNumcte;
    ELSE
        SELECT 1
          INTO cExiste
          FROM "informix".si_cliente
         WHERE numcte = cNumcte;

        IF cExiste IS NULL THEN
            LET cCodret = "00104";
            RETURN cCodret,cNumcte;
        END IF;

        BEGIN

		SELECT COUNT(*) INTO nRes FROM si_usuario_movil WHERE ejecutivo=pEjecutivo;
        
		IF (nRes > 0) THEN
            
			SELECT  COUNT(*) INTO nRes2 FROM si_solicitud_movil WHERE numcte=cNumcte AND folio_procesado=0 AND status_valua=1;
			
            IF (nRes2 > 0) THEN			   
                SELECT first 1 escolaridad, tipo_residencia, pers_domicilio 
                    INTO pEscolaridad, pHabita_en, pNumhabitantes
                    FROM si_solicitud_movil
					WHERE numcte=cNumcte
					AND folio_procesado=0
					AND escolaridad <>'' AND escolaridad IS NOT NULL
					AND tipo_residencia <>'' AND tipo_residencia IS NOT NULL
					AND pers_domicilio <>'' AND pers_domicilio IS NOT NULL;
					
				
				LET pEscolaridad="0"||pEscolaridad;
				
            END IF;
        END IF;

        -- Se Desactiva por Requerimiento de Bancoppel JLP 18/09/07
        UPDATE bdinteg:"informix".si_cliente
           SET ( ejecutivo, tpo_persona, tipo_cliente, --- apell_paterno, apell_materno, nombre1, nombre2, rfc, sectOR, segmento, actividad_esp,
                 sectOR, segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2) = --, id_pais) = -- DSB230162JERV1694 id_pais
               ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
                 pSector, pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes) --, pIdPais) -- DSB230162JERV1694 pIdPais
        WHERE numcte = cNumcte;


		--SE VALIDA SI LA CURP VIENE VACIA
		IF(pCurp = '') THEN
			SELECT curp
			INTO pCurp
			FROM "informix".si_ctepf 
			WHERE numcte = cNumcte;
		END IF;																 
        UPDATE bdinteg:"informix".si_ctepf
           SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
                 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
                 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, sms_cel, id_pais) = -- DSB230162JERV1694 id_pais
               ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
                 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
                 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, '0', pIdPais) -- DSB230162JERV1694 pIdPais
        WHERE numcte = cNumcte;

        END;

        IF pEmail IS NOT NULL OR pEmail <> '' THEN
            CALL sp_registra_correos( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo )
            RETURNING cCodret2;
        END IF;
    END IF;
    RETURN cCodret, cNumcte;
    END;
END PROCEDURE
DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"FECHA : 14/Marzo/2008",
"Ver.  : 1.1",
"BD    : bdinteg",
"MODIFICO : Moreno Cota Jesus Alberto",
"MODIFICACION: Se agrega cantidad de personas vivien domicilio",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Gaxiola Gaxiola Frank",
"MODIFICACION: Se agrega validacion para cuando la sucursal este activa como caja unica",
"marque al cliente en el campo string1 como cliente nacido en caja unica",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Aguilar Heredia Jesus Manuel",
"FECHA : 26/Abril/2012",
"MODIFICACION: Se agrega validacion para crear la relacion de clientes Bancoppel con Coppel en una tabla de control",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Zazueta Acosta Josue Remberto",
"FECHA : 11/JUNIO/2012",
"MODIFICACION:Se modifico para que realice el insert a la tabla de si_relacion_ctebcplcpl por medio de el", "sp_relacion_generarelacion en lugar de aserlo por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Zazueta Acosta Josue Remberto",
"FECHA : 15/Agosto/2012",
"MODIFICACION: Se Modifica Origen de la relacion de clientes, se quita el origen por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MOFIDICO     : Martin Eduardo Miranda",
"FECHA        : 26/Abril/2013",
"MODIFICACION : Se modifica Procedimiento Almacenado para comentar la linea 'LET pCurp = cCurp'",
"               * Se aplican reglas de programacion.",
"MOFIDICO     : Claudio Almodovar",
"FECHA        : 29/10/2014",
"cCodret  200 : parametros vacios para opcion 'S'",
"cCodret  210 : cliente no existe en bdinteg:si_cliente",
"cCodret  220 : cliente no existe en bdinteg:si_ctepf",
"MODIFICACION : Se modifica para agregar la opcion 'S' para pFuncion y se comenta donde pFm3 toma valor si es vacio o null",
"--------------",
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - Jose Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripcion:	Se agrega parametro para aceptar el nuevo campo id_pais para el insert de la si_cliente y para el update de la si_ctepf",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694",
'Autor: Diego Perez',
'BD: bdinteg',
'Fecha: 13/06/2017',
'DescripciÃ³n: Clon del ctefisico y modificacion del coRet a 5 digitos, se agrega 00 a la izq para los codRet ya identificados';

CREATE PROCEDURE "informix".sp_val_clubproteccion_web(pCliente CHAR(20),pCuenta CHAR(20),pCredito CHAR(20),pTarjeta CHAR(20))


RETURNING CHAR(5) AS codRet,
		  DATE AS fecha_vencimiento;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE dtFechaHoy DATE;
DEFINE dtFechaVenc DATE;
DEFINE cNumCte CHAR(20);
DEFINE iDiaVenc INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodret	= "00000";
LET iSqlErr = 0;
LET iDiaVenc = 0;
LET cNumCte = '';
LET dtFechaHoy = '';
LET dtFechaVenc = DATE(1);

--SET DEBUG FILE TO '/home/sp_val_clubproteccion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,dtFechaVenc;
		END IF;
	END EXCEPTION;

	RETURN cCodret,today+100;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET pCliente=TRIM(NVL(pCliente,''));
	LET pCuenta=TRIM(NVL(pCuenta,''));
	LET pCredito=TRIM(NVL(pCredito,''));
	LET pTarjeta=TRIM(NVL(pTarjeta,''));
	

	IF pCliente = '' AND pCuenta = '' AND pCredito= '' AND pTarjeta = '' THEN
		LET cCodret	= "00001";
	ELSE
		IF pCliente = '' THEN
			IF  pCuenta <> '' OR pCredito <> '' THEN
				SELECT num_cte INTO cNumCte FROM bdicheq: "informix".sc_maechq WHERE cuenta = pCuenta;
				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecred WHERE num_credito = pCredito;

					IF dbinfo("sqlca.sqlerrd2") = 0 then
						SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_maecredcrd WHERE num_credito = pCredito;
					END IF;
				END IF;
			ELIF pTarjeta <> '' THEN
				SELECT numcte INTO cNumCte FROM bdicred: "informix".sd_tarjeta WHERE num_tarjeta = pTarjeta;

				IF dbinfo("sqlca.sqlerrd2") = 0 then
					SELECT numcte INTO cNumCte FROM bdicheq: "informix".sc_tarjeta WHERE num_tarjeta = pTarjeta;
				END IF;
			END IF;
		ELSE
			SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas where empresa='001';

			SELECT fecha_vencimiento INTO dtFechaVenc FROM bdinteg: "informix".si_ctesavencer  WHERE numcte_banco = pCliente AND pagado = 0;

			IF dtFechaHoy <= dtFechaVenc THEN
				LET iDiaVenc =  dtFechaVenc - dtFechaHoy;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc <= 7 THEN
					LET cCodret	= "01468";
					RETURN cCodret,dtFechaVenc;
				END IF;
			ELIF dtFechaHoy > dtFechaVenc THEN
				LET iDiaVenc =  dtFechaHoy - dtFechaVenc;
				LET iDiaVenc = NVL(iDiaVenc,0);

				IF iDiaVenc > 0 AND iDiaVenc <= 60 THEN
					LET cCodret	= '01469';
					RETURN cCodret,dtFechaVenc;
				ELIF iDiaVenc > 60 THEN
					LET cCodret	= '01470';
					RETURN cCodret,dtFechaVenc;
				END IF;
			END IF;
		END IF;

	END IF;

	RETURN cCodret,dtFechaVenc;
END
END PROCEDURE
DOCUMENT
'Folio: 137 Consulta saldos para Club de proteccion familiar.',
'Autor: Bryan Limon',
'BD: bdinteg',
'Fecha: 03/11/2016',
'Descripcion: REALIZA LA VALIDACION SEGUN EL ESTADO EN QUE SE ENCUENTRE EL CLUB DE PROTECCION DEL CLIENTE VALIDA QUE MENSAJE MOSTRAR AL USUARIO AL USUARIO';

CREATE PROCEDURE "informix".sp_valida_cel_repetido_web(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))

	RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;
	
	DEFINE sCodRet		CHAR(5);
	DEFINE iCantRep     INTEGER;
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE iDias        INTEGER;
	
	LEt sCodRet     =   '00000';
	LET iCantRep    =   0;
	LET iSqlErr		=   0;
	LET iSamErr     =   0;
	LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='V'	AND (DATE(CURRENT) - DATE(fecha_hora) < 90);
		
	IF iCantRep >= 1 THEN
		LET sCodRet = '00288';
	END IF;
	
	RETURN sCodRet, iCantRep;
END
END PROCEDURE;