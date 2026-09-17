CREATE PROCEDURE "informix".sp_conspros_refs(pTipoConsulta CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING	CHAR(5),	-- CODIGO DE RETORNO
			CHAR(20),	-- NO. CLIENTE
			CHAR(26),	-- PRIMER NOMBRE
			CHAR(26),	-- SEGUNDO NOMBRE
			CHAR(26),	-- APELLIDO PATERNO
			CHAR(26),	-- APELLIDO MATERNO
			DATE,		-- FECHA DE NACIMIENTO
			CHAR(13),	-- RFC
			CHAR(20),	-- NO. CLIENTE COPPEL
			CHAR(20),	-- NO. CLIENTE BANCO
			CHAR(20),	-- CURP
			CHAR(1),	-- SEXO
			CHAR(2),	-- EDO CIVIL
			CHAR(26),	-- APELLIDO CASADA
			CHAR(3),	-- NACIONALIDAD
			CHAR(18),	-- NO. FM3
			CHAR(2),	-- TIPO DE IDENTIFICACION
			CHAR(30),	-- NO. IDENTIFICACION
			CHAR(2),	-- DEPENDIENTES
			CHAR(100),	-- CORREO ELECTRONICO
			CHAR(2),	-- PARENTESCO
			CHAR(13),	-- TEL. CASA
			CHAR(13),	-- TEL. CELULAR
			CHAR(13),	-- TEL. TRABAJO
			CHAR(5),	-- EXTENSION
			CHAR(2),	-- ESTADO
			SMALLINT,	-- NUMERO CIUDAD
			CHAR(5),	-- DELEGACION
			INTEGER,	-- COLONIA
			INTEGER,	-- CALLE
			CHAR(10),	-- NUM EXTERIOR
			CHAR(10),	-- NUM INTERIOR
			CHAR(6),	-- DEPARTAMENTO
			CHAR(5),	-- CODIGO POSTAL
			CHAR(1),	-- PUNTO CARDINAL
			SMALLINT,	-- MANZANA
			SMALLINT,	-- OTROS
			SMALLINT,	-- ANDADOR
			SMALLINT,	-- ETAPA
			SMALLINT,	-- EDIFICIO
			SMALLINT,	-- ENTRADA
			SMALLINT,	-- LOTE
			CHAR(80),	-- OBSERVACIONES
			CHAR(40),	-- ENTRE CALLES
			INTEGER,	-- SECUENCIA
			CHAR(3),	-- CIUDAD
			CHAR(1);	-- UNIDAD HABITACIONAL

DEFINE viSqlErr			INTEGER;
DEFINE viIsamErr		INTEGER;
DEFINE vcDescErr		CHAR(50);
DEFINE vcCodRet			CHAR(5);
DEFINE vcCodRet2		CHAR(5);
DEFINE vcCodRet3		CHAR(50);

DEFINE vcNumPros		CHAR(20);
DEFINE vcNombre1		CHAR(26);
DEFINE vcNombre2		CHAR(26);
DEFINE vcApellPaterno	CHAR(26);
DEFINE vcApellMaterno	CHAR(26);
DEFINE vdFechaNac		DATE;
DEFINE vcRfc			CHAR(13);
DEFINE vcCteCoppel		CHAR(20);
DEFINE vcCteBanco		CHAR(20);
DEFINE vcCurp			CHAR(20);
DEFINE vcSexo			CHAR(1);
DEFINE vcEdoCivil		CHAR(2);
DEFINE vcApellCasada	CHAR(26);
DEFINE vcNacionalidad	CHAR(3);
DEFINE vcFM3			CHAR(18);
DEFINE vcTipoId			CHAR(2);
DEFINE vcNumId			CHAR(30);
DEFINE vcDependientes	CHAR(2);
DEFINE vcCorreo			CHAR(100);
DEFINE vcParentesco		CHAR(2);
DEFINE vcTelCasa		CHAR(13);
DEFINE vcTelCelular		CHAR(13);
DEFINE vcTelOficina		CHAR(13);
DEFINE vcExtension		CHAR(5);
DEFINE vcEstado			CHAR(2);
DEFINE viNumCiudad		SMALLINT;
DEFINE vcMunicipio		CHAR(5);
DEFINE viColonia		INTEGER;
DEFINE viCalle			INTEGER;
DEFINE vcNumExt			CHAR(10);
DEFINE vcNumInt			CHAR(10);
DEFINE vcDepto			CHAR(6);
DEFINE vcCodPos			CHAR(5);
DEFINE vcPuntoCard		CHAR(1);
DEFINE viManzana		SMALLINT;
DEFINE viOtros			SMALLINT;
DEFINE viAndador		SMALLINT;
DEFINE viEtapa			SMALLINT;
DEFINE viEdificio		SMALLINT;
DEFINE viEntrada		SMALLINT;
DEFINE viLote			SMALLINT;
DEFINE vcObservaciones	CHAR(80);
DEFINE vcEntreCalles	CHAR(40);
DEFINE viSecuencia		INTEGER;
DEFINE vcCiudad			CHAR(3);
DEFINE vcUnidadHabitac	CHAR(1);
DEFINE vTotRef          SMALLINT;

LET viSqlErr		= 0;
LET viIsamErr		= 0;
LET vcDescErr		= 0;
LET vcCodRet		= '00000';
LET vcCodRet2		= '';
LET vcCodRet3		= '';

LET vcNumPros		= '';
LET vcNombre1		= '';
LET vcNombre2		= '';
LET vcApellPaterno	= '';
LET vcApellMaterno	= '';
LET vdFechaNac		= '';
LET vcRfc			= '';
LET vcCteCoppel		= '';
LET vcCteBanco		= '';
LET vcCurp			= '';
LET vcSexo			= '';
LET vcEdoCivil		= '';
LET vcApellCasada	= '';
LET vcNacionalidad	= '';
LET vcFM3			= '';
LET vcTipoId		= '';
LET vcNumId			= '';
LET vcDependientes	= '';
LET vcCorreo		= '';
LET vcParentesco	= '';
LET vcTelCasa		= '';
LET vcTelCelular	= '';
LET vcTelOficina	= '';
LET vcExtension		= '';
LET vcEstado		= '';
LET viNumCiudad		= '';
LET vcMunicipio		= '';
LET viColonia		= 0;
LET viCalle			= 0;
LET vcNumExt		= '';
LET vcNumInt		= '';
LET vcDepto			= '';
LET vcCodPos		= '';
LET vcPuntoCard		= '';
LET viManzana		= 0;
LET viOtros			= 0;
LET viAndador		= 0;
LET viEtapa			= 0;
LET viEdificio		= 0;
LET viEntrada		= 0;
LET viLote			= 0;
LET vcObservaciones	= '';
LET vcEntreCalles	= '';
LET viSecuencia		= '';
LET vcCiudad		= '';
LET vcUnidadHabitac	= '';
LET vTotRef         = 0;

--- SET DEBUG FILE TO "/tmp/sp_conspros_refs.out";
--- TRACE ON;

BEGIN
	ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
		SET DEBUG FILE TO "/tmp/sp_conspros_refs.err";
		TRACE ON;
		IF viSqlErr <> 0 THEN
			LET vcCodRet  = viSqlErr;
			LET vcCodRet2 = viIsamErr;
			LET vcCodRet3 = vcDescErr;
			LET vcNumPros  = '';
			RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco,
			vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
			vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt,
			vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones,
			vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF (pTipoConsulta IS NULL OR pTipoConsulta = '') OR (pEmpresa IS NULL OR pEmpresa = '') OR (pNumCte  IS NULL OR pNumCte = '') THEN
		LET vcCodRet = '00110';
		LET vcNumPros = '';
		RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco,
		vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
		vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt,
		vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones,
		vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac;
	END IF;

	SELECT numcte_pros INTO vcNumPros FROM pr_cliente WHERE numcte_pros = pNumCte;

	IF vcNumPros IS NULL OR vcNumPros = '' OR vcNumPros <> pNumCte THEN
		LET vcCodRet = '00110';
		LET vcNumPros = '';
		RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco,
		vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
		vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt,
		vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones,
		vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac;
	END IF;

	IF pTipoConsulta = '1' THEN
		FOREACH
			SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.numcte_ref, cte.numcte_banco,
			cte.parentesco, dir.telefono1, dir.telefono2, dir.telefono3, cte.secuencia
			INTO vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vcCteCoppel, vcCteBanco,
			vcParentesco, vcTelCasa, vcTelCelular, vcTelOficina, viSecuencia
			FROM pr_refclientes cte, pr_refdirecciones dir
			WHERE cte.numcte_pros = vcNumPros AND dir.numcte_pros = cte.numcte_pros AND dir.secuencia = cte.secuencia
			AND cte.fecha_insert = (SELECT MAX(fecha_insert) FROM pr_refclientes WHERE numcte_pros = cte.numcte_pros)

			IF vcNombre1		IS NULL THEN LET vcNombre1		= ''; END IF;
			IF vcNombre2		IS NULL THEN LET vcNombre2		= ''; END IF;
			IF vcApellPaterno	IS NULL THEN LET vcApellPaterno	= ''; END IF;
			IF vcApellMaterno	IS NULL THEN LET vcApellMaterno	= ''; END IF;
			IF vcCteCoppel		IS NULL THEN LET vcCteCoppel	= ''; END IF;
			IF vcCteBanco		IS NULL THEN LET vcCteBanco		= ''; END IF;
			IF vcParentesco		IS NULL THEN LET vcParentesco	= ''; END IF;
			IF vcTelCasa		IS NULL THEN LET vcTelCasa		= ''; END IF;
			IF vcTelCelular		IS NULL THEN LET vcTelCelular	= ''; END IF;
			IF vcTelOficina		IS NULL THEN LET vcTelOficina	= ''; END IF;
			IF viSecuencia		IS NULL THEN LET viSecuencia	= 0;  END IF;

			RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco,
			vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
			vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt,
			vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones,
			vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac WITH RESUME;
		END FOREACH;

	ELIF pTipoConsulta = '2' OR pTipoConsulta = '3' THEN
		IF pTipoConsulta = '2' THEN
			SELECT MIN(secuencia) INTO viSecuencia
			FROM pr_refclientes
			WHERE numcte_pros = vcNumPros
			AND fecha_insert = (SELECT MAX(fecha_insert) FROM pr_refclientes WHERE numcte_pros = vcNumPros);

              select count(*) 
              into vTotRef
              from bdinteg:si_refclientes 
              where empresa = pEmpresa
                and numcte =  (SELECT numcte FROM pr_cliente WHERE numcte_pros = vcNumPros)
                and parentesco  = 'E';
            
		ELIF pTipoConsulta = '3' THEN
			SELECT MAX(secuencia) INTO viSecuencia
			FROM pr_refclientes
			WHERE numcte_pros = vcNumPros
			AND fecha_insert = (SELECT MAX(fecha_insert) FROM pr_refclientes WHERE numcte_pros = vcNumPros);
		END IF;

        IF (vTotRef = 0) THEN
            SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.fecha_nac, cte.rfc, cte.numcte_ref,
            cte.numcte_banco, cte.curp, cte.sexo, cte.estado_civil, cte.apellido_cas, cte.nacionalidad, cte.no_fm3,
            cte.codidentifi, cte.numidentifi, cte.pers_domicilio, cte.email, cte.parentesco,
            dir.telefono1, dir.telefono2, dir.telefono3, dir.extension, dir.estado, dir.numerociudad, dir.municipio,
            dir.numerocolonia, dir.numerocalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, dir.cod_postal,
            dir.puntocardinal, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.edificio, dir.entrada, dir.lote,
            dir.observaciones, dir.entre_calles, cte.secuencia, dir.ciudad, dir.unidadhabitac
            INTO vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel,
            vcCteBanco, vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3,
            vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
            vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio,
            viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos,
            vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote,
            vcObservaciones, vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac
            FROM pr_refclientes cte, pr_refdirecciones dir
            WHERE cte.numcte_pros = vcNumPros AND cte.secuencia = viSecuencia
            AND dir.numcte_pros = cte.numcte_pros AND dir.secuencia = cte.secuencia;
        END IF;

		IF vcNombre1		IS NULL THEN LET vcNombre1			= ''; END IF;
		IF vcNombre2		IS NULL THEN LET vcNombre2			= ''; END IF;
		IF vcApellPaterno	IS NULL THEN LET vcApellPaterno		= ''; END IF;
		IF vcApellMaterno	IS NULL THEN LET vcApellMaterno		= ''; END IF;
		IF vdFechaNac		IS NULL THEN LET vdFechaNac			= ''; END IF;
		IF vcRfc			IS NULL THEN LET vcRfc				= ''; END IF;
		IF vcCteCoppel		IS NULL THEN LET vcCteCoppel		= ''; END IF;
		IF vcCteBanco		IS NULL THEN LET vcCteBanco			= ''; END IF;
		IF vcCurp			IS NULL THEN LET vcCurp				= ''; END IF;
		IF vcSexo			IS NULL THEN LET vcSexo				= ''; END IF;
		IF vcEdoCivil		IS NULL THEN LET vcEdoCivil			= ''; END IF;
		IF vcApellCasada	IS NULL THEN LET vcApellCasada		= ''; END IF;
		IF vcNacionalidad	IS NULL THEN LET vcNacionalidad		= ''; END IF;
		IF vcFM3			IS NULL THEN LET vcFM3				= ''; END IF;
		IF vcTipoId			IS NULL THEN LET vcTipoId			= ''; END IF;
		IF vcNumId			IS NULL THEN LET vcNumId			= ''; END IF;
		IF vcDependientes	IS NULL THEN LET vcDependientes		= ''; END IF;
		IF vcCorreo			IS NULL THEN LET vcCorreo			= ''; END IF;
		IF vcParentesco		IS NULL THEN LET vcParentesco		= ''; END IF;
		IF vcTelCasa		IS NULL THEN LET vcTelCasa			= ''; END IF;
		IF vcTelCelular		IS NULL THEN LET vcTelCelular		= ''; END IF;
		IF vcTelOficina		IS NULL THEN LET vcTelOficina		= ''; END IF;
		IF vcExtension		IS NULL THEN LET vcExtension		= ''; END IF;
		IF vcEstado			IS NULL THEN LET vcEstado			= ''; END IF;
		IF viNumCiudad		IS NULL THEN LET viNumCiudad		= 0;  END IF;
		IF vcMunicipio		IS NULL THEN LET vcMunicipio		= ''; END IF;
		IF viColonia		IS NULL THEN LET viColonia			= 0;  END IF;
		IF viCalle			IS NULL THEN LET viCalle			= 0;  END IF;
		IF vcNumExt			IS NULL THEN LET vcNumExt			= ''; END IF;
		IF vcNumInt			IS NULL THEN LET vcNumInt			= ''; END IF;
		IF vcDepto			IS NULL THEN LET vcDepto			= ''; END IF;
		IF vcCodPos			IS NULL THEN LET vcCodPos			= ''; END IF;
		IF vcPuntoCard		IS NULL THEN LET vcPuntoCard		= ''; END IF;
		IF viManzana		IS NULL THEN LET viManzana			= 0;  END IF;
		IF viOtros			IS NULL THEN LET viOtros			= 0;  END IF;
		IF viAndador		IS NULL THEN LET viAndador			= 0;  END IF;
		IF viEtapa			IS NULL THEN LET viEtapa			= 0;  END IF;
		IF viEdificio		IS NULL THEN LET viEdificio			= 0;  END IF;
		IF viEntrada		IS NULL THEN LET viEntrada			= 0;  END IF;
		IF viLote			IS NULL THEN LET viLote				= 0;  END IF;
		IF vcObservaciones	IS NULL THEN LET vcObservaciones	= ''; END IF;
		IF vcEntreCalles	IS NULL THEN LET vcEntreCalles		= ''; END IF;
		IF viSecuencia		IS NULL THEN LET viSecuencia		= 0;  END IF;
		IF vcCiudad			IS NULL THEN LET vcCiudad			= ''; END IF;
		IF vcUnidadHabitac	IS NULL THEN LET vcUnidadHabitac	= ''; END IF;

		RETURN vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco,
		vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco,
		vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt,
		vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones,
		vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac;
	END IF;
END;
END PROCEDURE;