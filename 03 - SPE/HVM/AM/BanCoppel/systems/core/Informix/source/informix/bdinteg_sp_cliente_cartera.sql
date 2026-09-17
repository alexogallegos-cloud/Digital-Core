CREATE PROCEDURE "informix".sp_cliente_cartera(
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

         --SET DEBUG FILE TO '/home/e10001492/sp_cliente_cartera.out'; 
         --TRACE ON;   

        SET OPTIMIZATION HIGH;
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
          dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel, id_pais,user_insert ) -- DSB230162JERV1694 id_pais
        VALUES
        ( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
          pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0', pIdPais,'informix'); -- DSB230162JERV1694 pIdPais

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
"Folio:			CI Banco",
"Proyecto:		CI Automotriz",
"Autor: 		99802161 - Narciso Ivan Cisneros Acosta",
"Fecha: 		30/10/2025",
"Solicita:		Abraham Narvaez Jacinto",
"Descripcion:   Se crea sp para la generacion del numero de cliente banco en cartera de clientes.",
"BD: 			bdinteg";

CREATE PROCEDURE "informix".sp_cliente_cartera_externa_existe(
    pCte CHAR(20),  -- NÃºmero de Cliente para bÃºsqueda
    pRfc CHAR(13)   -- RFC del Cliente para bÃºsqueda
)
    -- Se define el formato de retorno: CÃ³digo de estado Y el indicador de encontrado/no encontrado.
    RETURNING
    CHAR(6),    -- sCodRet: '000000': OK, '000001': Error parÃ¡metros, '000002': No encontrado, 'SQLCODE': Otros errores.
    CHAR(1);    -- sEncontrado: '1' si se encontrÃ³, '0' si no se encontrÃ³.

    -- #################################
    -- # 1. DECLARACIÃN DE VARIABLES
    -- #################################
    DEFINE sCodRet          CHAR(6);    -- CÃ³digo de retorno principal
    DEFINE sEncontrado      CHAR(1);    -- Indicador '1' (encontrado) o '0' (no encontrado)
    
    DEFINE iSqlErr          INTEGER;    -- Para SQLCODE
    DEFINE iIsamErr         INTEGER;    -- Para ISAMCODE
    DEFINE cVarDataErr      VARCHAR(64);    
    -- Variable temporal para la SELECT INTO (su valor no importa, solo su Ã©xito o fracaso)
    DEFINE temp_dummy       CHAR(1); 

BEGIN
    -- #################################
    -- # 2. MANEJO DE EXCEPCIONES GENERAL
    -- #################################
    
    ON EXCEPTION
        SET iSqlErr, iIsamErr, cVarDataErr
        -- En caso de cualquier error inesperado, asignamos el SQLCODE y seteamos '0' para 'Encontrado'.
        LET sCodRet = LPAD(iSqlErr::VARCHAR(6), 6, '0');
        LET sEncontrado = '0'; -- Un error implica que no se pudo "encontrar" correctamente.
        RETURN sCodRet, sEncontrado; 
    END EXCEPTION;
        
    -- InicializaciÃ³n de variables de retorno
    LET sCodRet     = '000000';         -- Por defecto, asumimos Ã©xito (cambiarÃ¡ si no se encuentra o hay error)
    LET sEncontrado = '0';              -- Por defecto, asumimos que no se encontrarÃ¡ al cliente

    -- ConfiguraciÃ³n de sesiÃ³n para el rendimiento
        SET OPTIMIZATION HIGH;
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;


    -- #################################
    -- # 3. VALIDACIÃN DE ENTRADA
    -- #################################

    -- El procedimiento requiere al menos uno de los dos parÃ¡metros (RFC o CTE) no vacÃ­os
    IF (pCte IS NULL OR TRIM(pCte) = '') AND (pRfc IS NULL OR TRIM(pRfc) = '') THEN
        LET sCodRet     = '000001'; -- CÃ³digo de error: ParÃ¡metros de bÃºsqueda vacÃ­os
        LET sEncontrado = '0';      -- No encontrado por falta de parÃ¡metros vÃ¡lidos
        RETURN sCodRet, sEncontrado; 
    END IF;

    -- #################################
    -- # 4. CONSULTA Y VALIDACIÃN DE EXISTENCIA
    -- #################################

    -- Usamos un bloque BEGIN...END con ON EXCEPTION IN (100) para detectar "no data found"
    BEGIN
        ON EXCEPTION IN (100) -- SQLCODE 100 es para "no data found"
            LET sCodRet     = '000002'; -- CÃ³digo: No se encontrÃ³ el cliente
            LET sEncontrado = '0';      -- Claramente, no encontrado.
            RETURN sCodRet, sEncontrado; 
        END EXCEPTION;

        -- Intentamos obtener una constante 'X' en una variable dummy para verificar la existencia.
        -- Si la SELECT INTO es exitosa, el cliente existe.
        SELECT FIRST 1 num_cliente -- Seleccionamos una constante, solo para llenar la variable dummy
        INTO temp_dummy
        FROM bdinteg:si_cliente_cartera_externa A
        WHERE
            -- LÃ³gica flexible de bÃºsqueda por RFC o NÃºmero de Cliente:
            (TRIM(pRfc) <> '' AND TRIM(A.rfc_calculado) = TRIM(pRfc))
            OR
            (TRIM(pCte) <> '' AND TRIM(A.num_cliente) = TRIM(pCte));

    END; -- Fin del bloque BEGIN...END para la SELECT INTO

    -- Si el SP llega hasta aquÃ­, significa que el SELECT INTO fue exitoso.
    -- El cliente ha sido encontrado.
    IF temp_dummy <> '' THEN
        LET sCodRet     = '000000'; -- Todo OK, cliente encontrado.
        LET sEncontrado = '1';      -- Indicador de que el cliente fue encontrado.
    END IF
    RETURN sCodRet, sEncontrado;
end
END PROCEDURE
-- #################################
-- # DOCUMENTACIÃN (Buenas PrÃ¡cticas)
-- #################################

DOCUMENT
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_cliente_cartera_externa_Existe"',
'Folio.........: XXX',
'Autor.........: Miguel Ãngel Blanco ArÃ©chiga',
'Fecha.........: 16/09/2025 (ActualizaciÃ³n)',
'Solicita......: Miguel Esquivel/Estephany Ley',
'Objetivo......: Valida si el cliente existe ',
'BD............: bdinteg',
'ParÃ¡metros....: pRfc CHAR(13), pCte CHAR(20)',
'Retorna.......: CHAR(6) - CÃ³digo de Retorno (000000: OK, 000001: Input InvÃ¡lido, 000002: No Encontrado, >000002: SQLCODE)',
'                CHAR(1) - Encontrado (0 No Encontrado 1: Encontrado)''Historial de Cambios: ',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | Fecha        | Autor                               | DescripciÃ³n del Cambio                                                      |',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | 27/10/2025   | M.A. Blanco Arechiga                | CreaciÃ³n inicial del procedimiento.                                         |',
' -----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_mensajes_cartera_externa_lista(
    pCte CHAR(20),  -- ParÃ¡metro de entrada: NÃºmero de cliente
    pRfc CHAR(13)   -- ParÃ¡metro de entrada: RFC del cliente
)
    RETURNING
    CHAR(6),    -- CÃ³digo de Retorno para cada fila (o error general)
    CHAR(20),   -- Producto de origen
    CHAR(50),   -- Empresa de origen
    CHAR(20);   -- Cuenta STP o estado de liquidaciÃ³n

    -- #################################
    -- # 1. DECLARACIÃN DE VARIABLES
    -- #################################
    DEFINE sCodRet          CHAR(6);    -- Almacena el cÃ³digo de retorno
    DEFINE rProductoOrigen  CHAR(20);   -- Almacena el producto de origen para cada fila
    DEFINE rEmpresaOrigen   CHAR(50);   -- Almacena el nombre de la empresa para cada fila
    DEFINE rCtaSTP          CHAR(20);   -- Almacena el estado o nÃºmero de cuenta STP para cada fila
    
    DEFINE iRegistros       SMALLINT;   -- Contador de registros encontrados
    DEFINE iSqlErr          INTEGER;    -- Almacena el SQLCODE en caso de error
    DEFINE iIsamErr         INTEGER;    -- Almacena el ISAMCODE en caso de error
    DEFINE cVarDataErr      VARCHAR(64);
BEGIN
    -- #################################
    -- # 2. MANEJO DE EXCEPCIONES GENERAL
    -- #################################
    -- Este bloque ON EXCEPTION captura cualquier error SQL inesperado durante la ejecuciÃ³n
    -- del procedimiento. Retorna el SQLCODE como indicador de error.
    ON EXCEPTION SET iSqlErr, iIsamErr, cVarDataErr
        LET sCodRet = LPAD(iSqlErr::VARCHAR(6), 6, '0');
        -- Retorna el cÃ³digo de error y valores NULL para los datos.
        RETURN sCodRet, NULL, NULL, NULL;
    END EXCEPTION;
        
    -- #################################
    -- # 3. INICIALIZACIÃN DE VARIABLES Y CONFIGURACIÃN DE SESIÃN
    -- #################################
    LET sCodRet    = '000000';         -- CÃ³digo de retorno inicial (asume Ã©xito)
    LET iRegistros = 0;                -- Inicializa el contador de registros
    
    -- ConfiguraciÃ³n del nivel de aislamiento para mejorar el rendimiento.
    -- DIRTY READ permite leer datos no confirmados, adecuado para consultas de listado.
        SET OPTIMIZATION HIGH;
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

    -- #################################
    -- # 4. VALIDACIÃN DE PARÃMETROS DE ENTRADA
    -- #################################
    -- Se requiere que al menos uno de los parÃ¡metros de bÃºsqueda (pCte o pRfc)
    -- contenga un valor vÃ¡lido. Si ambos estÃ¡n vacÃ­os, se retorna un error.
    IF (TRIM(pCte) IS NULL OR TRIM(pCte) = '') AND (TRIM(pRfc) IS NULL OR TRIM(pRfc) = '') THEN
        LET sCodRet = '000001'; -- CÃ³digo de error: ParÃ¡metros de entrada nulos o vacÃ­os
        RETURN sCodRet, NULL, NULL, NULL;
    END IF;

    -- #################################
    -- # 5. CONSULTA Y RETORNO DE REGISTROS (FOREACH)
    -- #################################
    -- El bucle FOREACH itera sobre los registros que coinciden con los criterios de bÃºsqueda
    -- y retorna cada fila como parte del conjunto de resultados del procedimiento.
    FOREACH
        SELECT
            A.producto_origen,
            TRIM(B.nombre),
            -- Determina el valor de la cuenta STP: 'Liquidado' si es 'NA' o vacÃ­o, de lo contrario el valor de la cuenta.
            CASE
                WHEN A.cta_stp_adquiriente = 'NA' THEN 'Liquidado'
                WHEN A.cta_stp_adquiriente = ''   THEN 'Liquidado'
                ELSE TRIM(A.cta_stp_adquiriente)
            END
        INTO 
            rProductoOrigen,
            rEmpresaOrigen,
            rCtaSTP
        FROM
            si_cliente_cartera_externa A
        INNER JOIN
            si_empresa_cartera B ON A.id_empresa_cartera = B.ID
        WHERE
            -- LÃ³gica de bÃºsqueda flexible: coincide si el RFC o el NÃºmero de Cliente coinciden
            -- con los parÃ¡metros de entrada (siempre que el parÃ¡metro no estÃ© vacÃ­o).
            (TRIM(A.rfc_calculado) = TRIM(pRfc) AND TRIM(pRfc) <> '')
            OR
            -- O la columna A.num_cliente debe coincidir con pCte (si pCte no estÃ¡ vacÃ­o)
            (TRIM(A.num_cliente) = TRIM(pCte) AND TRIM(pCte) <> '')           
        -- Retorna la fila actual con el cÃ³digo de Ã©xito y los valores de los campos.
        -- NVL se usa para asegurar que los campos no sean NULL si la tabla lo permite.
        RETURN sCodRet, NVL(rProductoOrigen,''), NVL(rEmpresaOrigen,''), NVL(rCtaSTP,'') WITH RESUME;
        LET iRegistros = iRegistros + 1; -- Incrementa el contador de registros encontrados
    END FOREACH;
    
    -- #################################
    -- # 6. MANEJO DE "NO DATA FOUND"
    -- #################################
    -- Si el bucle FOREACH finaliza y no se encontrÃ³ ningÃºn registro (iRegistros sigue siendo 0),
    -- se retorna un cÃ³digo de error especÃ­fico para "no data found".
    IF iRegistros = 0 THEN
        LET sCodRet = '000002'; -- CÃ³digo de error: No se encontrÃ³ Cliente/RFC
        -- Retorna el cÃ³digo de error y valores NULL para indicar la ausencia de resultados.
        RETURN sCodRet, NULL, NULL, NULL;
    END IF;

    -- Este punto no deberÃ­a ser alcanzado si el FOREACH encontrÃ³ y retornÃ³ registros.
    -- Si llega aquÃ­ (por alguna lÃ³gica no prevista), simplemente finaliza.
END
END PROCEDURE
DOCUMENT
'Nombre              : sp_consulta_mensajes_cartera_externa_Lista',
'DescripciÃ³n         : Recupera una lista de mensajes de cartera externa para un cliente especÃ­fico',
'                      identificado por su nÃºmero de cliente (pCte) o su RFC (pRfc).',
'                      Retorna un conjunto de resultados que incluye informaciÃ³n del producto, la empresa',
'                      de origen y el estado de la cuenta STP.',
'Autor               : 99801890 - Miguel Angel Blanco Arechiga',
'Fecha de CreaciÃ³n   : 16/09/2025',
'Solicitado por      : Miguel Esquivel / Estephany Ley',
'Base de Datos       : bdinteg',
'Historial de Cambios: ',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | Fecha        | Autor                               | DescripciÃ³n del Cambio                                                     |',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | 16/09/2025   | M.A. Blanco Arechiga                | CreaciÃ³n inicial del procedimiento.                                        |',
' -----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_valida_dias_transcurridos_cartera_externa(
    pCte                CHAR(20),       -- ParÃ¡metro de entrada: NÃºmero de cliente
    pRfc                CHAR(13),       -- ParÃ¡metro de entrada: RFC del cliente
    pDiasConfigurados   INTEGER         -- ParÃ¡metro de entrada: DÃ­as lÃ­mite para la validaciÃ³n
)
    RETURNING
    CHAR(6) AS sCodRet,                  -- CÃ³digo de retorno principal
    CHAR(1) AS sMuestraPantalla,        -- Bandera de si los dÃ­as han transcurrido
    INTEGER AS sDiasTranscurridos;            -- NÃºmero de dÃ­as transcurridos calculado
    
    -- #################################
    -- # 1. DECLARACIÃN DE VARIABLES
    -- #################################
    DEFINE cCodRet                      CHAR(6);    -- Almacena el cÃ³digo de retorno
    DEFINE sMuestraPantalla             CHAR(1);    -- Bandera para indicar si los dÃ­as han transcurrido ('1' o '0')
    DEFINE iDiastranscurridos           INTEGER;    -- Almacena el cÃ¡lculo de los dÃ­as transcurridos
    DEFINE dFechaRegistroCte            DATE;       -- Almacena la fecha de registro del cliente obtenida de la tabla
    DEFINE iSqlErr                      INTEGER;    -- Almacena el SQLCODE en caso de error
    DEFINE iSamErr                      INTEGER;    -- Almacena el ISAMCODE en caso de error
    DEFINE cVarDataErr                  VARCHAR(64);
BEGIN
    -- #################################
    -- # 2. MANEJO DE EXCEPCIONES GENERAL
    -- #################################
    -- Este bloque ON EXCEPTION captura cualquier error SQL inesperado que ocurra
    -- dentro del procedimiento, excepto el SQLCODE 100 ("no data found") que se
    -- maneja de forma especÃ­fica mÃ¡s adelante.
    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        -- Asignar el SQLCODE como cÃ³digo de retorno, rellenando con ceros a la izquierda
        LET cCodRet = LPAD(iSqlErr::VARCHAR(6), 6, '0');
        -- En caso de error, la bandera de dÃ­as transcurridos es '0' y los dÃ­as son 0
        RETURN cCodRet, '0', 0; -- Retorna el SQLCODE, bandera '0' y dÃ­as transcurridos '0'
    END EXCEPTION;
        
    -- #################################
    -- # 3. INICIALIZACIÃN DE VARIABLES
    -- #################################
    -- Establecer valores iniciales para las variables de retorno y control
    LET cCodRet                     = '000000'; -- Por defecto, se asume un estado de Ã©xito
    LET sMuestraPantalla            = '0';      -- Por defecto, se asume que los dÃ­as NO han transcurrido
    LET iDiastranscurridos          =  0;        -- Inicialmente, 0 dÃ­as transcurridos
    LET dFechaRegistroCte           = NULL;     -- Asegurar que la fecha estÃ© nula al inicio

    -- #################################
    -- # 4. CONFIGURACIÃN DE SESIÃN
    -- #################################
    -- Establecer el modo de bloqueo y el nivel de aislamiento para la transacciÃ³n.
    -- DIRTY READ permite leer datos no confirmados, mejorando el rendimiento en consultas.
    SET LOCK MODE TO WAIT 3; -- Esperar hasta 3 segundos por un bloqueo
    SET ISOLATION TO DIRTY READ; 

    -- #################################
    -- # 5. VALIDACIÃN DE PARÃMETROS DE ENTRADA
    -- #################################
    -- Verificar que al menos uno de los parÃ¡metros de bÃºsqueda (pCte o pRfc)
    -- no estÃ© nulo o vacÃ­o para poder realizar la consulta.
    IF (pCte IS NULL OR TRIM(pCte) = '') AND (pRfc IS NULL OR TRIM(pRfc) = '') THEN
        LET cCodRet = '000001'; -- CÃ³digo de error: ParÃ¡metros de bÃºsqueda vacÃ­os
        RETURN cCodRet, sMuestraPantalla, 0; -- Retorna error de parÃ¡metros, bandera '0' y dÃ­as '0'
    END IF;
    
    -- #################################
    -- # 6. CONSULTA DE FECHA DE REGISTRO DEL CLIENTE
    -- #################################
    -- Este bloque intenta obtener la fecha de registro del cliente de 'si_cartera_externa'.
    -- El bloque ON EXCEPTION IN (100) gestionarÃ¡ el escenario donde el cliente no es encontrado.
    BEGIN
        ON EXCEPTION IN (100) -- Captura especÃ­ficamente "no data found"
            -- Si el cliente NO se encuentra en la tabla, se considera que la condiciÃ³n
            -- de "dÃ­as transcurridos" SI se cumple, ya que no hay registro activo.
            LET cCodRet                     = '000000'; -- Se mantiene como Ã©xito, pues es un resultado esperado.
            LET sMuestraPantalla            = '1';      -- Se marca la bandera como '1' (sÃ­ han transcurrido)
            -- Retorna Ã©xito y la bandera '1', ya que no hay registro para validar dÃ­as.
            RETURN cCodRet, sMuestraPantalla, 0; 
        END EXCEPTION;
        
        -- Seleccionar la primera fecha de registro que coincida con pCte o pRfc.
        -- Se convierte a tipo DATE para facilitar la resta con TODAY (que es DATE).
        -- La clÃ¡usula WHERE permite buscar por numcte, rfc o una combinaciÃ³n de ambos.
        SELECT FIRST 1 FECHA::DATE
        INTO dFechaRegistroCte
        FROM bdinteg:si_cartera_externa
        WHERE 1 = 1 -- CondiciÃ³n base para encadenar las siguientes
        AND (
            -- BÃºsqueda por nÃºmero de cliente (si pCte tiene valor)
            (pCte IS NOT NULL AND TRIM(pCte) <> '' AND TRIM(numcte) = TRIM(pCte))
            OR
            -- BÃºsqueda por RFC (si pRfc tiene valor)
            (pRfc IS NOT NULL AND TRIM(pRfc) <> '' AND TRIM(rfc) = TRIM(pRfc))
        )
        AND (
            -- CondiciÃ³n adicional: si ambos pCte y pRfc tienen valor, se exige que AMBOS coincidan.
            -- Esto evita que una bÃºsqueda por ambos devuelva un cliente que solo coincide en uno de los campos.
            NOT (pCte IS NOT NULL AND TRIM(pCte) <> '' AND pRfc IS NOT NULL AND TRIM(pRfc) <> '') OR
            (TRIM(numcte) = TRIM(pCte) AND TRIM(rfc) = TRIM(pRfc))
        );
    END; -- Fin del bloque de manejo de "no data found" para la SELECT

    -- #################################
    -- # 7. CÃLCULO Y VALIDACIÃN DE DÃAS TRANSCURRIDOS
    -- #################################
    -- Si el SP llega a este punto, significa que el cliente fue encontrado exitosamente.

    -- Calcular la diferencia en dÃ­as entre la fecha de registro del cliente y la fecha actual (TODAY).
    -- El resultado es un entero que representa los dÃ­as transcurridos.
    LET iDiastranscurridos = TODAY - dFechaRegistroCte; 

    -- Comparar los dÃ­as transcurridos con el lÃ­mite configurado (pDiasConfigurados).
    IF iDiastranscurridos  > pDiasConfigurados THEN
        LET sMuestraPantalla = '1'; -- La condiciÃ³n se cumple: SÃ­ han transcurrido mÃ¡s dÃ­as.
    ELSE
        LET sMuestraPantalla = '0'; -- La condiciÃ³n NO se cumple: No han transcurrido los dÃ­as.
    END IF;

    -- #################################
    -- # 8. RETORNO FINAL DE RESULTADOS
    -- #################################
    -- Retorna el cÃ³digo de Ã©xito, la bandera de dÃ­as transcurridos y el conteo de dÃ­as.
    RETURN cCodRet, sMuestraPantalla, iDiastranscurridos;
END
END PROCEDURE
DOCUMENT
'Nombre              : sp_valida_dias_transcurridos_cartera_externa',
'DescripciÃ³n         : Procedimiento para validar si la fecha de registro de un cliente en la tabla bdinteg:si_cartera_externa',
'                      ha excedido un nÃºmero de dÃ­as configurado. Permite buscar por nÃºmero de cliente (pCte) o RFC (pRfc).',
'                      Retorna un cÃ³digo de estado (sCodRet), un indicador de si los dÃ­as han transcurrido (sMuetsraPantalla),',
'                      y la cantidad de dÃ­as transcurridos (sDiasTranscurridos).',
'Autor               : 99801890 - Miguel Angel Blanco Arechiga',
'Fecha de CreaciÃ³n   : 16/09/2025',
'Solicitado por      : Miguel Esquivel / Estephany Ley',
'Base de Datos       : bdinteg',
'Historial de Cambios: ',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | Fecha        | Autor                               | DescripciÃ³n del Cambio                                                      |',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | 27/10/2025   | M.A. Blanco Arechiga                | CreaciÃ³n inicial del procedimiento.                                         |',
' -----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inserta_cartera_externa(
    pCte        CHAR(20),   -- ParÃ¡metro de entrada: NÃºmero de cliente
    pRfc        CHAR(13),   -- ParÃ¡metro de entrada: RFC del cliente (clave de bÃºsqueda)
    pModulo     CHAR(1)     -- ParÃ¡metro de entrada: MODULO para identificar de donde se esta consultando Cartera Externa
)
    RETURNING
    CHAR(6);   -- CÃ³digo de Retorno de la operaciÃ³n

    -- #################################
    -- # 1. DECLARACIÃN DE VARIABLES
    -- #################################
    DEFINE vCodRet          CHAR(6);    -- Almacena el cÃ³digo de retorno de la operaciÃ³n
    DEFINE iSqlErr          INTEGER;    -- Almacena el SQLCODE en caso de error
    DEFINE iSamErr          INTEGER;    -- Almacena el ISAMCODE en caso de error
    DEFINE cVarDataErr      VARCHAR(64);    
    -- Variables para capturar datos existentes antes de historizar
    DEFINE l_numcte_exist   CHAR(20);
    DEFINE l_rfc_exist      CHAR(13);
    DEFINE l_modulo_exist   CHAR(1);    -- Asumiendo '001' es CHAR(3)
    DEFINE l_fecha_exist    DATETIME YEAR TO SECOND;       -- Asumiendo 'fecha' es de tipo DATE

BEGIN
    -- #################################
    -- # 2. MANEJO DE EXCEPCIONES GENERAL
    -- #################################
    -- Este bloque ON EXCEPTION captura cualquier error SQL inesperado que ocurra
    -- dentro del procedimiento. Asigna el SQLCODE como cÃ³digo de retorno.
    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        -- Asignar el SQLCODE como cÃ³digo de retorno, rellenando con ceros a la izquierda
        LET vCodRet = LPAD(iSqlErr::VARCHAR(6), 6, '0');
        RETURN vCodRet;
    END EXCEPTION;

    -- #################################
    -- # 3. INICIALIZACIÃN DE VARIABLES
    -- #################################
    -- Establecer el cÃ³digo de retorno por defecto a Ã©xito
    LET vCodRet = '000000';

    -- ConfiguraciÃ³n de sesiÃ³n para rendimiento (si es necesario)
        SET OPTIMIZATION HIGH;
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
    -- #################################
    -- # 4. VALIDACIÃN DE PARÃMETROS DE ENTRADA
    -- #################################
    -- Verificar que AL MENOS UNO de los parÃ¡metros esenciales (pCte o pRfc) no estÃ© vacÃ­o.
    IF (pCte IS NULL OR TRIM(pCte) = '') AND (pRfc IS NULL OR TRIM(pRfc) = '') THEN
        LET vCodRet = '000001'; -- CÃ³digo de error: Ambos parÃ¡metros de bÃºsqueda estÃ¡n vacÃ­os        
        RETURN vCodRet;
    END IF;

    -- #################################
    -- # 5. LÃGICA DE INSERCIÃN O ACTUALIZACIÃN (CON HISTORIAL)
    -- #################################
    -- Se intenta encontrar el registro por RFC para determinar si ya existe.
    -- El bloque ON EXCEPTION IN (100) gestionarÃ¡ el escenario de "no data found".
    BEGIN
        ON EXCEPTION IN (100) -- SQLCODE 100 es para "no data found"
            -- Si NO se encontrÃ³ el registro con el RFC, es una nueva inserciÃ³n.
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (pCte, pRfc, CURRENT, pModulo); -- Se asume 'fecha' y se usa TODAY.
                 
            
            RETURN vCodRet; -- Retorna '000000' (Ã©xito) y finaliza el SP.
        END EXCEPTION;
        
        -- Si llegamos aquÃ­, el registro con el RFC EXISTE.
        -- Se capturan los datos actuales para el historial antes de modificarlo.
        SELECT numcte, rfc, fecha, Modulo
        INTO l_numcte_exist, l_rfc_exist, l_fecha_exist, l_modulo_exist
        FROM bdinteg:si_cartera_externa
        WHERE 1 = 1 -- CondiciÃ³n base, siempre verdadera, para encadenar las siguientes
        AND (
            -- BÃºsqueda por RFC (si pRfc tiene valor)
            (TRIM(pRfc) <> '' AND TRIM(rfc) = TRIM(pRfc))
            OR
            -- BÃºsqueda por NÃºmero de Cliente (si pCte tiene valor)
            (TRIM(pCte) <> '' AND TRIM(numcte) = TRIM(pCte))
        );

        -- #################################
        -- # 5.1. VALIDACIÃN DE DATOS PARA HISTORIAL (opcional, si los campos pueden ser NULL)
        -- #################################
        -- Asegurar que los datos para el historial no sean nulos si las columnas no lo permiten
        IF l_numcte_exist IS NULL OR TRIM(l_numcte_exist) = '' THEN
            LET l_numcte_exist = TRIM(pCte); -- Usar el nuevo cliente si el viejo era nulo/vacÃ­o
            
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc,  fecha, Modulo)
            VALUES (pCte, pRfc,  CURRENT, pModulo);
        ELSE
       
            IF l_fecha_exist IS NULL THEN
                LET l_fecha_exist = CURRENT; -- Usar la fecha actual si la fecha del registro era nula
            END IF;
   
            -- #################################
            -- # 5.2. MOVER A HISTORIAL, BORRAR Y RE-INSERTAR
            -- #################################
            -- 1. Insertar el registro existente en la tabla de historial
            INSERT INTO si_his_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (l_numcte_exist, l_rfc_exist, l_fecha_exist, l_modulo_exist); -- Usamos los datos capturados y validados
            -- 2. Eliminar el registro de la tabla principal.
            --    La clÃ¡usula WHERE se adapta para buscar por pCte, pRfc, o ambos,
            --    utilizando la misma lÃ³gica de identificaciÃ³n que en el SELECT.
            DELETE FROM bdinteg:si_cartera_externa
            WHERE 1 = 1 -- CondiciÃ³n base, siempre verdadera, para encadenar las siguientes
            AND TRIM(numcte) = TRIM(pCte);
            
            -- 3. Insertar el nuevo registro (o la "actualizaciÃ³n") en la tabla principal
            -- La fecha del nuevo registro siempre serÃ¡ TODAY.
            INSERT INTO bdinteg:si_cartera_externa (numcte, rfc, fecha, Modulo)
            VALUES (pCte, pRfc,  current, pModulo);
            
        END IF;
    END; -- Fin del bloque BEGIN/END que maneja la lÃ³gica de existencia

    -- #################################
    -- # 6. RETORNO FINAL
    -- #################################
    -- Si el SP llega a este punto, significa que la operaciÃ³n se completÃ³ exitosamente.
    RETURN vCodRet; -- Retorna '000000' (Ã©xito)
END
END PROCEDURE
DOCUMENT
'Nombre              : sp_inserta_cartera_externa',
'DescripciÃ³n         : Este procedimiento almacenado maneja la inserciÃ³n de nuevos clientes',
'                      o la actualizaciÃ³n de clientes existentes en la tabla "si_cartera_externa".',
'                      Si el cliente ya existe (validado por RFC), su registro actual es movido a',
'                      "si_his_cartera_externa" (historial) y luego se inserta el nuevo registro.',
'                      Si el cliente no existe, se inserta directamente en "si_cartera_externa".',
'Autor               : 99801890 - Miguel Angel Blanco Arechiga',
'Fecha de CreaciÃ³n   : 16/09/2025',
'Solicitado por      : Miguel Esquivel / Estephany Ley',
'Base de Datos       : bdinteg',
'Historial de Cambios: ',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | Fecha        | Autor                               | DescripciÃ³n del Cambio                                                     |',
' -----------------------------------------------------------------------------------------------------------------------------------',
' | 16/09/2025   | M.A. Blanco Arechiga                | CreaciÃ³n inicial del procedimiento.                                        |',
' -----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_insbitsmstelcte(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5), pdigito_ver CHAR(4), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
RETURNING char(5) as codret;
DEFINE iSqlErr			INTEGER;
DEFINE sNumRnd          INTEGER;
DEFINE sNumRnd2         DECIMAL(10,0);
DEFINE sCodigo          CHAR(4);
DEFINE sCodSp           CHAR(5);
DEFINE iMinutos         INTEGER;
DEFINE iReintentos      INTEGER;
DEFINE iEnviados        INTEGER;
DEFINE iMinTrans        INTEGER;
DEFINE sDiferencia      CHAR(30);
DEFINE iExiste          SMALLINT;
DEFINE pCte             CHAR(20);
DEFINE sCodSp2          CHAR(5);
DEFINE sCorreo          CHAR(100);
DEFINE pfecha           DATETIME YEAR TO FRACTION;

LET sNumRnd     =   0;
LET sNumRnd2    =   0;
LET sCodigo     =   '';
LET sCodSp      =   '00000';
LET iMinutos    =   0;
LET iReintentos =   0;
LET iEnviados   =   0;
LET iMinTrans   =   0;
LET sDiferencia =   '';
LET iExiste     =   0;
LET pCte        =   '';
LET pfecha      =   '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

SET ISOLATION TO DIRTY READ;
--SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO '/tmp/anj/sp_insbitsmstel.sql';
--TRACE ON;

IF popcion='1' THEN		
--*****OPCION 1 DE INSERCION*****--



       --IF NOT EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current)) THEN
       SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       LET iExiste = dbinfo("sqlca.sqlerrd2");
       IF iExiste=0 THEN
           INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
	   ELSE
			SELECT FIRST 1 digito_ver INTO pdigito_ver FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       END IF;

       EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
            SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
            IF NVL(sCorreo,'')<>'' THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
            END IF;
       --***ATENCION DEL RQI 63 421***--
        
ELIF popcion='2' THEN
--*****OPCION 2 INSERTAR CODIGO INCORRECTO*****--
        SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
        UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut = pteclea_ejecut
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, bandera, fecha) 
            VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pbandera, current);
ELIF popcion='3' THEN
--*****OPCION 3 ACTUALIZACION CODIGO CORRECTO*****--
        --IF EXISTS (SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL) THEN 
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
            UPDATE si_bitsmstels SET teclea_ejecut=pteclea_ejecut, bandera=pbandera, fecha=CURRENT
                WHERE numcte = pnumcte AND ejecutivo = pejecutivo AND sucursal = psucursal AND fecha = pfecha AND teclea_ejecut IS NULL;
        ELSE
            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, bandera, fecha) 
                              VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pteclea_ejecut, pbandera, current);
        END IF;
        --AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
        IF pbandera<>'F' or pbandera<>'f' THEN
            UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
            UPDATE si_telefonos SET verificado="F" WHERE numcte<> pnumcte and telefono=ptelefono;
        END IF;

ELIF popcion='5' THEN
	--Realizar el ReenvÃÂ­o de nuevo cuando es mantenimiento

        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
        VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);


        EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
			INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
        SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
        IF NVL(sCorreo,'')<>'' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
        END IF;
       --***ATENCION DEL RQI 63 421***--

ELSE
--*****OPCION 4 ENVIO DEL SMS DE NUEVA CUENTA*****--

  --OBTENIENDO LOS PARAMETROS
    --MINUTOS MAXIMO PARA REENVIAR EL SMS
    SELECT TRIM(valor) INTO iMinutos FROM si_param WHERE cod_param='382';
    --CANTIDAD DE REINTENTOS MAXIMOS POR DIA (SOLO REENVIO)
    SELECT TRIM(valor) INTO iReintentos FROM si_param WHERE cod_param='383';


  --OBTENIENDO LA CANTIDAD DE REENVIOS DEL DIA POR CTE-TELEFONO
    SELECT COUNT(*) INTO iEnviados
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND TRIM(teclea_ejecut)='REENVIO SMS'
        AND DATE(fecha)=DATE(current);

  --SI SE SUPERA EL MAXIMO DE SMS REENVIADOS SE DA POR TERMINADO EL SP
    IF  iEnviados>=iReintentos THEN
        RETURN sCodSp;
    END IF;

  --OBTENIENDO LOS MINUTOS QUE HAN TRANSCURRIDO DEL ULTIMO MENSAJE
    SELECT CURRENT-MIN(fecha) INTO sDiferencia
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND DATE(fecha)=DATE(current) AND digito_ver = pdigito_ver;

    IF LENGTH(TRIM(sDiferencia))=16 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 8 for 2) INTO iMinTrans FROM si_fechas;
    ELIF LENGTH(TRIM(sDiferencia))=15 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 7 for 2) INTO iMinTrans FROM si_fechas;   
    ELSE
        select SUBSTRING((TRIM(sDiferencia))  from 6 for 2) INTO iMinTrans FROM si_fechas;   
    END IF;

   --SI LOS MINUTOS OBTENIDOS SON MENORES AL RANGO ESTABLECIDO NO SE ENVIA MENSAJE
   IF iMinTrans<iMinutos THEN
      RETURN sCodSp;
   END IF;

        --IF EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL) THEN
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            --
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels WHERE numcte = pnumcte AND telefono = ptelefono;
            
            UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut='REENVIO SMS'
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        ELSE
            INSERT INTO bdinteg:"informix".si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono,'REENVIO SMS', current);
        END IF;

            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);

            EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL3','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;
            
            --***ATENCION DEL RQI 63 421***--
                --EXTRAYENDO EL E-MAIL DEL CLIENTE
                SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
                IF NVL(sCorreo,'')<>'' THEN
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
                END IF;
            --***ATENCION DEL RQI 63 421***--
        
END IF;  
       RETURN sCodSp;
	END
END PROCEDURE;