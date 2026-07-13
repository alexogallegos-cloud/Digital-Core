CREATE PROCEDURE "informix".sp_importarcofetel()
	
	--DATOS A REGRESAR
	RETURNING CHAR(5);

	--DEFINICIÓN DE VARIABLES
	DEFINE cCodret 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cSql 	CHAR(200);
	DEFINE cRuta 	VARCHAR(200);
	DEFINE vExiste	INTEGER;

	--INICIALIZA VARIABLES
	LET cCodret ='000';
	LET iSqlErr = 0;
	LET cSql 	= '';
	LET cRuta 	= '';
	LET vExiste = 0;

	--SET DEBUG FILE TO "/resplogifx/telefonos/sp_importarcofetel.out";
	--RACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;

		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		SELECT TRIM(valor)
		INTO cRuta
		FROM bdinteg:"informix".si_param
		WHERE cod_param = "58";

		if (cRuta IS NULL) OR (cRuta = '') THEN

			LET cCodret = '001';

		END IF;

		--- VERIFICA SI EXISTE LA TABLA TEMPORAL PARA BORRARLA
		SELECT count(*) 
		into vExiste 
		FROM "informix".tmp_si_cattelefono;

		IF (vExiste > 0) THEN

			LET cSql = '';
			LET cSql = 'echo "unload to  '|| cRuta || 'resp_telefonos.unl' || ' SELECT * FROM tmp_si_cattelefono" > ' || cRuta || 'instruccion1.sql';
			SYSTEM cSql;
			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'resp_telefonos.unl';
			SYSTEM cSql;

			truncate table "informix".tmp_si_cattelefono;

		END IF;

		LET cSql = '';
		LET cSql = 'echo "LOAD FROM '|| cRuta || 'telefonos.sql' || ' DELIMITER ' || '''|''' || ' INSERT INTO tmp_si_cattelefono" > ' || cRuta || 'instruccion.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql = "chmod 777 " || cRuta || 'instruccion.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion.sql';
		SYSTEM cSql;

		RETURN cCodret;

	END
END PROCEDURE

DOCUMENT
'REALIZO:	Carmén Orozco',
'FECHA:		27-12-2008',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Mohamed Carreón',
'FECHA:		17-02-2009',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  temporal tmp_si_cattelefonos y no a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Frank Gaxiola',
'FECHA:		17-11-2009',
'FUNCION:	Se modifica para que la ruta del servidor sea tomada de un parametro',
'BDD:		bdinteg',

'MODIFICO:	Daniela Ramírez',
'FECHA:		31-01-2012',
'FUNCION:	Se aplican reglas de informix',
'BDD:		bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_sucursales_nuevas(dFecha DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5)  AS Cod_Retorno,
			  CHAR(4)  AS No_Sucursal,
			  CHAR(40) AS Nom_Sucursal,
			  CHAR(40) AS Plaza;

DEFINE cCodRet      CHAR(5);
DEFINE iSql_err 	INT;
DEFINE No_Sucursal  CHAR(4);
DEFINE Nom_Sucursal CHAR(40);
DEFINE iCont        INT;
DEFINE cPlaza       CHAR(40);

--inicializando variables
LET cCodRet 	    = "00000";
LET iSql_err 	    = 0;
LET No_Sucursal	    = '';
LET Nom_Sucursal    = '';
LET iCont           = 0;
LET cPlaza          = '';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza;
		END IF;
	END EXCEPTION;

	  --SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_sucursales_nuevas.out";
	  --TRACE ON;

	IF dFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
		LET cCodRet = '00003';
		RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza;
	END IF;
		
	-- VALIDACION DE LA PAGINACION
	IF pRegistros < 0 OR pRecuperacion < 0 THEN
		LET cCodRet = '00098';
		RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza;
	END IF;
	  
	SET ISOLATION TO DIRTY READ;
    FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion ss.sucursal, ss.nombre, sp.nombre AS plaza
		INTO No_Sucursal,Nom_Sucursal, cPlaza
		FROM "informix".si_sucursales ss, "informix".si_plazas sp
		WHERE sp.plaza = ss.plaza
		AND tpo_sucursal = 'S'
		AND ss.fecha_insert >= dFecha

        LET iCont = iCont + 1;
        RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza WITH RESUME;
    END FOREACH;
	
	IF iCont = 0 AND pRegistros = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza;
	ELIF iCont = 0 AND pRegistros > 0 THEN
		LET cCodRet = '1001';
		RETURN cCodRet, No_Sucursal, Nom_Sucursal, cPlaza;
	END IF;   

END
END PROCEDURE
DOCUMENT
'Autor: VHSM',
'FUNCIONAMIENTO: Consulta sucursales nuevas para actualizar catalogo',
'FECHA : 20-11-2012',
'VER   : 1.0',
'FECHA MODIFICACION: 29/04/2013',
'MODIFICACIÓN: Se agrega el nombre de la plaza de la sucursal',
'AUTOR: M.D.S. Sandra Cano',
'FECHA: 25/11/2016',
'DESCRIPCION: Se agrega filtro para obtener registros de tipo Sucursal',
'AUTOR: Martha Salgado',
'FECHA: 01/12/2016',
'DESCRIPCION: Se agrega paginado',
"BD: bdinteg";

CREATE PROCEDURE "informix".ctefisico( pEmpresa CHAR(3),
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
                                       pEmail CHAR(100),
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
                                       pNumhabitantes CHAR (60) )
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
DEFINE cEmail 				CHAR(100);
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

LET cCodret 			= "000";
LET cCodret2 			= '000';
LET cEmpresa 			= pEmpresa;
LET cNumcte 			= " ";
LET cSucursal 			= pSucursal;
LET cTppersona 			= pTp_persona;
LET cNumcte_ref 		= " ";
LET cEjecut_autoriza 	= pEjecut_autoriza;
LET iOrigen 			= 0; --sin informacion
LET cTipoRel			='0';
LET cCodRet3            = "00000";
LET cMensajeRet         = "Se realizÃÂ³ la consulta correctamente";

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

        IF SUBSTRING(cRfc FROM 1 FOR 10) <> SUBSTRING(pCurp FROM 1 FOR 10) THEN
				INSERT INTO bdinteg:"informix".si_bitacora_cambio_curp
                ( numcte, rfc, curp, resultado, fecha )
				VALUES
                ( pNumcte, cRfc, pCurp, '03', CURRENT );

				--LET pCurp = cCurp;
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
        foreach
            SELECT limit 1 1
                INTO cExiste
            FROM bdinteg:"informix".si_usuario_movil
            WHERE ejecutivo=pEjecutivo
        end foreach;

        IF cExiste IS NULL THEN
            LET cCodret = "112";
            RETURN cCodret,cNumcte;
        END IF;
    END IF;

    SELECT 1
      INTO cExiste
      FROM bdinteg:"informix".si_sector
     WHERE sector=pSector;

    IF cExiste IS NULL THEN
        LET cCodret = "113";
        RETURN cCodret,cNumcte;
    END IF;

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

    IF cExiste IS NULL THEN
        LET cCodret = "124";
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
        LET cCodret = "106";
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
            LET cCodret = "133";
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
          numeric1, numeric2, money1, DATE1, puesto_ppes, familiar_ppes, actividad_esp, ejecut_autoriza, user_insert, fecha_insert )
        VALUES
        ( pEmpresa, cNumcte, "AL", pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, pNombre2, " ",
          pRfc, pSector, pSegmento, pActividad_princ, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumcte_ref, "", pNumhabitantes,
          0, 0, 0, "", pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pEjecut_autoriza, pEjecutivo, dFecha );

        INSERT INTO bdinteg:"informix".si_ctepf
        ( numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss,
          dependientes, tutor, nom_conyuge, empresa, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, string1, sms_cel )
        VALUES
        ( cNumcte, pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss,
          pDependientes, pTutor, pNom_conyuge, pEmpresa, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pPromocion, '0' );

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
            LET cCodret = "104";
            RETURN cCodret,cNumcte;
        END IF;

        BEGIN

        IF pSucursal ='0010' OR pSucursal ='0012' OR pSucursal ='0034'
            OR pSucursal ='0131' OR pSucursal ='0164' OR pSucursal ='0623' OR pSucursal ='0638' OR pSucursal ='1213' THEN
            
            IF EXISTS(SELECT * FROM si_solicitud_movil WHERE numcte=cNumcte AND folio_procesado=0 AND status_valua=1) THEN
                SELECT escolaridad, tipo_residencia, pers_domicilio 
                    INTO pEscolaridad, pHabita_en, pNumhabitantes
                    FROM si_solicitud_movil WHERE numcte=cNumcte AND folio_procesado=0;
				
				LET pEscolaridad="0"||pEscolaridad;
				
            END IF;
        END IF;

        -- Se Desactiva por Requerimiento de Bancoppel JLP 18/09/07
        UPDATE bdinteg:"informix".si_cliente
           SET ( ejecutivo, tpo_persona, tipo_cliente, --- apell_paterno, apell_materno, nombre1, nombre2, rfc, sectOR, segmento, actividad_esp,
                 sectOR, segmento, actividad_esp, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, string2 ) =
               ( pEjecutivo, pTp_persona, pTp_cliente, --- pPaterno, pMaterno, pNombre1, pNombre2,
                 pSector, pSegmento, pActividad_esp, pGrupo, pSubgrupo, pResidencia, dFecha, pApell_casada, pDistrito, pNumhabitantes)
        WHERE numcte = cNumcte;


        UPDATE bdinteg:"informix".si_ctepf
           SET ( fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo,
                 curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge,
                 seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, sms_cel ) =
               ( pFecha_nac, pLugar_nac, pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo,
                 pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pNom_conyuge,
                 pSeguro_defunc, pEscolaridad,pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, '0' )
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
"MODIFICACION:Se modifica para que realice el insert a la tabla de si_relacion_ctebcplcpl por medio de el", "sp_relacion_generarelacion en lugar de aserlo por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Zazueta Acosta Josue Remberto",
"FECHA : 15/Agosto/2012",
"MODIFICACION: Se Modifica Origen de la relacion de clientes, se quita el origen por medio de alta unica",
"BD    : bdinteg",
"VER   : 1.1",
"MOFIDICION     : Martin Eduardo Miranda",
"FECHA        : 26/Abril/2013",
"MODIFICACION : Se modifica Procedimiento Almacenado para comentar la linea 'LET pCurp = cCurp'",
"               * Se aplican reglas de programaciÃÂ³n.",
"MOFIDICION     : Claudio Almodovar",
"FECHA        : 29/10/2014",
"cCodret  200 : parametros vacios para opcion 'S'",
"cCodret  210 : cliente no existe en bdinteg:si_cliente",
"cCodret  220 : cliente no existe en bdinteg:si_ctepf",
"MODIFICACION : Se modifica para agregar la opcion 'S' para pFuncion y se comenta donde pFm3 toma valor si es vacio o null";

CREATE PROCEDURE "informix".ctefisico_val_cor
(
     pEmpresa CHAR(3),pFuncion CHAR(1),pNumcte CHAR(20),pSucursal CHAR(4),pEjecutivo CHAR(8),pTp_persona CHAR (2),pTp_cliente CHAR(1),pPaterno CHAR (26),pMaterno CHAR (26),pNombre1 CHAR (26),pNombre2 CHAR (26),pRfc CHAR (13),pSector CHAR (2),pSegmento CHAR (3),pActividad_princ CHAR (3),pGrupo CHAR(3),pSubgrupo CHAR(3),pResidencia CHAR(1),pApell_casada CHAR(20),pNumcte_ref CHAR(20),pDistrito CHAR(2),pPuesto_ppes CHAR(1),pFamiliar_ppes CHAR(1),pActividad_esp CHAR(11),pFecha_nac DATE, pLugar_nac CHAR (2),pNacionalidad CHAR(3),pFm3 CHAR(18),pEstado_civil CHAR(1),pRegimen_mat CHAR(1),pProfesion CHAR (3),pSexo CHAR(1),pCurp CHAR(20),pCodidentif CHAR(2),pNumidentif CHAR(30),pNo_imss CHAR(12),pDependientes SMALLINT,pTutor CHAR(60),pEmail CHAR(100),pNom_conyuge CHAR(60),pSeguro_defunc CHAR(1),pEscolaridad CHAR(2),pHabita_en CHAR(20),pAnios_habita SMALLINT,pNombre_prop CHAR(60),pImphiporenta MONEY(14,2),pNumeroife CHAR(20),pNumerotutor CHAR(20),pNumeroconyuge CHAR(20),pEjecut_autoriza CHAR(8),pPromocion CHAR(2),pNumhabitantes CHAR (60),pStatusCode CHAR(3)
)
RETURNING  CHAR(5) AS Codret,  CHAR(20) AS Numcte;

DEFINE cCodret CHAR(5);
DEFINE cCodret2 CHAR(5);
DEFINE cNumcte CHAR(20);
DEFINE cNumcte_referencia CHAR(20);
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

	 --SET DEBUG FILE TO '/respaldosbd/mario/ctefisico_val_cor.out';
	 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	EXECUTE PROCEDURE bdinteg:"informix".ctefisico (pEmpresa,pFuncion,pNumcte,pSucursal,pEjecutivo,pTp_persona,pTp_cliente,pPaterno,pMaterno,pNombre1,pNombre2 ,pRfc ,pSector,pSegmento,pActividad_princ,pGrupo,pSubgrupo,pResidencia,pApell_casada,pNumcte_ref,pDistrito,pPuesto_ppes,pFamiliar_ppes,pActividad_esp,pFecha_nac, pLugar_nac ,pNacionalidad,pFm3,pEstado_civil,pRegimen_mat,pProfesion,pSexo,pCurp,pCodidentif,pNumidentif,pNo_imss,pDependientes,pTutor,'',pNom_conyuge ,pSeguro_defunc ,pEscolaridad,pHabita_en,pAnios_habita,pNombre_prop,pImphiporenta,pNumeroife,pNumerotutor,pNumeroconyuge,pEjecut_autoriza,pPromocion,pNumhabitantes)
	INTO cCodret,cNumcte;
	
	IF pEmail IS NOT NULL OR pEmail <> '' THEN
		EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos_valcor ( pEmpresa, cNumcte, pEmail, 1, 1, pEjecutivo,pStatusCode)
		INTO cCodret2;
	END IF;
		
	RETURN cCodret, cNumcte;
END;    
END PROCEDURE
DOCUMENT
"Folio:1581",
"Autor:95142134 Mario Gallardo",
"Fecha:19/02/2014",
"Modificación: Se crea copia de procedimiento almacenado para guardar respuesta de el web service Strike Iron.",
"Sustento: RQI 63 044 - Valida Correo Alta Clientes Bancoppel.pdf",
"Solicita: Jaime González Prado",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_validacombinacion(param1 CHAR(3), param2 CHAR(3), param3 CHAR(3), param4 CHAR(3))
   RETURNING CHAR(9), CHAR(1000);
   
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cDescripcion 	  CHAR(1000);
   DEFINE n1 	  CHAR(3);
   DEFINE n2 	  CHAR(3);
   DEFINE ap 	  CHAR(3);
   DEFINE am 	  CHAR(3);
   
   LET cCodRet 		      = '00001';   
   LET cDescripcion	      = 'Combinacion No valida';
   
   LET n1 	   = '';  
   LET n2 	   = '';  
   LET ap 	   = '';  
   LET am 	   = '';  
      
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cDescripcion;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/combinacion/sp_validacombinacion.out";
	--TRACE ON;
				
	FOREACH
		SELECT nombre1, nombre2, ape_pat, ape_mat INTO n1, n2, ap, am FROM COMBINACIONESNOMBRE
		
		IF param1 = n1 AND param2 = n2 AND param3 = ap AND param4 = am THEN
			LET cCodRet = '00000';
			LET cDescripcion = 'Combinacion Correcta';
		END IF;													  
	
	END FOREACH;		
	
	RETURN cCodRet, cDescripcion;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Elmer López Valenzuela',
'FECHA: 15/09/2016',
'BD: BDINTEG',
'Objetivo: Se crea procedimiento para validar la combinación de nombres que selecciono el cliente';

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta3(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)

                    returning CHAR(5)  AS Cod_Retorno,
                                DATE     AS Fecha,
                                DATETIME HOUR to FRACTION(3) AS Hora,
                                CHAR(4)  AS CveTransaccion,
                                CHAR(50) AS Desc_Transaccion,
                                CHAR(16) AS Folio,
                                DATE     AS Periodo_Inicial,
                                MONEY(14,2) AS Monto,
                                DATE     AS Periodo_Final,
                                CHAR(20) AS Sistema_Cuenta,
                                CHAR(1)  AS Naturaleza,
                                CHAR(40) AS Referencia,
                                CHAR(1)  AS Reversos,
                                CHAR(4)  AS Sucursal,
                                CHAR(20) AS CveProcedencia,
                                CHAR(50) AS Desc_Procedencia,
                                MONEY(14,2) AS Saldo,
                                CHAR(20) AS Numero_Tarjeta,
                                CHAR(1)  AS Reversados,
                          CHAR(8)  AS Usuario,
                                CHAR(23) AS Referencia23;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
DEFINE iKiosko			INT;
DEFINE iAbierto			INT;

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET  iExisteCta = 0;
LET iKiosko               =0;
LET iAbierto              =0;


BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
     END EXCEPTION;
                

	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3; 

    --SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta3.out";
    --TRACE ON;
              
     IF cID_USUARIOC = ''      OR
        cID_FUNCIONC = ''      OR
        cNUMCUENTA  = ''     OR
        dPERIODOI   IS NULL OR
        dPERIODOF      IS NULL     OR
        cSISTEMACUENTA = '' THEN
        LET cCodRet = "00036";
        RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
        cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
    END IF; 
     IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
          LET cCodRet = "00037";
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

     --VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
			  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;
     -- TERMINA VALIDACION
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN
	IF pNumRegistro = 0 THEN
		DELETE FROM "informix".si_tempomovs WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA;
        SET ISOLATION TO DIRTY READ;
		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		SELECT valor
		INTO cconsmovhisold2
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld2';

		SELECT valor
		INTO cconsmovhisold3
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'vfechconmovhisold3';
		
		SELECT valor
		INTO cconsmovhisold4
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld4';
		
		LET iAbierto = 1;
		IF dPERIODOF = TODAY THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movdia MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
						
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
			MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:"informix".sc_movhis_old2 MO
			LEFT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;

		SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX (bdicheq:sc_maechq idx_sc_maechq)} NVL(COUNT(cuenta),0) 
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		
		IF iExisteCta = 0 THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old3 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
			IF (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD
				SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,MO.num_tarjeta,MO.usuario,MO.referencia_23
				INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
				FROM bdicheq:"informix".sc_movhis_old4 MO
				LEFT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
				
				LET iCont=iCont+1;
				
				INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
					sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
				VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
					mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
				IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				END FOREACH;
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			SELECT MO.fecha_alt as fech_alt,extend(MO.fech_hor_fin,HOUR to FRACTION(3)),MO.transacc,TR.descripcion,MO.monto,DECODE(MO.tpo_mov,"D","A","C","C"),
			MO.sdo_cuenta_origen,MO.referencia,'','',MO.secuencia,'','TRANSFER',''
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			cNumtarjeta,cUsuario,cReferencia23
			FROM bditransfer:tf_success_transac  MO
			LEFT JOIN bditransfer:tf_cat_transac_mps TR
			ON MO.transacc = TR.transac
			WHERE MO.cuenta = cNUMCUENTA
			AND MO.fecha_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.fecha_alt < to_date('20/03/2015','%d/%m/%Y')
			
			LET iCont=iCont+1;
			
			INSERT INTO "informix".si_tempomovs (codret, ejecutivosif, no_cuenta, fech_alt, fech_hor, transacc, descripcion, monto_tot, naturaleza, 
				sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_serial, num_tarjeta, usuario, referencia_23) 
			VALUES (cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,
				mSaldo,cReferencia,cReversos,cSucursal,cFolio,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23);
			IF iCont >= 1000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
			END IF;
			END FOREACH;
		END IF;
		
		IF iAbierto = 1 THEN
			LET iAbierto = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
		LET iCont = 0;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH RESUME;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
	ELSE
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_tempomovs idx_tempomovs)} SKIP pNumRegistro FIRST pRecuperacion codret, ejecutivosif, no_cuenta, fech_alt, 
			fech_hor, transacc, descripcion, monto_tot, naturaleza, sdo_cuenta, referencia, cancelad, sucursal, folio_suc, num_tarjeta, usuario, 
			referencia_23
			INTO cCodRet,cID_USUARIOC,cNUMCUENTA,dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
				cNumtarjeta,cUsuario,cReferencia23
			FROM "informix".si_tempomovs
			WHERE ejecutivosif = cID_USUARIOC AND no_cuenta = cNUMCUENTA
			ORDER BY fech_alt DESC,fech_hor DESC
			
			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia 
				WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			
			
			LET iCont=iCont+1;
			
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
		END FOREACH;
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPERIODOI,mMonto,dPERIODOF,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
	END IF;
		
	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SET ISOLATION TO DIRTY READ;
		SELECT NVL(COUNT(num_credito),0) 
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;		

		IF iExisteCta > 0 THEN
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END                    
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELSE

				SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
				SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';
 

				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		ELSE
			FOREACH
				SELECT SKIP pNumRegistro FIRST pRecuperacion MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				INTO          
				cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
				dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			UNION
				SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
				MO.transacc_suc,TR.descripcion,MO.referencia,
				MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
			ORDER BY MO.secuencia DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			  
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELSE
				SELECT transacc INTO cTransaccion FROM bdicred:sd_transfun WHERE codigo_fun=cCodfun AND codigo_ref=cCodref;
				SELECT descripcion,naturaleza INTO cD_Transaccion,cNaturaleza FROM bdinteg:si_transacc WHERE numero=cTransaccion AND sistema='06';

				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;

			END FOREACH;
		END IF;
						
		IF iCont = 0 AND pNumRegistro=0 THEN
		   LET cCodRet = '00039';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
		   LET cCodRet = '1001';
				RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
						cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
	 SET ISOLATION TO DIRTY READ;
	  FOREACH
		   SELECT SKIP pNumRegistro FIRST pRecuperacion     
		   MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   INTO
		   dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,cUsuario,sNUMSERIAL
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movdia MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		   UNION
		   SELECT MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
		   FROM bdinvers:sv_maeinv MC
		   LEFT JOIN bdinvers:sv_movhis MO
		   ON MC.cuenta = MO.cuenta
		   LEFT JOIN bdinteg:si_transacc TR
		   ON MO.transacc = TR.numero 
		   WHERE MO.cuenta = cNUMCUENTA
		   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
		AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
		AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END     
		ORDER BY MO.num_serial DESC

		LET iCont=iCont+1;    
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			   
	  END FOREACH;

	  IF iCont = 0 THEN
	  LET cCodRet = '1001';
		   RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	  END IF
	END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo Sánchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"ACTUALIZO: Oscar Flores Conde (M-Finis Soluciones y Servicios Financieros)",
"MODIFICACION: Se agregaron el parametro de entrada para filtrar los movimientos reversados, se agrega en los parametros de salida la referencia a 23 posiciones",
"FECHA: 02/12/2013",
"BD    : bdinteg",
"VER   : 3.0";

CREATE PROCEDURE "informix".sp_obtienecorreos(pTipo CHAR(1),pRegistros INTEGER, pNumcte CHAR(20), pCorreo CHAR(100), pValida CHAR(3))
	RETURNING 	CHAR(5)  AS cCodRet,
				CHAR(20) AS cNumCte, 
				CHAR(100) AS cEmail;

				
--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumCte 		CHAR(20);
DEFINE cEmail 		CHAR(100);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cEmail 			= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/cristo/sp_obtienecorreos.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	
		
	IF 	pTipo = '1' THEN-- Obtener los correos a validar
		IF (pRegistros IS NULL OR pRegistros = 0) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
			RETURN cCodRet, cNumCte,cEmail;
		ELSE
			
			FOREACH
				 
				SELECT {+MULTI_INDEX("informix".si_correos)} FIRST pRegistros numcte, correo_elec INTO cNumCte, cEmail
				FROM "informix".si_correos
				WHERE status_correo ='A' AND valida_correo IS NULL
				ORDER BY fecha_hora DESC
				
				RETURN cCodret , TRIM(cNumCte), TRIM(cEmail) WITH RESUME;
				
			END FOREACH;	
			
		END IF;
	ELIF pTipo = '2' THEN  -- Actualizar registro de correo validado por webservice strikeiron
		IF ((pNumcte IS NULL OR pNumcte = '') OR (pValida IS NULL OR pValida = '')) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
		ELSE
			
			IF pValida IN ('200','210','220') THEN -- Se valida que el codigo de retorno indique correo valido
				UPDATE "informix".si_correos SET valida_correo = pValida, valido='1',fecha_valida = current WHERE numcte = pNumcte AND status_correo='A' AND TRIM(correo_elec)=TRIM(pCorreo);
			ELSE
				UPDATE "informix".si_correos SET valida_correo = pValida, valido='0',fecha_valida = current WHERE numcte = pNumcte AND status_correo='A' AND TRIM(correo_elec)=TRIM(pCorreo);
			END IF;
				
			
		END IF;
		
		RETURN cCodRet, cNumCte,cEmail; 
	ELSE
		LET cCodRet = '00002';	--Valor de parametro pTipo no valido
		RETURN cCodRet, cNumCte,cEmail;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los correo aun sin validar para ser evaluados por webservice strikeiron',
'permite realizar la actualizaciÃÂ³n de los campos valida_correo y valido',
'AUTOR : Cristo Lugo',
'FECHA : 27-05-2014',
'VERSION: 20140527.1000',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_detalle_boletos (pClaveSort CHAR(5), pFechaActual DATE)
RETURNING CHAR (5) AS Codigo, CHAR(5) AS Clave_Sorteo, CHAR (80) AS Mensaje;

--- DECLARACION DE VARIABLES

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
	DEFINE vconsecutivo 	INTEGER;
    DEFINE vCodret          CHAR(5);
    DEFINE vCveSorteo       CHAR(5);
    DEFINE vMensaje         CHAR(80);

    DEFINE vF_Proceso       DATE;
    DEFINE vEmpresa         CHAR(3);
    DEFINE vCve_Sorteo      CHAR(5);
    DEFINE vF_ini           DATE;
    DEFINE vF_Fin           DATE;

    DEFINE vNumcte          CHAR(10);
	  DEFINE iNumcte          INTEGER;

    DEFINE vCve_Sort        CHAR(5);
    DEFINE vBoleto_ini      INT8;
    DEFINE vBoleto_Fin      INT8;
    DEFINE vF_registro      DATETIME YEAR TO SECOND;
    DEFINE vNumCliente      CHAR(10);
    DEFINE vEstado          INTEGER;
    DEFINE vSucursal        CHAR(4);
    DEFINE vArea            CHAR(1);
    DEFINE vCaja            INTEGER;
    DEFINE vTipomov         CHAR(10);
    DEFINE vFoliosuc        CHAR(16);
    DEFINE vImporte         MONEY;
    DEFINE vTel1            CHAR(10);
    DEFINE vTel2            CHAR(13);
    DEFINE vNombre          CHAR(45);
    DEFINE vCiudad          CHAR(20);
    DEFINE vDomicilio       CHAR(50);
	DEFINE vEntfed		    CHAR(25);
    DEFINE vFecha           DATE;
    DEFINE vOrigen          CHAR(10);
    DEFINE vSecuencia       INTEGER;
    DEFINE vLimite          INTEGER;
    DEFINE vContador        INTEGER;
    DEFINE vContSecuencia   INTEGER;

    DEFINE cCodRet          CHAR(3);
    DEFINE v_Valor          CHAR(5);
	  --DEFINE vrowid       	  INTEGER;
	  DEFINE vCuentaBoletos   INTEGER;
	  DEFINE vCuentaEmpleados INTEGER;


--- INICIALIZACION DE VARIABLES

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET vCodret         = '00000';
    LET vCveSorteo      = pClaveSort;
    LET vMensaje        = 'El proceso concluyÃ³ exitosamente';

    LET vF_Proceso      = '';
    LET vEmpresa        = '001';
    LET vCve_Sorteo     = '0';
    LET vF_ini          = '';
    LET vF_Fin          = '';

    LET vNumcte         = '';

    LET vCve_Sort       = '';
    LET vBoleto_ini     = '';
    LET vBoleto_Fin     = '';
    LET vF_registro     = '';
    LET vNumCliente     = '';
    LET vEstado         = '';
    LET vSucursal       = '';
    LET vArea           = '';
    LET vCaja           = '';
    LET vTipomov        = '';
    LET vFoliosuc       = '';
    LET vImporte        = 0.00;
    LET vTel1           = '';
    LET vTel2           = '';
    LET vNombre         = '';
    LET vCiudad         = '';
    LET vDomicilio      = '';
	LET vEntfed			= '';
    LET vFecha          = '';
    LET vOrigen         = '';
    LET vSecuencia      = '';
    LET vLimite         = 0;
    LET vContador       = 0;
    LET vContSecuencia  = 1;
	LET vconsecutivo 	= 1;

    LET cCodRet          = '';
    LET v_Valor          = '';
	  --LET vrowid      	   = 0;
	  LET iNumcte      	   = 0;
	  LET vCuentaBoletos   = 0;
	  LET vCuentaEmpleados = 0;



     --****************************************************************
     -- Creado por RaÃºl RamÃ­rez    01/Septiembre/2010
     -- Proceso para traducir rangos de boletos a un detalle de boletos
     --****************************************************************


BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET vCodret   = sql_err;
            LET vCodret   = '00045';
            LET vMensaje  = 'ERROR EN LA EJECUCION';
            RETURN vCodret, vCveSorteo, vMensaje;        -- Termina proceso del SP
        END IF;
    END EXCEPTION;
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = vCveSorteo AND pFechaActual -1 BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        --SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_detalle_boletos.out";
        --TRACE ON;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				LET vF_Proceso = pFechaActual -1;

				SELECT {+INDEX(si_param ix_si_param)} valor
				INTO v_Valor
				FROM bdinteg:si_param
				WHERE empresa = vEmpresa
				AND cod_param = 118;

				SELECT {+INDEX (si_sorteo idx_si_sorteo2)} cve_sorteo, f_ini, f_fin
				INTO vCve_Sorteo, vF_ini, vF_Fin
				FROM bdinteg:si_sorteo
				WHERE cve_sorteo = v_Valor;


				IF (v_Valor IS NULL OR v_Valor = '') OR -- Valida clave sorteo vigente
				   (v_Valor <> pClaveSort) THEN
					 LET vCodret = '00040';
					 LET vMensaje = 'NO EXISTE SORTEO';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
				ELSE
					IF (vF_ini IS NULL OR vF_ini = '') OR      -- Valida fecha sorteo vigente
					   (vF_Fin IS NULL OR vF_Fin = '') OR
					   (vF_Proceso NOT BETWEEN vF_ini AND vF_Fin) THEN
						  LET vCodret = '00042';
						  LET vMensaje = 'SORTEO NO ESTA VIGENTE?';
						RETURN vCodret, vCveSorteo, vMensaje;    -- Termina proceso del SP
					END IF;
				END IF;

				-- BGM 11-Nov-2010: Se agrega depuraciÃ³n de tabla si_boleto_temp
				TRUNCATE si_boleto_temp;
				
				EXECUTE PROCEDURE "informix".sp_movtos_reversados ('001')
						INTO cCodRet;
				
				--FOREACH

					---SELECT {+INDEX (si_movreversados idx_si_movrever)} empresa, fecha_mov, folio_suc
				--	SELECT {+FULL} empresa, fecha_mov, folio_suc
				--	INTO vEmpresa, vFecha, vFoliosuc
				--	FROM bdinteg:si_movreversados
				--	WHERE empresa = vEmpresa
				--	AND folio_suc <> ''
					
				--	IF EXISTS (SELECT {+INDEX (bdinteg:si_boleto idx_si_boleto)} foliosuc 
				--	           FROM bdinteg:si_boleto 
				--		         WHERE cve_sorteo = vCve_Sorteo
				--          AND foliosuc = vFoliosuc
				--           AND fecha = vFecha) THEN
						
				--			UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist
				--			SET estado = '101'
				--			WHERE cve_sorteo = vCveSorteo
				--			AND   foliosuc = vFoliosuc
				--			AND   fecha = vFecha;

							--DELETE {+INDEX (si_boleto idx_si_boleto)} FROM bdinteg:si_boleto
							--WHERE cve_sorteo = vCveSorteo
							--AND   foliosuc = vFoliosuc
							--AND   fecha = vFecha;
				--	END IF;
					
				--END FOREACH;
				
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist2)} bdinteg:si_boleto_hist set estado = 101 
				WHERE foliosuc in (SELECT folio_suc FROM si_movreversados) 
				AND fecha = vF_Proceso;
					
				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist3)} bdinteg:si_boleto_hist set estado = 101 
				WHERE numcte in (SELECT numcte FROM si_syssorteo_emp)
				AND fecha = vF_Proceso;
				
				--SELECT {+FULL} COUNT(*) into vCuentaBoletos FROM si_boleto;
				--SELECT {+FULL} COUNT(*) into vCuentaEmpleados FROM si_syssorteo_emp;

				--IF vCuentaBoletos <= vCuentaEmpleados THEN
				
				--	FOREACH
					
				--		SELECT {+FULL} numcte
				--		INTO iNumcte
				--		FROM bdinteg:si_boleto
						
				--		IF EXISTS (SELECT {+INDEX (si_syssorteo_emp idx_si_syssorteo_emp)} numcte
				--				FROM si_syssorteo_emp
				--				WHERE tipo IN (2 , 4) 
				--                                    AND status = 'A'
				--                                    AND numcte = iNumcte) THEN
								
				--				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} si_boleto_hist
				--				SET estado = '101'
								---WHERE numcte::INT = iNumcte;
				--				WHERE numcte = iNumcte;
				--		END IF;
					
				--	END FOREACH;
					
				--ELIF vCuentaBoletos > vCuentaEmpleados THEN
				
				--	FOREACH
				
				--		SELECT {+FULL} numcte
				--		INTO iNumcte  
				--		FROM si_syssorteo_emp
						
				--		IF EXISTS (SELECT {+INDEX (bdinteg:si_boleto idx_idx_si_boleto6)} numcte 
				--				FROM bdinteg:si_boleto 
								--WHERE numcte::INT = iNumcte) THEN
				--				WHERE numcte = iNumcte) THEN
							
				--				UPDATE {+INDEX (si_boleto_hist idx_si_boleto_hist4)} bdinteg:si_boleto_hist
				--				SET estado = '101'
								---WHERE numcte::INT = iNumcte;
				--				WHERE numcte = iNumcte;
				--		END IF;
							
				--	END FOREACH;
					
				--END IF;
				
				FOREACH cursor_inserta WITH HOLD FOR
								
						SELECT {+INDEX (si_boleto_hist idx_si_boleto_hist2)}
								cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov,
								foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed
						INTO  vCve_Sort, vBoleto_Ini, vBoleto_Fin, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
						  vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vSecuencia, vEntfed
						FROM bdinteg:si_boleto_hist
						WHERE cve_sorteo =  vCveSorteo
						AND foliosuc <> ''
						AND fecha = vF_Proceso
						AND estado = 2
						
						LET vLimite = vBoleto_Fin;
						BEGIN WORK;
							FOR vContador = vBoleto_Ini TO vLimite
								INSERT INTO si_boleto_temp(cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov,
											foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed, consecutivo)
								VALUES (vCve_Sort, vContador, vF_registro, vNumCliente, vEstado, vSucursal, vArea, vCaja, vTipomov,
										vFoliosuc, vImporte, vTel1, vTel2, vNombre, vCiudad, vDomicilio, vFecha, vOrigen, vContSecuencia, vEntfed, vconsecutivo);
								LET vContSecuencia = vContSecuencia + 1;
								LET vconsecutivo = vconsecutivo +1;
							END FOR

							LET vContSecuencia = 1;
							COMMIT WORK;                           
						   
				END FOREACH;

			  -- BGM 11-Nov-2010: Se agrega depuraciÃ³n de tabla si_boleto;
				TRUNCATE si_boleto;
				TRUNCATE si_movreversados;
	
	ELSE
		LET vCodret = "22222";
        LET vMensaje = "Â¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
	END IF;	
		  
END
    RETURN vCodret, vCveSorteo, vMensaje;

END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_respaldo_boletos (pClaveSort CHAR(5), pdFechaRespaldo DATE)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;              


   DEFINE v_codigo_retorno	CHAR(5);
   DEFINE v_mensaje	  	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);

   DEFINE vi_valor      CHAR (50);

   DEFINE vsqlerr      INTEGER; 
   DEFINE pdrepositorio CHAR (60);
   

    DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (40);
	DEFINE vsSQL CHAR (1100);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (700);
	DEFINE vsSQL3 CHAR (200);


       -- SET debug file TO "/ids10_1uc5/fmartinez_2/sorteo/batch_30nov/pba1/respalda_boletos.out";
       -- TRACE ON;

	
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';



-- DECLARACION DE VARIABLES
             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente...";
             LET v_reverso = '0';
             LET v_store_pro = 'sp_respaldo_boletos';
     
        	 LET vsNomArchivo = 'RESPALDOSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.unl' ;


            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exception, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_respalda_boletos';
         RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
   END EXCEPTION;
   
   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2 Y ESTE ACTIVO EL SORTEO*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = pClaveSort AND pdFechaRespaldo BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        
		-- FMV 16-DIC-2010: La ruta del archivo serÃ¡ la misma
				 SELECT {+index (si_param 194_429)}  
						   valor
				   INTO vi_valor
				   FROM si_param
				   WHERE empresa = '001'
					 AND cod_param = '112';
					IF NOT EXISTS (SELECT {+index (si_param 194_429)} valor
									 FROM si_param
									WHERE empresa = '001' AND cod_param = '112')
					  THEN
							LET v_codigo_retorno = "00042";
							LET v_mensaje = "Error: No Existe ruta de deposito!";
						RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
					END IF;
					LET pdrepositorio = vi_valor;


		 
			LET vsArchTemporal = 'temporal.txt';
					LET vsNomArchivo = 'BACKUPSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.txt' ;

					--GENERA EL ARCHIVO DE INTERCAMBIO
					LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''|''';



					LET vsSQL2 = "SELECT {+ INDEX (bdinteg:si_boleto)idx_si_boleto_clte} * FROM bdinteg:si_boleto;";


					LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
					LET vsSQL1 = TRIM(vsSQL1);
					LET vsSQL3 = TRIM(vsSQL3);
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				   IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL ;
					--Permiso para la creacion de archivo.
						LET vsSQL = '' ;
						LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						LET vsSQL = '' ;

						LET vsSQL = 'dbaccess BdInteg ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						SYSTEM vsSQL ;
						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/control_reporte.sql';
						SYSTEM vsSQL ;

						--Elimina el caracter delimitador '?'.
						LET vsSQL = '' ;
						LET vsSQL =  "sed 's/|$//g' " || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal) || " > " || TRIM(pdrepositorio) || '/' ||
						TRIM (vsNomArchivo);
						SYSTEM vsSQL;

						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal);
						SYSTEM vsSQL ;

					LET v_codigo_retorno = "00000";
					LET v_mensaje = 'RESPALDO EN ' || TRIM (vsNomArchivo) || ' FINALIZADA OK';					LET v_reverso = '1';         
					LET v_store_pro = 'sp_respalda_boletos';
				   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

					END IF;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "Â¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	
    END IF;
 END;   --begin        
      RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 10 NOVIEMBRE 2016',
'OBJETIVO: EN LA LINEA 135 SE CAMBIA EL MENSAJES DE SALIDA',
'          PARA CUANDO SEA EXITOSA QUE CONTROL TOME LA ',
'          LINEA CORRECTA Y NO SE MUEVA CUANDO ESTE EL',
'          SORTEO ACTIVO Ã INACTIVO',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_actualiza_aprcf()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE Iid				INTEGER;
DEFINE IidErr			INTEGER;

--SISTEMA DE CUENTA 01 VARIABLES
DEFINE sAP_paterno     CHAR(26);
DEFINE sAP_materno     CHAR(26);
DEFINE sAP_nombre1     CHAR(26);
DEFINE sAP_nombre2     CHAR(26);
DEFINE sAP_fecha_nac   CHAR(10);
DEFINE sAP_rfc         CHAR(13);
DEFINE sAP_dia          CHAR(2);
DEFINE sAP_mes          CHAR(2);
DEFINE sAP_year         CHAR(4);
DEFINE sAP_fecnac       CHAR(10);

LET sAP_paterno        = '';
LET sAP_materno        = '';
LET sAP_nombre1        = '';
LET sAP_nombre2        = '';
LET sAP_fecha_nac      = '';
LET sAP_rfc            = '';
LET sAP_dia            = '';
LET sAP_mes            = '';
LET sAP_year           = '';
LET sAP_fecnac         = '';
LET Iid				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;




BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_status_valua)} id,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,ap_fecha_nac INTO Iid,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_fecnac FROM si_solicitud_movil
		WHERE status_valua IS NOT NULL AND ap_rfc IS NULL AND ap_fecha_nac IS NOT NULL and length(ap_fecha_nac)=10

		 LET IidErr=Iid;
		 LET sAP_dia = "";
		 LET sAP_mes = "";
		 LET sAP_year = "";
		 LET sAP_dia = sAP_fecnac[1,2];
		 LET sAP_mes = sAP_fecnac[4,5];
		 LET sAP_year = sAP_fecnac[7,10];

		 IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		 END IF;
		 LET sAP_fecnac ="";
		 LET sAP_rfc="";
		 LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		 CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		 RETURNING sRetCod, sAP_rfc;
		 IF sRetCod = '00000' THEN
			UPDATE "informix".si_solicitud_movil set ap_rfc=sAP_rfc where id=Iid;
		 END IF;
		LET sAP_paterno        = '';
		LET sAP_materno        = '';
		LET sAP_nombre1        = '';
		LET sAP_nombre2        = '';
		LET sAP_fecnac      = '';
	END FOREACH;


	RETURN cCodRet,IidErr;
END
END PROCEDURE;