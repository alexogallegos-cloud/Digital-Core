CREATE PROCEDURE "informix".sp_conspros_refs_piloto(pTipoConsulta CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20))

RETURNING	
			CHAR(5)  AS CodRet,			-- CODIGO DE RETORNO
			CHAR(20) As NumPros,		-- NO. CLIENTE
			CHAR(26) As Nombre1,		-- PRIMER NOMBRE
			CHAR(26) As Nombre2,		-- SEGUNDO NOMBRE
			CHAR(26) As ApellPaterno,	-- APELLIDO PATERNO
			CHAR(26) As ApellMaterno,	-- APELLIDO MATERNO
			DATE     As FechaNac,		-- FECHA DE NACIMIENTO
			CHAR(13) As Rfc,			-- RFC
			CHAR(20) As CteCoppel,		-- NO. CLIENTE COPPEL
			CHAR(20) As CteBanco,		-- NO. CLIENTE BANCO
			CHAR(20) As Curp,			-- CURP
			CHAR(1)  As Sexo, 			-- SEXO
			CHAR(2)  As EdoCivil, 		-- EDO CIVIL
			CHAR(26) As ApellCasada,	-- APELLIDO CASADA
			CHAR(3)  As Nacionalidad, 	-- NACIONALIDAD
			CHAR(18) AS FM3,			-- NO. FM3
			CHAR(2)  As TipoId, 		-- TIPO DE IDENTIFICACION
			CHAR(30) As NumId,			-- NO. IDENTIFICACION
			CHAR(2)  As Dependientes, 	-- DEPENDIENTES
			CHAR(100)As Correo,			-- CORREO ELECTRONICO
			CHAR(2)  As Parentesco,		-- PARENTESCO
			CHAR(13) As TelCasa, 		-- TEL. CASA
			CHAR(13) As TelCelular, 	-- TEL. CELULAR
			CHAR(13) As TelOficina, 	-- TEL. TRABAJO
			CHAR(5)  As Extension, 		-- EXTENSION
			CHAR(2)  As Estado, 		-- ESTADO
			SMALLINT As NumCiudad ,		-- NUMERO CIUDAD
			CHAR(5)  As Municipio, 		-- DELEGACION
			INTEGER  As Colonia, 		-- COLONIA
			INTEGER  As Calle, 			-- CALLE
			CHAR(10) As NumExt ,		-- NUM EXTERIOR
			CHAR(10) As NumInt,			-- NUM INTERIOR
			CHAR(6)  As Depto, 			-- DEPARTAMENTO
			CHAR(5)  As CodPos, 		-- CODIGO POSTAL
			CHAR(1)  As PuntoCard, 		-- PUNTO CARDINAL
			SMALLINT As Manzana,		-- MANZANA
			SMALLINT As Otros,			-- OTROS
			SMALLINT As Andador,		-- ANDADOR
			SMALLINT As Etapa,			-- ETAPA
			SMALLINT As Edificio,		-- EDIFICIO
			SMALLINT As Entrada,		-- ENTRADA
			SMALLINT As Lote,			-- LOTE
			CHAR(80) As Observaciones,	-- OBSERVACIONES
			CHAR(40) As EntreCalles,	-- ENTRE CALLES
			INTEGER  As Secuencia, 		-- SECUENCIA
			CHAR(3)  As Ciudad, 		-- CIUDAD
			CHAR(1)  As UnidadHabitac;	-- UNIDAD HABITACIONAL
			
	DEFINE viSqlErr			INTEGER;
	DEFINE viIsamErr		INTEGER;
	DEFINE vcDescErr		CHAR(50);
	DEFINE vcCodRet			CHAR(5);
	DEFINE vcCodRet2		CHAR(5);
	DEFINE vcCodRet3		CHAR(50);

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
	DEFINE vcEdoCiProsp		CHAR(1);
	DEFINE vcEdoCiTitu		CHAR(1);

	LET viSqlErr		= 0;
	LET viIsamErr		= 0;
	LET vcDescErr		= 0;
	LET vcCodRet		= '00000';
	LET vcCodRet2		= '';
	LET vcCodRet3		= '';

	LET vcNombre1		= '';
	LET vcNombre2		= '';
	LET vcApellPaterno	= '';
	LET vcApellMaterno	= '';
	LET vdFechaNac		= DATE(1);
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
	LET vcEdoCiProsp	= '';
	LET vcEdoCiTitu		= '';

BEGIN
	ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
		IF viSqlErr <> 0 THEN
			LET vcCodRet  = viSqlErr;
			LET vcCodRet2 = viIsamErr;
			LET vcCodRet3 = vcDescErr;
			LET pNumCte  = '';
			RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/bbaez/sp_conspros_refs.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pTipoConsulta,'') = '' OR NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' THEN
	
		LET vcCodRet = '00110';
		LET pNumCte = '';
		
		RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'');
		
	END IF;

	IF SUBSTR(pNumCte,1,1) <> 'P' THEN
		
		SELECT numcte_pros
			INTO vcCteBanco
			FROM "informix".pr_cliente 
			WHERE numcte = pNumCte;
			LET pNumCte = vcCteBanco;
	END IF;
	
	IF EXISTS(SELECT numcte_pros FROM "informix".pr_cliente WHERE numcte_pros = pNumCte) THEN
	
		IF pTipoConsulta = '1' THEN
			FOREACH
			
				SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.fecha_nac, cte.numcte_ref, cte.numcte_banco,cte.rfc,
				cte.parentesco, dir.telefono1, dir.telefono2, dir.telefono3, cte.secuencia
				INTO vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno,vdFechaNac, vcCteCoppel, vcCteBanco,vcRfc,
				vcParentesco, vcTelCasa, vcTelCelular, vcTelOficina, viSecuencia
				FROM "informix".pr_refclientes cte, "informix".pr_refdirecciones dir
				WHERE cte.numcte_pros = pNumCte 
				AND dir.numcte_pros = cte.numcte_pros 
				AND dir.secuencia = cte.secuencia
				AND cte.fecha_insert = (SELECT MAX(fecha_insert) 
										FROM "informix".pr_refclientes 
										WHERE numcte_pros = cte.numcte_pros)
				
				RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'') WITH RESUME;

			END FOREACH;

		ELIF pTipoConsulta = '2' OR pTipoConsulta = '3' THEN
	
			--- consultar estado civil( prospecto y titular)
			SELECT estado_civil INTO vcEdoCiProsp 
			FROM "informix".pr_ctepf 
			WHERE numcte_pros = pNumCte;
			
			SELECT estado_civil INTO vcEdoCiTitu 
			FROM  bdinteg:"informix".si_ctepf 
			WHERE numcte = (SELECT numcte 
							FROM "informix".pr_cliente 
							WHERE numcte_pros = pNumCte);
		
			IF nvl(vcEdoCiTitu,'') <> '' THEN
			--validar estado civil 
				IF vcEdoCiProsp <> vcEdoCiTitu  THEN
					IF pTipoConsulta = '2' THEN
						IF (vcEdoCiProsp IN ('S','D','V') AND vcEdoCiTitu IN ('C','U')) OR (vcEdoCiProsp IN ('C','U') AND vcEdoCiTitu IN ('S','D','V'))  THEN
					
							LET vcCodRet = '00000';
							LET pNumCte = '';
							RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'');
							
						END IF;
					END IF;
					IF pTipoConsulta = '3' THEN
						IF vcEdoCiProsp IN ('S','D','V') AND vcEdoCiTitu IN ('C','U') THEN
							LET pTipoConsulta = '2';	
						ELIF vcEdoCiProsp IN ('U','C') AND vcEdoCiTitu IN ('V','D','S')  THEN
							LET pTipoConsulta = '3';
						END IF;
					END IF;
					
				ELIF vcEdoCiProsp = vcEdoCiTitu AND pTipoConsulta = '2' THEN
				
					SELECT count(*) 
					INTO vTotRef
					FROM bdinteg:"informix".si_refclientes 
					WHERE empresa = pEmpresa
					AND numcte =  (SELECT numcte 
								   FROM "informix".pr_cliente 
								   WHERE numcte_pros = pNumCte)
					AND parentesco  = 'E';
				END IF;
			END IF;
		
			IF pTipoConsulta = '2' THEN
				
				SELECT MIN(secuencia) INTO viSecuencia
				FROM "informix".pr_refclientes
				WHERE numcte_pros = pNumCte
				AND fecha_insert = (SELECT MAX(fecha_insert) 
									FROM "informix".pr_refclientes 
									WHERE numcte_pros = pNumCte);
				
			ELIF pTipoConsulta = '3' THEN
				SELECT MAX(secuencia) INTO viSecuencia
				FROM "informix".pr_refclientes
				WHERE numcte_pros = pNumCte
				AND fecha_insert = (SELECT MAX(fecha_insert) 
									FROM "informix".pr_refclientes 
									WHERE numcte_pros = pNumCte)
				AND secuencia <> (SELECT MIN(secuencia)	FROM "informix".pr_refclientes
									WHERE numcte_pros = pNumCte
									AND fecha_insert = (SELECT MAX(fecha_insert) 
														FROM "informix".pr_refclientes 
														WHERE numcte_pros = pNumCte));
			END IF;
			
			IF (vTotRef = 0) THEN 
			
				SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.fecha_nac, cte.rfc, cte.numcte_ref, cte.numcte_banco, cte.curp, cte.sexo, cte.estado_civil, cte.apellido_cas, cte.nacionalidad, cte.no_fm3, cte.codidentifi, cte.numidentifi, cte.pers_domicilio, cte.email, cte.parentesco, dir.telefono1, dir.telefono2, dir.telefono3, dir.extension, dir.estado, dir.numerociudad, dir.municipio, dir.numerocolonia, dir.numerocalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.edificio, dir.entrada, dir.lote, dir.observaciones, dir.entre_calles, cte.secuencia, dir.ciudad, dir.unidadhabitac
				INTO vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCteCoppel, vcCteBanco, vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcTipoId, vcNumId, vcDependientes, vcCorreo, vcParentesco, vcTelCasa, vcTelCelular, vcTelOficina, vcExtension, vcEstado, viNumCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, viSecuencia, vcCiudad, vcUnidadHabitac
				FROM "informix".pr_refclientes cte, "informix".pr_refdirecciones dir
				WHERE cte.numcte_pros = pNumCte AND cte.secuencia = viSecuencia
				AND dir.numcte_pros = cte.numcte_pros AND dir.secuencia = cte.secuencia;

			END IF;
		
			RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'');	
		END IF;
	ELSE 
		LET vcCodRet = '00110';
		LET pNumCte = '';
		
		RETURN vcCodRet, NVL(pNumCte,''), NVL(vcNombre1,''),NVL(vcNombre2,''), NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),NVL(vdFechaNac,DATE(1)),NVL(vcRfc,''),NVL(vcCteCoppel,''),NVL(vcCteBanco,''),NVL(vcCurp,''),NVL(vcSexo,''),NVL(vcEdoCivil,''),NVL(vcApellCasada,''),NVL(vcNacionalidad,''),NVL(vcFM3,''),NVL(vcTipoId,''),NVL(vcNumId,''),NVL(vcDependientes,''),NVL(vcCorreo,''),NVL(vcParentesco,''),NVL(vcTelCasa,''),NVL(vcTelCelular,''),NVL(vcTelOficina,''),NVL(vcExtension,''),NVL(vcEstado,''),NVL(viNumCiudad,0),NVL(vcMunicipio,''),NVL(viColonia,0),NVL(viCalle,0),NVL(vcNumExt,''),NVL(vcNumInt,''),NVL(vcDepto,''),NVL(vcCodPos,''),NVL(vcPuntoCard,''),NVL(viManzana,0),NVL(viOtros,0),NVL(viAndador,0),NVL(viEtapa,0),NVL(viEdificio,0),NVL(viEntrada,0),NVL(viLote,0),NVL(vcObservaciones,''),NVL(vcEntreCalles,''),NVL(viSecuencia,0),NVL(vcCiudad,''),NVL(vcUnidadHabitac,'');
	END IF;
END;
END PROCEDURE
