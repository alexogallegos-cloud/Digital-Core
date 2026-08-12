CREATE PROCEDURE "informix".ctefisico_opt(
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
	pFecha_nac			DATE,
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

DEFINE cCodret 			CHAR(5);
DEFINE cCodret2 			CHAR(5);
DEFINE dFecha 				DATE;
DEFINE iSignumcte 			INT;
DEFINE cExiste 			CHAR(1);
DEFINE cEmpresa 			CHAR(3);
DEFINE cNumcte 			CHAR(20);
DEFINE cSucursal 			CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE cEjecut_autoriza 	CHAR(8);
DEFINE cTp_persona 		CHAR (2);
DEFINE cTp_cliente 		CHAR(1);
DEFINE cPaterno 			CHAR(26);
DEFINE cMaterno 			CHAR(26);
DEFINE cNombre1 			CHAR(26);
DEFINE cNombre2 			CHAR(26);
DEFINE cRfc 				CHAR(13);
DEFINE cSector 			CHAR(2);
DEFINE cSegmento 			CHAR(3);
DEFINE cAtividad_princ 	CHAR(3);
DEFINE cGrupo 				CHAR(3);
DEFINE cSubgrupo 			CHAR(3);
DEFINE cResidencia 		CHAR(1);
DEFINE cApell_casada 		CHAR(20);
DEFINE cNumcte_referencia	CHAR(20);
DEFINE cDistrito 			CHAR(2);
DEFINE cPuesto_ppes 		CHAR(1);
DEFINE cFamiliar_ppes 		CHAR(1);
DEFINE cActividad_esp 		CHAR(11);
DEFINE dFecha_nac 			DATE;
DEFINE cLugar_nac 			CHAR(2);
DEFINE cNacionalidad 		CHAR(3);
DEFINE cFm3 				CHAR(18);
DEFINE cEstado_civil 		CHAR(1);
DEFINE cRegimen_mat 		CHAR(1);
DEFINE cProfesion 			CHAR (3);
DEFINE cSexo 				CHAR(1);
DEFINE cCurp 				CHAR(20);
DEFINE cCodidentif 		CHAR(2);
DEFINE cNumidentif 		CHAR(20);
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
DEFINE cStatus_cte 		CHAR(2);
DEFINE dFecha_alta 		DATE;
DEFINE cRazon_soc 			CHAR(40);
DEFINE sDiferencia			SMALLINT;
DEFINE sI 					SMALLINT;
DEFINE cNumcte_ref 		CHAR(20);
DEFINE cNumhabitantes 		CHAR(60);
DEFINE cSucursalCajaUnica 	CHAR(1);
DEFINE iOrigen 			INTEGER;
DEFINE cTipoRel 			CHAR(1);
DEFINE cCodRet3            CHAR(6);
DEFINE cMensajeRet         CHAR(80);

-- Valida referencia Coppel
DEFINE v_codret_cc         CHAR(5);
DEFINE v_result_cc			CHAR(1);
-- Valida referencia Coppel
--variable para guardar resultado de consulta
DEFINE nRes					INTEGER;
DEFINE nRes2				INTEGER;

DEFINE mCURP                CHAR(30);
DEFINE mCORREO              CHAR(30);
DEFINE mIDENTIF             CHAR(30);

LET mCURP='';
LET mCORREO='';
LET mIDENTIF='';


LET nRes 				=0;
LET nRes2 				=0;
LET cCodret 			= "000";
LET cCodret2 			= '000';
LET cEmpresa 			= pEmpresa;
LET cNumcte 			= " ";
LET cSucursal 			= pSucursal;
LET cTppersona 			= pTp_persona;
LET cNumcte_ref 		= " ";
LET cEjecut_autoriza 	= pEjecut_autoriza;
LET iOrigen 			= 0;
LET cTipoRel			='0';
LET cCodRet3            = "00000";
LET cMensajeRet         = "Se realizÃ³ la consulta correctamente";


LET v_codret_cc      = "00000";
LET v_result_cc		= '';



BEGIN
ON EXCEPTION SET iSqlerr,iIsamerr
	IF iSqlerr != 0 THEN
		LET cCodret=iSqlerr;
		RETURN cCodret,cNumcte;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/ctefisico_opt.out";
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
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT es_fisica
              INTO cEsfisica
              FROM bdinteg:"informix".si_tipper
             WHERE tpo_persona = cTppersona;

            IF UPPER(cEsfisica) != "S" THEN
                LET cCodret = "120";
                RETURN cCodret,cNumcte;
            END IF;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicheq:"informix".sc_maechq
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdisolic:"informix".ss_solicitudes
         WHERE empresa="001"
           AND numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
            RETURN cCodret,cNumcte;
        END IF

        SELECT COUNT(*)
          INTO sCont
          FROM bdinvers:"informix".sv_maeinv
         WHERE numcte = pNumcte;

        IF sCont > 0 THEN
            LET cCodret = "121";
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

       /*
         OBTENEMOS CURP Y NUMERO DE IDENTIFICACION Y CORREO PARA NO ACTUALIZARLOS
       */
        SELECT LIMIT 1 CURP, NUMIDENTIFI INTO mCURP, mIDENTIF FROM SI_CTEPF WHERE NUMCTE=cNumcte;
        SELECT limit 1 CORREO_ELEC INTO mCORREO FROM SI_CORREOS WHERE NUMCTE=cNumcte AND STATUS_CORREO='A';


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
            LET cCodret = "104";
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

        IF pCurp IS NULL OR pCurp = "" THEN
            LET pCurp=mCURP;
        END IF;

        IF pNumidentif IS NULL OR pNumidentif = "" THEN
            LET pNumidentif=mIDENTIF;
        END IF;

        IF pEmail IS NULL OR pEmail = "" THEN
            LET pEmail=mCORREO;
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

		IF(pCurp <> '') THEN
		
			IF SUBSTRING(cRfc FROM 1 FOR 10) <> SUBSTRING(pCurp FROM 1 FOR 10) THEN
					INSERT INTO bdinteg:"informix".si_bitacora_cambio_curp
					( numcte, rfc, curp, resultado, fecha )
					VALUES
					( pNumcte, cRfc, pCurp, '03', CURRENT );

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

	IF NVL(pFuncion,'') = "S" THEN
		IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'') = '' OR NVL(pEscolaridad,'') = '' THEN
				LET cCodret = "200";
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
					LET cCodret = "220";
					RETURN cCodret,cNumcte;
			   END IF
			ELSE
				LET cCodret = "210";
				RETURN cCodret,cNumcte;
		   END IF
		END IF;
	END IF

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
        LET cCodret = "110";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT es_fisica
      INTO cEsfisica
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = pTp_persona;

    IF UPPER(cEsfisica) != "S" THEN
        LET cCodret = "120";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal=pSucursal;

    IF cExiste IS NULL THEN
        LET cCodret = "111";
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
            LET cCodret = "112";
            RETURN cCodret,cNumcte;
        END IF;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector=pSector;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_segment
     WHERE segmento=pSegmento;

    IF cExiste IS NULL THEN
        LET cCodret = "114";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_grupos
     WHERE grupo=pGrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "115";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_subgpos
     WHERE subgrupo=pSubgrupo;

    IF cExiste IS NULL THEN
        LET cCodret = "116";
        RETURN cCodret,cNumcte;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_nacion
     WHERE nacion=pNacionalidad;

    LET pRfc = TRIM(pRfc);

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_cliente
     WHERE rfc = pRfc;

    IF NOT cExiste IS NULL AND pFuncion = "A" THEN
        LET cCodret = "106";
        RETURN cCodret,cNumcte;
    END IF

    IF TRIM(pCodidentif) <> "" THEN
        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_tipoidentif
         WHERE codidentif = pCodidentif;

        IF cExiste IS NULL THEN
            LET cCodret = "133";
            RETURN cCodret,cNumcte;
        END IF
    END IF;

    IF pTp_cliente = "M" THEN ---MenOR de edad
        IF pTutor IS NULL OR pTutor = "" THEN
            LET cCodret = "144";
            RETURN cCodret,cNumcte;
        END IF

        SELECT 1
          INTO cExiste
          FROM bdinteg:"informix".si_cliente
         WHERE numcte = pTutor;

        IF cExiste IS NULL THEN
            LET cCodret = "145";
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
            LET cCodret = "105";
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
            LET cCodret = "118";
            RETURN cCodret, cNumcte;
        END IF;

        IF NVL(pNumcte_ref,'') <> '' THEN
-- Valida referencia Coppel 
            EXECUTE PROCEDURE bdinteg:"informix".sp_cons_ref_cop(pEmpresa, pSucursal, pEjecutivo, cNumcte, pNumcte_ref, pPaterno, pMaterno, pNombre1 ,pNombre2, pRfc)
                         INTO v_codret_cc, v_result_cc;

            IF ( v_result_cc = '1' ) THEN
                LET pNumcte_ref = '';
            END IF;
         END IF;
-- Valida referencia Coppel

		SELECT 1
			INTO cExiste
		FROM bdinteg:"informix".si_cliente
		WHERE rfc = pRfc;

		IF NOT cExiste IS NULL AND pFuncion = "A" THEN
			LET cCodret = "106";
			RETURN cCodret,cNumcte;
		END IF

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

        IF NVL(pNumcte_ref,"") <> "" THEN ---Se realiza validacion para relacionar al cliente Bancoppel con un Cliente Coppel
			LET iOrigen = 2; 
			LET cTipoRel ='1';
		END IF;		--Se agrega llamado para crear relacion de clientes bancoppel-coppel.

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
            LET cCodret = "104";
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

        UPDATE bdinteg:"informix".si_cliente
           SET ( ejecutivo, tpo_persona, tipo_cliente,
                 sectOR, segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2) = 
               ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
                 pSector, pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes)
        WHERE numcte = cNumcte;
		
		UPDATE bdinteg:"informix".si_ctepf
		   SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
				 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
				 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, sms_cel, id_pais) = 
			   ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
				 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
				 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, '0', pIdPais)
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
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para la generacion del numero de cliente banco.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".ctefisico_val_cor_opt(pEmpresa CHAR(3),pFuncion CHAR(1),pNumcte CHAR(20),pSucursal CHAR(4),pEjecutivo CHAR(8),pTp_persona CHAR(2),pTp_cliente CHAR(1),pPaterno CHAR(26),pMaterno CHAR(26),pNombre1 CHAR(26),pNombre2 CHAR(26),pRfc CHAR(13),pSector CHAR(2),pSegmento CHAR(3),pActividad_princ CHAR(3),pGrupo CHAR(3),pSubgrupo CHAR(3),pResidencia CHAR(1),pApell_casada CHAR(20),pNumcte_ref CHAR(20),pDistrito CHAR(2),pPuesto_ppes CHAR(1),pFamiliar_ppes CHAR(1),pActividad_esp CHAR(11),pFecha_nac DATE, pLugar_nac CHAR(2),pNacionalidad CHAR(3),pFm3 CHAR(18),pEstado_civil CHAR(1),pRegimen_mat CHAR(1),pProfesion CHAR(3),pSexo CHAR(1),pCurp CHAR(20),pCodidentif CHAR(2),pNumidentif CHAR(30),pNo_imss CHAR(12),pDependientes SMALLINT,pTutor CHAR(60),pEmail CHAR(60),pNom_conyuge CHAR(60),pSeguro_defunc CHAR(1),pEscolaridad CHAR(2),pHabita_en CHAR(20),pAnios_habita SMALLINT,pNombre_prop CHAR(60),pImphiporenta MONEY(14,2),pNumeroife CHAR(20),pNumerotutor CHAR(20),pNumeroconyuge CHAR(20),pEjecut_autoriza CHAR(8),pPromocion CHAR(2),pNumhabitantes CHAR(60),pStatusCode CHAR(3), pIdPais CHAR(3))
RETURNING  CHAR(5) AS Codret,  CHAR(20) AS Numcte;

DEFINE cCodret CHAR(5);
DEFINE cCodret2 CHAR(5);
DEFINE cNumcte CHAR(20);
DEFINE iSqlerr INTEGER;
DEFINE iIsamerr INTEGER;

LET cCodret = "000";
LET cCodret2 = '000';
LET cNumcte = " ";

BEGIN
	ON EXCEPTION SET iSqlerr,iIsamerr
		IF iSqlerr != 0 THEN
			LET cCodret=iSqlerr;
			RETURN cCodret,cNumcte;
		END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO '/tmp/ctefisico_val_cor_opt.out';
	 --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

	--Se le agrega parametro id_pais para invocar el SP pIdPais
	EXECUTE PROCEDURE bdinteg:"informix".ctefisico_opt (pEmpresa,pFuncion,pNumcte,pSucursal,pEjecutivo,pTp_persona,pTp_cliente,pPaterno,pMaterno,pNombre1,pNombre2 ,pRfc ,pSector,pSegmento,pActividad_princ,pGrupo,pSubgrupo,pResidencia,pApell_casada,pNumcte_ref,pDistrito,pPuesto_ppes,pFamiliar_ppes,pActividad_esp,pFecha_nac, pLugar_nac ,pNacionalidad,pFm3,pEstado_civil,pRegimen_mat,pProfesion,pSexo,pCurp,pCodidentif,pNumidentif,pNo_imss,pDependientes,pTutor,'',pNom_conyuge ,pSeguro_defunc ,pEscolaridad,pHabita_en,pAnios_habita,pNombre_prop,pImphiporenta,pNumeroife,pNumerotutor,pNumeroconyuge,pEjecut_autoriza,pPromocion,pNumhabitantes, pIdPais)
	INTO cCodret,cNumcte;
	
	IF pEmail IS NOT NULL OR pEmail <> '' THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos_valcor (pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo,pStatusCode)
		INTO cCodret2;
	END IF
		
	RETURN cCodret, cNumcte;
END;    
END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para la generacion del numero de cliente banco.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".sp_obtiene_ctecurp( pRfc CHAR(13))

RETURNING CHAR(5) AS codret , 
	      CHAR(9) AS numcte,
		  CHAR (18) AS curp,
		  CHAR (1) AS validacurp;

DEFINE vCodret CHAR (5);
DEFINE vNumcte CHAR (20);
DEFINE vCurp 	CHAR (18);
DEFINE vValidaCurp CHAR(1);
DEFINE vSql_err INTEGER;  

LET vCodret  = '00000';
LET vNumcte  = '';
LET vCurp		= '';
LET vValidaCurp = '';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret, vNumcte, vCurp, vValidaCurp;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_obtiene_ctecurp.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF pRfc is null or pRfc ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret, vNumcte, vCurp, vValidaCurp;
     END IF;
	 
	SELECT numcte, curp, validacurp INTO vNumcte, vCurp, vValidaCurp
	FROM bdinteg:"informix".si_ctepf 
	WHERE numcte = (SELECT numcte 
    FROM bdinteg:"informix".si_cliente 
    WHERE rfc = pRfc);
 
    LET vNumcte = NVL(vNumcte,'');
	LET vCurp = NVL(vCurp,'');
	LET vValidaCurp = NVL (vValidaCurp,'');

     RETURN vCodret, TRIM(vNumcte), TRIM(vCurp), TRIM(vValidaCurp);
 END;
END PROCEDURE
DOCUMENT
"Folio:			868",
"Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4",
"Autor: 		98440021 - Veronica Rodriguez",
"Fecha: 		29/11/2022",
"Solicita:		Fernando Rojas",
"Descripcion:   Se crea sp para obtener la curp del cliente cuando ya exista en BD.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".sp_recuperarcurp(
    cEmpresa    CHAR(3),
    cNumCte     CHAR(20))

RETURNING   CHAR(5) AS cCodRet,
			CHAR(20) AS cCurp;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vCurp CHAR(20);

    LET vCodRet	= '00000';
    LET iSqlErr = 0;
    LET vCurp	= '';


    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN  vCodRet, vCurp;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarCurp.err";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vCurp;
        END IF;
        
        --EL JOIN ES PARA VALIDAR QUE EL CLIENTE EXISTA
        SELECT
            Nvl(curp, '')
        INTO vCurp
        FROM bdinteg:"informix".si_ctepf pf
        INNER JOIN si_cliente c ON c.numcte = pf.numcte
        WHERE pf.numcte = cNumCte AND pf.empresa = cEmpresa;
    
        RETURN vCodRet, vCurp;
        
    END;
        
END PROCEDURE

DOCUMENT
'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de curp con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperardatoscontacto(
	cEmpresa     CHAR(3),
	cNumCte      CHAR(20))
	
RETURNING   CHAR(5)   AS cCodRet,
            CHAR(100) AS cCorreoElectronico,
            CHAR(10)  AS cTelefonoCasa,
            CHAR(10)  AS cTelefonoCelular;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vCorreoElectronico CHAR(100);
    DEFINE vTelefonoCasa CHAR(10);
    DEFINE vTelefonoCelular CHAR(10);
    DEFINE vNumCteProspecto	CHAR(20);
    
    LET iSqlErr = 0;
    LET vCodRet	= '00000';
    LET vCorreoElectronico = '';
    LET vTelefonoCasa = '';
    LET vTelefonoCelular = '';
    LET vNumCteProspecto = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vCorreoElectronico, vTelefonoCasa, vTelefonoCelular;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarDatosContacto.err";
        --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vCorreoElectronico, vTelefonoCasa, vTelefonoCelular;
        END IF; 

        SELECT
            NVL(correo_elec, '')
        INTO vCorreoElectronico
        FROM bdinteg:"informix".si_correos
        WHERE numcte = cNumCte
            AND status_correo = 'A'
            AND empresa = cEmpresa;

        SELECT
            NVL(telefono,'')
        INTO vTelefonoCasa
        FROM bdinteg:"informix".si_telefonos_actual
        WHERE numcte = cNumCte
            AND tipo_tel = 1 --telefono_tipo_casa
            AND status_tel = 'A'
            AND empresa = cEmpresa;

        SELECT
            NVL(telefono, '')
        INTO vTelefonoCelular
        FROM bdinteg:"informix".si_telefonos_actual
        WHERE numcte = cNumCte
            AND tipo_tel = 2 --telefono_tipo_casa
            AND status_tel = 'A'
            AND empresa = cEmpresa;

        --Antes de este punto consulta datos del cliente por si tiene guardados
        IF
            (vTelefonoCasa IS NULL OR len(vTelefonoCasa) = 0)
            and (vTelefonoCelular IS NULL OR len(vTelefonoCelular) = 0)
        THEN
		
            --si los telefonos son vacios no has capturado informaciÃ³n, reviso si capturaste datos como prospecto
            SELECT numcte_pros
            INTO vNumCteProspecto
            FROM bdiprospectos: "informix".pr_cliente
            WHERE numcte = cNumCte
                AND empresa = cEmpresa;
    
            --consulta datos del prospecto
            IF vNumCteProspecto IS NULL OR vNumCteProspecto = '' THEN
                --nada, regresamos datos vacios porque es cliente nuevo
            ELSE
                --consultalos y traemelos
                SELECT NVL(telefono,'')
                INTO vTelefonoCasa
                FROM bdiprospectos:"informix".pr_telefonos
                WHERE numcte_pros = vNumCteProspecto
                    AND tipo_tel = 1
                    AND status_tel = 'A'
                    AND secuencia = (
                        SELECT
                        MAX(secuencia)
                        FROM bdiprospectos:"informix".pr_telefonos
                        WHERE numcte_pros = vNumCteProspecto
                            AND tipo_tel = 1);
    
                SELECT NVL(telefono,'')
                INTO vTelefonoCelular
                FROM bdiprospectos:"informix".pr_telefonos
                WHERE numcte_pros = vNumCteProspecto
                AND tipo_tel = 2
                AND status_tel = 'A'
                AND secuencia = (
                    SELECT
                    MAX(secuencia)
                    FROM bdiprospectos:"informix".pr_telefonos
                    WHERE numcte_pros = vNumCteProspecto
                        AND tipo_tel = 2);
    
                SELECT
                    NVL(correo_elec, '')
                INTO vCorreoElectronico 
                FROM bdiprospectos:"informix".pr_correos
                WHERE numcte_pros = vNumCteProspecto;
            END IF
        END IF
	
	    RETURN vCodRet, NVL(vCorreoElectronico,''), NVL(vTelefonoCasa,''), NVL(vTelefonoCelular,'');
	
	END;
    
END PROCEDURE
	DOCUMENT
	'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
	'Descripcion: CreaciÃ³n de procedure para obtener datos del cliente',
	'AUTOR: 98021080 - Hiram Ramirez',
	'Fecha: 17/10/2022',
	'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperardatosgenerales(
    cEmpresa CHAR(3),
    cNumcte CHAR(20))

RETURNING   CHAR(5)   AS cCodRet,
            SMALLINT  AS iSubActividad,
            SMALLINT  AS iActividad,
            CHAR(120) AS cDescripcionActividad,
            CHAR(1)   AS cTipoHabitacion;

    DEFINE vCodret                  CHAR(5);
    DEFINE iSqlerr                  INTEGER;
    DEFINE vSecuencia               SMALLINT;
    DEFINE vSubActividad            SMALLINT;
    DEFINE vActividad               SMALLINT;
    DEFINE vDescripcionActividad    CHAR(120);
    DEFINE vTipoHabitacion          CHAR(1);
    DEFINE vNumCteProspecto         CHAR(20);

    LET vCodRet = '00000';
    LET iSqlerr = 0;
    LET vSecuencia = 0;
    LET vSubActividad = 0;
    LET vActividad = 0;
    LET vDescripcionActividad = '';
    LET vTipoHabitacion = '';
    LET vNumCteProspecto = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vSubActividad, vActividad, vDescripcionActividad, vTipoHabitacion;
            END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/anj/recuperarDatosGenerales.sql";
		--TRACE ON;
    
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
        
        SELECT MAX(sec_ingreso)
        INTO vSecuencia
        FROM bdinteg:"informix".si_ingresos
        WHERE empresa = cEmpresa
            AND numcte = cNumcte;

        SELECT
            ing.claveopcionpuesto, ing.clavesubopcionpuesto, act.descrip
        INTO
            vActividad, vSubActividad, vDescripcionActividad
        FROM bdinteg:"informix".si_ingresos ing
        LEFT JOIN bdinteg:"informix".si_actsubact act ON act.id_act = ing.claveopcionpuesto AND act.id_subact = ing.clavesubopcionpuesto
        WHERE ing.empresa = cEmpresa
            AND ing.numcte = cNumcte
            AND ing.sec_ingreso = vSecuencia;
    
        SELECT
            habita_en
        INTO vTipoHabitacion
        FROM bdinteg:informix.si_ctepf
        WHERE empresa = cEmpresa
            AND numcte = cNumcte;
    
        --Antes de este punto consulta datos del cliente por si tiene guardados
        IF vTipoHabitacion IS NULL OR len(vTipoHabitacion) = 0 THEN
            
            SELECT numcte_pros
            INTO vNumCteProspecto
            FROM bdiprospectos:"informix".pr_cliente
            WHERE numcte = cNumcte
                AND empresa = cEmpresa;
    
            --consulta datos del prospecto
            IF vNumCteProspecto IS NULL OR vNumCteProspecto = '' THEN
                --nada, regresamos datos vacios porque es cliente nuevo
            ELSE
                --consultalos y traemelos
                SELECT
                    claveopcionpuesto, clavesubopcionpuesto
                INTO vActividad, vSubActividad
                FROM bdiprospectos:"informix".pr_ingresos
                WHERE numcte_pros = vNumCteProspecto
                    AND empresa = cEmpresa;
    
                IF vActividad IS NOT NULL AND vSubActividad IS NOT NULL THEN
                    SELECT act.descrip
                    INTO vDescripcionActividad
                    FROM bdinteg:"informix".si_actsubact act
                    WHERE act.id_act = vActividad
                        AND act.id_subact = vSubActividad;
                END IF
    
                --tipo_habitacion
                SELECT
                    habita_en
                INTO vTipoHabitacion
                FROM bdiprospectos:"informix".pr_ctepf
                WHERE numcte_pros = vNumCteProspecto
                    AND empresa = cEmpresa;
                
            END IF
            
        END IF;
    
        RETURN vCodRet, NVL(vSubActividad,''), NVL(vActividad,''), NVL(vDescripcionActividad,''), NVL(vTipoHabitacion,'');
    
    END;

END PROCEDURE
DOCUMENT
'FOLIO: RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de datos generales con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_recuperartipocliente(
	cEmpresa     CHAR(3),
	cNumCte      CHAR(20))
	
RETURNING 	CHAR(5) AS cCodRet,
			CHAR(1) AS cTipoCliente;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE vTipoCliente CHAR(1);
    
    LET iSqlErr = 0;
    LET vCodRet	= '00000';
    LET vTipoCliente = '';

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet, vTipoCliente;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO "/resplogifx/conciliachq/recuperarTipoCliente.err";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF cNumCte is null or cNumCte = "" OR Len(cNumCte) = 0 OR cEmpresa is null or cEmpresa = "" OR Len(cEmpresa) = 0 THEN 
            LET vCodret = '00002' ; -- FALTA PARAMETRO DE ENTRADA
            RETURN vCodRet, vTipoCliente;
        END IF; 
        
        SELECT
            tipo_cliente
        INTO vTipoCliente
        FROM bdinteg:"informix".si_cliente
        WHERE numcte = cNumCte
            AND empresa = cEmpresa;    
    
        RETURN vCodRet, NVL(vTipoCliente,'');
	
	END;
    
END PROCEDURE
DOCUMENT
'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Descripcion: CreaciÃ³n de procedure para la recuperaciÃ³n de tipo de cliente con base en numero de cliente',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/11/2022',
'BDD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_autorizaciones_hcbopt
		(pEmpresa       CHAR (3),
		 pCliente       CHAR (10), 
		 pSucursal      CHAR (4),
		 pOperador      CHAR (10),
		 pMensajeAviso  VARCHAR (200),
		 pSic           CHAR (1),
		 pAviso         CHAR (1),
		 pINE           CHAR(1), 
		 pGrupoCoppel   CHAR (1),
		 pEdoCta        CHAR (1))

		RETURNING       CHAR (5);
		--***************************************************************************************************************
		--*                                    DEFINICION DE VARIABLES                                                  *
		--***************************************************************************************************************

		DEFINE Cod_ret                CHAR(5);
		DEFINE iSqlErr                INTEGER;
		DEFINE aviso_Aut              CHAR(3);
		DEFINE aut_Coppel             CHAR(3);
		DEFINE aut_Sic                CHAR(5);
		DEFINE secuencia              SMALLINT;
		DEFINE aut_EdoCta             CHAR(5);
		DEFINE stat_edoCta            CHAR(1);
		DEFINE existeAutorizadoAviso INTEGER;

		--***************************************************************************************************************
		--*                                    ASIGNACION DE VARIABLES                                                  *
		--***************************************************************************************************************

		LET Cod_ret                   = "00000";
		LET iSqlErr                   = 0;

		LET aviso_Aut                 = '0';
		LET aut_Coppel                = '0';
		LET aut_Sic                   = '0';
		LET secuencia                 = '0';
		LET aut_EdoCta                = '0';
		LET stat_edoCta               = '0';
		LET existeAutorizadoAviso     = 0;

		--***************************************************************************************************************
		--*                                    CONTROL DE ERRORES                                                       *
		--***************************************************************************************************************

		BEGIN
			ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET Cod_ret = iSqlErr;
				RETURN Cod_ret;
			END IF ;
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/sysifx/sp_registra_autorizaciones_hcbopt.out";
			--TRACE ON;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			--***********************************************************************************************************
			--*                                PROGRAMA PRINCIPAL                                                       *
			--***********************************************************************************************************

			IF NVL(pCliente, '') <> "" THEN
				
				--** aviso de privacidad
				IF pAviso = '1' THEN
					
						SELECT count(numcte) into existeAutorizadoAviso 
						FROM bdinteg:"informix".si_autorizacion_privacidad 
						WHERE empresa = pEmpresa AND numcte = pCliente AND respuesta = '1';
					
					IF existeAutorizadoAviso = 0 then
						
						CALL bdinteg:"informix".sp_insert_autor_privacidad(pEmpresa, pCliente,pSucursal,pAviso,pMensajeAviso) RETURNING aviso_Aut;

						IF NVL(aviso_Aut, '') <> "000" THEN
							LET Cod_ret = "00001";
							RETURN  Cod_ret;
						END IF;
					 ELSE
						   LET Cod_ret = "00000";
					 END IF;

				END IF;

				--** Compartir datos con coppel
				IF pGrupoCoppel = '1' THEN
					CALL bdinteg:"informix".sp_autoriza_datos_contacto(pCliente, pOperador, pSucursal, '1', '1', pGrupoCoppel, 2) RETURNING aut_Coppel;
					
					IF NVL(aut_Coppel, '') <> "000" THEN
						LET Cod_ret = "00001";
						RETURN Cod_ret;
					END IF;
				END IF;

				--** autorizacion envio de cuenta por medios electronicos
				IF pEdoCta = '1' THEN
					CALL bdinteg:"informix".sp_registro_aut_envio_edocta(pCliente, pSucursal, pOperador, pEdoCta,"","") RETURNING  aut_EdoCta, stat_edoCta;
				END IF;

			END IF;
			RETURN Cod_ret;
		END;
	END PROCEDURE
	DOCUMENT
	'----------------------------------------------------------------------------',
	'--Autor: Alberto Sanchez',
	'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
	'--Fecha: 26/09/2022.',
	'--Solicita:', 
	'--Descripcion: Se crea procedimiento almacenado para registrar diferentes tablas',
	'--las autorizaciones que selecciono el cliente',
	'--BD: bdinteg.',
	'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cons_datos_contacto(pcliente CHAR(9))
   RETURNING CHAR(3);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE sExiste CHAR(9);

LET iSqlErr = 0;
LET cCodRet = '';
LET sExiste='';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;
        --let pcliente=pcliente;
        select count(numcte) INTO sExiste  from si_autoriza_datos_contacto where numcte=pcliente and flag='1';
  
        IF sExiste='0' THEN
           LET cCodRet = '000'; --Muestra la pregunta en OFI
        ELSE
           LET cCodRet = '001'; --Cte ya respondiÃ³, no muestra la pregunta
        END IF          

RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Folio:			868',
'Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4',
'Autor: 		98440021 - Veronica Rodriguez',
'Fecha: 		29/11/2022',
'Solicita:		Fernando Rojas',
'Descripcion:   Consulta autorizaciones de contacto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_generareplica_catdomssuc()

 returning char(5);

define v_codret        	char(5);
define v_sqlerr        	integer;
define v_isamerr       	integer;
define vdia            	date;
define vhora           	char(8);
define cMensaje        	char(80);
define pUsuario        	char(8);
define pEmpresa        	char(3);
define vtexto_select    char(1000);
define vPath           	char(50);
define cCadena         	char(2500); 
define cCadenadb2       char(2500); 
define vNomarch        	char(80);
define vNomarchdb2     	char(30);
define vfecha_hoy      	char(8);
define vLargoCadena    	integer;
--define vConteo         	smallint;
define vConteo         	integer;
define vfecha_hoy2     	date;
define vf_ultinsercion 	date;
define vf_ultactualiza 	date;
define vCatalogo      	char(20);
define vEjecutarProceso char(1);
define cUPD           	char(1);
define cINS           	char(1);

define i_numerociudad		integer;
define i_numerocolonia		integer;
define c_nombrezona		    char(32);
define c_poblacionzona		char(27);
define c_municipiozona		char(27);
define i_codigopostalzona	integer;
define c_planozona		    char(7);
define c_rumbozona		    char(42);
define i_supervisorzona		integer;
define i_choferzona		    integer; 
define i_jefegrupozona		integer;
define i_gerentezona		integer;
define i_abogadozona		integer;
define c_marcaencuesta30dias char(3);
define i_numerocalle		integer;
define i_numerocasa		    integer;
define c_marcaunidadhabitacional char(3);
define i_numerodivisioncobranzas integer;
define i_claveabogado		integer;
define i_ciudadcobranzas	integer;
define i_numerocobranzas	integer;
define c_clavearagon		char(3);
define i_centro		        integer;
define i_pais               integer;
define i_estado             integer;
define i_ciudad             integer;
define c_nombreciudad       char(50);
define i_numerociudad_2     integer;
define c_localidad          char(8);
define i_tipociudad         integer;
define dFecha_hoy           date;
define cUsr_modifica        char(10);
define iExiste_col          integer;
define iExiste_cd           integer;
define vEjecuta_omnicanal   char(1);
define vPath_ominicanal     char(50);
define vSeparador           char(1);
define cCadena_omni    	char(3500); 

let v_codret            = "00000";
let v_sqlerr            = 0;
let v_isamerr           = 0; 
let vdia                = '01-01-1900';
let vhora               = "";
let cMensaje            = 'PROCESO EXITOSO';
let pUsuario            = user;
let pEmpresa            = '001';
let vtexto_select       = "";
let vPath               = ""; 
let cCadena             = "";
let cCadenadb2          = "";
let vNomarch            = "";
let vNomarchdb2         = "";
let vfecha_hoy          = "";
let vLargoCadena        = 0;
let vConteo             = 0;
let vfecha_hoy2         = '01-01-1900';
let vf_ultinsercion     = '01-01-1900';
let vCatalogo           = "";
let vf_ultactualiza     = '01-01-1900';
let vEjecutarProceso    = '';
let cUPD                = 'U';
let cINS                = 'I';

let i_numerociudad		= 0;
let i_numerocolonia		= 0;
let c_nombrezona		= '';
let c_poblacionzona		= '';
let c_municipiozona		= '';
let i_codigopostalzona	= 0;
let c_planozona		    = '';
let c_rumbozona		    = '';
let i_supervisorzona	= 0;
let i_choferzona		= 0;
let i_jefegrupozona		= 0;
let i_gerentezona		= 0;
let i_abogadozona		= 0;
let c_marcaencuesta30dias = '';
let i_numerocalle		= 0;
let i_numerocasa		= 0;
let c_marcaunidadhabitacional = '';
let i_numerodivisioncobranzas = 0;
let i_claveabogado		= 0;
let i_ciudadcobranzas	= 0;
let i_numerocobranzas	= 0;
let c_clavearagon		= '';
let i_centro		    = 0;
 
let i_pais               = 0;
let i_estado             = 0;
let i_ciudad             = 0;
let c_nombreciudad       = ''; 
let i_numerociudad_2     = 0;
let c_localidad          = ''; 
let i_tipociudad         = 0;
let dFecha_hoy           = date(1);
let cUsr_modifica        = '';
let iExiste_col          = 0;
let iExiste_cd           = 0;
let vEjecuta_omnicanal   = '';
let vPath_ominicanal     = '';
let vSeparador           = '|';
let cCadena_omni         = '';  

  --SET DEBUG FILE TO "/ifxsif01/macf/generareplica_catdomssuc.out";
  --TRACE ON;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;

	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
        VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, 'ERROR', 0, pUsuario, vdia, vhora);

         return v_codret;

	 end if;
      

      
   end exception;
   
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
   select valor into vEjecutarProceso
     from bdinteg:si_param_dom
    where empresa = pEmpresa and cod_param = 25;
   
   if vEjecutarProceso = 'S' then 
       --Generales 
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
    
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', '11111', 'PROCESO INICIALIZADO', 0, pUsuario, vdia, vhora);
    
       select valor into vPath 
         from bdinteg:si_param_dom 
        where empresa = pEmpresa and cod_param = 24;
    
        --select fecha_hoy into vfecha_hoy2 from bdinteg:si_fechas;
        --select to_char(fecha_hoy, "%Y%m%d") into vfecha_hoy 
        --  from bdinteg:si_fechas;

        SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d"), DBINFO('utc_to_datetime', sh_curtime)::DATE
		INTO vfecha_hoy, dFecha_hoy
        from sysmaster:sysshmvals;
        
		--LET dFecha_hoy = MDY('02','08','2023');  --- SOLO TEST MACF
		--LET vfecha_hoy = '20230208';  --- SOLO TEST MACF
		
        ---- INICIO INSERTS SI_CATZONAS
        let vCatalogo  	= 'si_catzonas';
        let vNomarch 	= 'ins_catzonas_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catzonas_db2_' || vfecha_hoy;

        select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
         where catalogo = vCatalogo
           and tipo_operacion = cINS;
    
        --let vtexto_catzonas = to_char(vf_ultins_catzonas) || ' - ' ||to_char(vf_ultins_ciudades) || ' - ' ||vNomarch;
        --insert into si_bitacora_dom  (mensaje, user_insert, fecha_insert) values(vf_ultins_catzonas, pUsuario, vdia);
    
        foreach with hold
          SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechains)} 'INSERT INTO public.catzonas values(' ||
                  numerociudad || "," || numerocolonia || ",'" || trim(replace(replace(nombrezona,'"',''''),"'", "")) ||  "','" || nvl(trim(replace(poblacionzona,"'", "")), '')  || "','"  || 
                  nvl(trim(replace(municipiozona,"'", "")), '')  || "'," || nvl(codigopostalzona, 0) || ",'" || nvl(planozona, '') || "','" || 
                  nvl(trim(rumbozona),'') || "'," || nvl(supervisorzona,0) || "," || nvl(choferzona,0) || "," || 
                  nvl(jefegrupozona,0) || "," || nvl(gerentezona,0) || "," || nvl(abogadozona,0) || ",'" || nvl(marcaencuesta30dias, '') 
                  || "'," || nvl(numerocalle, 0) || "," || nvl(numerocasa, 0) || ",'" || nvl(marcaunidadhabitacional, '') || 
                  "'," || nvl(numerodivisioncobranzas,0) || "," || nvl(claveabogado,0) || "," || nvl(ciudadcobranzas,0) || "," || 
                  --nvl(numerocobranzas,0) || ",'" || nvl(clavearagon, '') || "'," || nvl(centro, 0) || ');',
				  nvl(numerocobranzas,0) || ",'" || 1 || "'," || nvl(centro, 0) || ');',
                  numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para inserciÃÂ³n (23 campos)
				  nvl(trim(replace(poblacionzona,"'", '')), ''), 
				  nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				  nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				  nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				  nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				  nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				  --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
				  nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  

				  INTO vtexto_select,
				  i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				  c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				  i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				  i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica		 				  
			  
          FROM bdinteg:si_catzonas
          WHERE f_inserta >= vf_ultinsercion
            AND usr_modifica <> 'SYSCARTERA'
	        AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
     if nvl(vtexto_select, '') <> '' then
		    let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
				  System cCadena;
				  let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
				elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
				 System cCadena;
				 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				 System cCadenadb2;
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
				
				select count(*) into iExiste_col
				  from bdinteg:si_catzonas_suc
				  where numerociudad = i_numerociudad and numerocolonia = i_numerocolonia;
				  
				
				if iExiste_col <= 0 then
					begin; 
					  insert into bdinteg:si_catzonas_suc(numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, planozona, 
						rumbozona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona, marcaencuesta30dias, numerocalle, numerocasa, 
						marcaunidadhabitacional, numerodivisioncobranzas, claveabogado, ciudadcobranzas, numerocobranzas, clavearagon, centro, f_inserta,
						usr_modifica) 
					  values(i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
							 c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
							 i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
							 i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, dFecha_hoy, 
							 cUsr_modifica);
				   commit; 
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
          else
              exit foreach;
          end if;
		  
		   
		
    
        end foreach;
				
        if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
        end if;   ----  FIN INSERTS SI_CATZONAS


       ---- INICIO UPDATES SI_CATZONAS
       let vCatalogo  	= 'si_catzonas';
       let vNomarch 	= 'upd_catzonas_' || vfecha_hoy;   
	   let vNomarchdb2 	= 'upd_catzonas_db2_' || vfecha_hoy;   
       let vConteo = 0;
       let vLargoCadena = 0;  --- temporary 
       let vtexto_select = '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
       
       foreach with hold
            SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechamodif)} 'UPDATE public.catzonas SET nombrezona =''' || trim(replace(replace(nombrezona,'"',''''),"'", "")) || '''' || ', poblacionzona = ''' || 
                    nvl(trim(replace(poblacionzona,"'", "")), '') || "'" || ', municipiozona = ''' || nvl(trim(replace(municipiozona,"'", "")), '') || "'" || ', codigopostalzona = '
                    || nvl(codigopostalzona, 0) || ', planozona = ' || "'" || nvl(trim(planozona), '') || "'" || ', rumbozona = ' || "'"
                    || nvl(trim(rumbozona), '') || "'" || ', supervisorzona = ' || nvl(supervisorzona,0)  || ', choferzona = ' || nvl(choferzona,0) 
                    || ', jefegrupozona = ' || nvl(jefegrupozona,0) || ', gerentezona = ' || nvl(gerentezona,0) || ', abogadozona = ' || nvl(abogadozona,0)
                    || ', marcaencuesta30dias = ' || "'" || nvl(marcaencuesta30dias,'') || "'" || ', numerocalle = ' || nvl(numerocalle,0)
                    || ', numerocasa = ' || nvl(numerocasa,0) || ', marcaunidadhabitacional = ' || "'" || nvl(marcaunidadhabitacional,'') || "'"
                    || ', numerodivisioncobranzas = ' || nvl(numerodivisioncobranzas,0) || ', claveabogado = ' || nvl(claveabogado,0) || 
                    ', ciudadcobranzas = ' || nvl(ciudadcobranzas,0) || ', numerocobranzas = ' || nvl(numerocobranzas, 0) ||
                    --', clavearagon = ' || "'" || nvl(trim(clavearagon), '') || "'" || ', centro = ' || nvl(centro,0) ||
					', clavearagon = ' || "'" || 1 || "'" || ', centro = ' || nvl(centro,0) ||
                    ' WHERE numerociudad = ' || numerociudad || ' AND numerocolonia = ' || numerocolonia || ';', 
					 numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para actualizaciÃÂ³n (23 campos)
				    nvl(trim(replace(poblacionzona,"'", '')), ''), 
				    nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				    nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				    nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				    nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				    nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				    --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
					nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  
				
					INTO vtexto_select,
                    i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				    c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				    i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				    i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas, i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica
            FROM bdinteg:si_catzonas
            WHERE f_modifica >= vf_ultactualiza
            AND usr_modifica <> 'SYSCARTERA' 
			AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
		    if nvl(vtexto_select, '') <> '' then
				let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
				elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				-- MACF Para update  en nueva tabla
				   begin;
                       update bdinteg:si_catzonas_suc set nombrezona= c_nombrezona, poblacionzona= c_poblacionzona, municipiozona= c_municipiozona,
  					      codigopostalzona= i_codigopostalzona, planozona= c_planozona, rumbozona= c_rumbozona, supervisorzona= i_supervisorzona, 
						  choferzona= i_choferzona, jefegrupozona= i_jefegrupozona, gerentezona= i_gerentezona, abogadozona= i_abogadozona, 
						  marcaencuesta30dias= c_marcaencuesta30dias, numerocalle= i_numerocalle, numerocasa= i_numerocasa, marcaunidadhabitacional= c_marcaunidadhabitacional,
						  numerodivisioncobranzas= i_numerodivisioncobranzas, claveabogado= i_claveabogado, ciudadcobranzas= i_ciudadcobranzas,
						  numerocobranzas= i_numerocobranzas, clavearagon= c_clavearagon, centro= i_centro
                        where  numerociudad= i_numerociudad and numerocolonia= i_numerocolonia; 
                   commit;
				   
				-- MACF Para update  en nueva tabla
             else
                exit foreach;
             end if;                  
       end foreach;
       
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; 
       ---- FIN UPDATES SI_CATZONAS

  

      ----- INICIO INSERTS SI_CIUDADES   
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'ins_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
      
       foreach with hold
          select 'INSERT INTO public.iciudades values(''' || '001' || ''',''' || pais || ''',''' || estado || ''',''' || ciudad || ''',''' ||
                 --nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || nvl(tipo_ciudad,0) || ');',
				 nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || '1' || ');',
                 --pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, tipo_ciudad
				 pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1
				 
				 INTO vtexto_select,
                      i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad
          from bdinteg:si_ciudades
          where fecha_insert >= vf_ultinsercion
		    and nvl(d_ciudad,'') <> '' and nvl(elegir,'') = ''
		  
          
          if nvl(vtexto_select, '') <> '' then
              let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              end if;
          
              --let vLargoCadena = length(cCadena);
              --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
              --let vLargoCadena = 0;
			  
			  select count(*) into iExiste_cd
			    from bdinteg:si_ciudades_suc
				where empresa = '001' and codigo_pais = i_pais and codigo_estado = i_estado and codigo_ciudad = i_ciudad;
			 
             if iExiste_cd <= 0 then
				  begin;
					   insert into bdinteg:si_ciudades_suc(empresa, codigo_pais, codigo_estado, codigo_ciudad, nombre, numerociudad, localidad, tipo_ciudad)
					   values(pEmpresa, i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad);
				  commit;
			 end if;
			  
          else
              exit foreach;
          end if;
      
       end foreach;
    
       if nvl(vtexto_select, '') <> '' then 
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;  ----- FIN  INSERTS SI_CIUDADES
   

       ----  INICIO UPDATE SI_CIUDADES
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'upd_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
        
        foreach with hold
            SELECT 'UPDATE public.iciudades SET nombre = ' || "'" || nombre || "'" || ', numerociudad = ' || ciudad_coppel || 
                   --', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = ' || nvl(tipo_ciudad,0)  ||
				   ', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = 1' ||
                   ' WHERE codigo_estado = ' || estado || ' AND numerociudad = ' || ciudad_coppel || ';',
				   --nombre, ciudad_coppel, nvl(localidad_banxico,''), tipo_ciudad, estado
				   nombre, ciudad_coppel, nvl(localidad_banxico,''), 1, estado
				   INTO vtexto_select,
				   c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad, i_estado
				   
            FROM  bdinteg:si_ciudades
            WHERE f_modifica >= vf_ultactualiza
              AND ciudad_coppel <> 0
			  AND nvl(d_ciudad,'') <> '' AND nvl(elegir,'') = ''
        
             if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                    
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				
				begin;
				  update bdinteg:si_ciudades_suc 
                     set nombre= c_nombreciudad, numerociudad= i_numerociudad_2, localidad= c_localidad, tipo_ciudad= i_tipociudad
				   where codigo_estado= i_estado and numerociudad = i_numerociudad_2; 
                commit;				
				
             else
                exit foreach;
             end if;   
        
        end foreach;
    
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; ---- FIN UPDATE SI_CIUDADES

 
       ----INSERTS SI_CATCIUDADES      
        let vCatalogo  	= 'si_catciudades';
        let vConteo 	= 0;
        let vNomarch 	= 'ins_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
         
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
         
      foreach with hold      
            select 'INSERT INTO public.catciudades values(' ||
             numerociudad || ',''' || trim(nombreciudad) || ''',''' || nvl(trim(inicialciudad),'') || ''','  || nvl(tasainteres,0) || ',' || nvl(numeroestado,0) || ',''' ||
             nvl(trim(inicialestado),'') || ''',' || nvl(salariominimo,0) || ',' || nvl(gerentezona,0) || ',' || nvl(regioncobranzas,0) || ',' || nvl(ivaciudad,0) || ',''' || 
             nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || ''',' || nvl(unificaciudadesinformes,0) || ',' || nvl(unificaciudadescobranzas,0) || ',' || nvl(gerentecobranzas,0) || ',''' ||
             nvl(trim(generajobcarteratienda),'') || ''',''' || nvl(trim(inicialcredito),'') || ''',''' || nvl(regionestadodecuenta, '') || ''',' || nvl(tasainteresropa,0) || ',' ||
             nvl(tasainteresmueble12,0) || ',' || nvl(tasainteresmueble18,0) || ',' || nvl(tasainteresprestamo,0) || ',' || nvl(tasainterescelular1,0) || ',' || 
             nvl(tasainterescelular2,0) || ',''' ||  nvl(tipozona, '')  || ''',''' || nvl(fechaultimaactualizacion, '') || ''');' INTO vtexto_select
            from bdinteg:si_catciudades
            where f_inserta >= vf_ultinsercion
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;    
    
       if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ----INSERTS SI_CATCIUDADES
      
   
       ---- INICIO UPDATE SI_CATCIUDADES
        let vCatalogo  = 'si_catciudades';
        let vConteo = 0;
        let vNomarch = 'upd_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'upd_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
         
      foreach with hold     
            SELECT 'UPDATE public.catciudades set nombreciudad = ' || "'" || trim(nombreciudad) || "'" || ',inicialciudad = ' 
                   || "'" || nvl(trim(inicialciudad),'') || "'" || ', tasainteres = ' || nvl(tasainteres,0) || ',numeroestado = ' || nvl(numeroestado,0) ||
                   ',inicialestado = ' || "'" || nvl(inicialestado,'') || "'" || ',salariominimo = ' || nvl(salariominimo,0) || ',gerentezona = ' 
                   || nvl(gerentezona,0) || ',regioncobranzas = ' || nvl(regioncobranzas,0) || ',ivaciudad = ' || nvl(ivaciudad,0) || ', antiguedadciudad = '
                   || "'" || nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || "'" || ', unificaciudadesinformes = ' || nvl(unificaciudadesinformes,0) || 
                   ',unificaciudadescobranzas = ' || nvl(unificaciudadescobranzas,0) || ', gerentecobranzas = ' || nvl(gerentecobranzas,0) ||
                   ',generajobcarteratienda = ' || "'" || nvl(trim(generajobcarteratienda),'') || "'" || ',inicialcredito = ' || "'" ||
                    nvl(trim(inicialcredito),'') || "'" || ', regionestadodecuenta = ' || "'" || nvl(regionestadodecuenta, '') || "'" || ',tasainteresropa = '
                   || nvl(tasainteresropa,0) || ', tasainteresmueble12 = ' || nvl(tasainteresmueble12,0) || ',tasainteresmueble18 = ' || 
                   nvl(tasainteresmueble18,0) || ', tasainteresprestamo = ' || nvl(tasainteresprestamo,0) || ', tasainterescelular1 = ' ||
                   nvl(tasainterescelular1,0) || ', tasainterescelular2 = ' || nvl(tasainterescelular2,0) || ', tipozona = ' || "'" ||
                   nvl(tipozona, '') || "' WHERE numerociudad = " || numerociudad || ' AND numeroestado = ' || numeroestado || ';' INTO vtexto_select
             from bdinteg:si_catciudades
            where fechaultimaactualizacion >= vf_ultactualiza
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				    System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				   System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if;   ---- FIN UPDATE SI_CATCIUDADES
        
     
        ---- INICIO INSERT SI_CATCALLES 
        let vCatalogo  = 'si_catcalles';
        let vConteo = 0;
        let vNomarch = 'ins_catcalles_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catcalles_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
       
       foreach with hold     
          select {+ INDEX (bdinteg:si_catcalles idx_catcalles_fechains)} 'INSERT INTO public.catcalles values(' ||
                 numerocalle || ',''' || trim(nombrecalle) || ''');'  INTO vtexto_select
           from bdinteg:si_catcalles
          where f_inserta >= vf_ultinsercion
    
          if nvl(vtexto_select, '') <> '' then
            let vConteo = vConteo + 1;
            if  vConteo = 1 then
                let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            elif vConteo > 1 then
                let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            end if;
            --let vLargoCadena = length(cCadena);                                                         -- this temporary
            --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);  
            --let vLargoCadena = 0;                                                                       
          else
            exit foreach;
          end if;
            
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then    
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ---- FIN INSERTS SI_CATCALLES
    
 
	   ------------------------------------------  NUEVA DESCARGA CATDOMS PARA OMNICANAL 2022-11-17
	   select valor into vEjecuta_omnicanal
         from bdinteg:si_param_dom
        where empresa = pEmpresa and cod_param = 31;  
	   
	   
	   IF vEjecuta_omnicanal = 'S' THEN
	      
		  --LET vNomarch = 'catalogo_catzonas.txt';
		  LET vNomarch = 'catalogo_catzonas_' || vfecha_hoy || '.txt';

	      select valor into vPath_ominicanal
            from bdinteg:si_param_dom
           where empresa = pEmpresa and cod_param = 30;  

		 LET cCadena_omni = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT  a.numerociudad, a.numerocolonia, ' 
  || 'trim(replace(a.nomzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end, case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado '
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado '
  || 'and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and b.d_ciudad = d.d_ciudad '
  || 'and (d.ciudad_coppel > 0 AND ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'UNION '
  || 'SELECT a.numerociudad, a.numerocolonia, trim(replace(a.nomzona_spmx,chr(39),''' || ''')),' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end,case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado ' 
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado and d.estado = ''' || '09' || ''' and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and (d.ciudad_coppel > 0 and d.ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'and nvl(a.nomzona_spmx,''' || ''') <> ''' || ''' and nvl(a.pobzona_spmx, ''' || ''') <> ''' || ''' and nvl(a.mnpio_spmx, ''' || ''') <> ''''" >' || trim(vPath_ominicanal) ||'corre_si_catzonas.sql'; 

 
         SYSTEM TRIM(cCadena_omni);
         let cCadena_omni = '';
   
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	     --------------------  CIUDADES
		 LET vNomarch = 'catalogo_iciudades_' || vfecha_hoy || '.txt';
	     LET cCadena = '';  
	 
	     LET cCadena = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT ''' || '001' || ''
	     || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
         || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel > 0 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado <> ''' || '09' || ''' UNION '
	     || 'SELECT ''' || '001' || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
	     || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel <> 6564 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado = ''' || '09' || '''" >' || trim(vPath_ominicanal) ||'corre_si_ciudades.sql';
	 
	     SYSTEM TRIM(cCadena);
	     let cCadena = '';
  
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);  

	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	   END IF;
 
       ----REGISTRO EN BITACORA
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
       
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, cMensaje, 0, pUsuario, vdia, vhora);
   else
     let v_codret = '00OFF';
   end if;
   
  RETURN v_codret;
END;

END PROCEDURE;