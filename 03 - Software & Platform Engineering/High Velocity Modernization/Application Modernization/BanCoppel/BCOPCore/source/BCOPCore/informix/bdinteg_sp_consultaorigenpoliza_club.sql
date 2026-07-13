CREATE PROCEDURE "informix".sp_consultaorigenpoliza_club
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pTipoCte INTEGER
)
RETURNING CHAR(6) AS CodRet,
		  CHAR(1) AS OrigenPoliza;

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE cOrigenPol CHAR(1);
DEFINE sExiste SMALLINT;
DEFINE cCteBanco CHAR(20);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cOrigenPol = '';
LET sExiste = 0;
LET cCteBanco = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, cOrigenPol;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaorigenpoliza_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTipoCte,0) <> 0  THEN
		IF pTipoCte = 2 THEN
			SELECT  numcte_banco
			INTO cCteBanco
			FROM "informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND cliente = pNumCte;
			
			IF NVL(cCteBanco,'') = '' THEN
				LET cOrigenPol = 'N';
			END IF;
		ELSE
			LET cCteBanco = pNumCte;
		END IF;
		IF pTipoCte = 1 OR cOrigenPol <> 'N' THEN
			SELECT  COUNT(numcte)
			INTO sExiste
			FROM "informix".si_club_proteccion
			WHERE empresa = pEmpresa
			AND numcte = cCteBanco
			AND aceptada = '1';
			IF sExiste > 0 THEN
				LET cOrigenPol = 'S';
			ELSE
				LET cOrigenPol = 'N';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	RETURN cCodRet, cOrigenPol;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:02/Jul/2014",
"Descripción: Se crea SP para validar si una póliza del Club de Proteccion nació en BanCoppel",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_consultaplan_club
(
   pEmpresa CHAR(3),
   pTipoPlan CHAR(1)   
)
RETURNING CHAR(6) AS CodRet,
		  CHAR(1) as TipoPlan,
		  CHAR(40) as Descripcion,
		  MONEY(14,2) as Monto;

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE	cTipoPlan CHAR(1);
DEFINE	cDes CHAR(40);
DEFINE	mMonto MONEY(14,2);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cTipoPlan = '';
LET cDes = '';
LET mMonto = 0.0;


BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet,cTipoPlan,cDes,mMonto;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaplan_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pTipoPlan,'') <> ''  THEN
		SELECT tipoplan,descripcion,monto
		INTO cTipoPlan,cDes,mMonto
		FROM "informix".si_club_planes
		WHERE empresa = pEmpresa
		AND tipoplan = pTipoPlan;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			RETURN cCodRet,NVL(cTipoPlan,''),NVL(cDes,''),NVL(mMonto,0.0);
		END IF
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	RETURN cCodRet,cTipoPlan,cDes,mMonto;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:15/Jul/2014",
"Descripción: Se crea SP para retornar la informacion de un plan en específico",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_guardacteprospecto_club
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplTitular		CHAR(20),
	pCteCplProspecto	CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet

	--VARIABLES
	DEFINE vcCodRet		CHAR(06);
	DEFINE vcCteBanCpl	CHAR(20);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACIÓN
	LET vcCodRet	= '000000';
	LET vcCteBanCpl	= '';
	LET iSql_err 	= 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_guardacteprospecto_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARÁMETROS VACÍOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '000001';
			RETURN vcCodRet;
		END IF;
		
		--BÚSQUEDA DE DATOS
		SELECT ctebancpl
		INTO vcCteBanCpl
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESÓ DATOS
		IF DBINFO("sqlca.sqlerrd2") = 1 THEN
			LET vcCodRet = '000002';
			RETURN vcCodRet;
		ELSE
			INSERT INTO "informix".si_club_hiscteprospecto(empresa, ctebancpl, ctecpltitular, ctecplprospecto)
			VALUES (pEmpresa, pCteBanCpl, pCteCplTitular, pCteCplProspecto);
			
			RETURN vcCodRet;
		END IF;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Guarda la relación del cliente bancoppel con el clinente Coppel titular y prospecto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_inserta_respuesta_club
(
	pEmpresa 			CHAR(03),
	pSucursal 			CHAR(04),
	pNumCteBancoppel	CHAR(20),
	pNumCteCoppel		CHAR(20),
	pRespuesta			CHAR(01)
)

RETURNING
	CHAR(06) AS cCodRet;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet = '000000';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_inserta_respuesta_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	LET pEmpresa  			= TRIM(pEmpresa);
	LET pSucursal 			= TRIM(pSucursal);
	LET pNumCteBancoppel 	= TRIM(pNumCteBancoppel);
	LET pNumCteCoppel 		= TRIM(pNumCteCoppel);
	LET pRespuesta 			= TRIM(pRespuesta);
	
	IF NVL(pEmpresa, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pNumCteBancoppel, '') = '' OR NVL(pNumCteCoppel, '') = '' OR NVL(pRespuesta, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet;
	END IF;
	
	INSERT INTO "informix".si_club_bitacora(empresa, sucursal, numcte, numcte_coppel, respuesta, fecha)
	VALUES(pEmpresa, pSucursal, pNumCteBancoppel, pNumCteCoppel, pRespuesta, CURRENT);
	RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'Inserta la respuesta en la tabla si_club_bitacora cuando el cliente contesta el cuestionario de salud cuando se le ofrece el Club de Protección coppel',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-02',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_obtienecteprospecto_club
(
	pEmpresa 	CHAR(03),
	pCteBanCpl	CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(20) AS cCteCplTitular,
	CHAR(20) AS cCteCplProspecto

--VARIABLES
DEFINE vcCodRet				CHAR(06);
DEFINE vcCteCplTitular		CHAR(15);
DEFINE vcCteCplProspecto	CHAR(15);
DEFINE iSql_err				INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET vcCodRet			= '000000';
LET vcCteCplProspecto	= '';
LET vcCteCplTitular		= '';
LET iSql_err			= 0;

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_obtienecteprospecto_club_out.sql';
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
			END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARÁMETROS VACÍOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' THEN
			LET vcCodRet = '000001';
			RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
		END IF;
		
		--BÚSQUEDA DE DATOS
		SELECT ctecpltitular, ctecplprospecto
		INTO vcCteCplTitular, vcCteCplProspecto
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESÓ DATOS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET vcCodRet = '000002';
			LET vcCteCplProspecto = '';
			LET vcCteCplTitular = '';
		END IF;
		RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Retorna el número de cliente titular y prospecto Coppel de un cliente relacionado BanCoppel',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_parentesco_club
(
	pEmpresa CHAR(03)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(01) AS cParentesco,
	CHAR(30) AS cDescripcion;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);
DEFINE cParentesco	CHAR(01);
DEFINE cDescripcion CHAR(30);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet			= '000000';
LET cParentesco		= '';
LEt cDescripcion	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_error_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cParentesco, cDescripcion;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	LET pEmpresa = TRIM(pEmpresa);
	
	IF NVL(pEmpresa, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF;
	
	FOREACH
		SELECT parentesco, descripcion
		INTO cParentesco, cDescripcion
		FROM "informix".si_club_parentesco
		WHERE empresa = pEmpresa
		RETURN cCodRet, cParentesco, cDescripcion WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF

END;
END PROCEDURE

DOCUMENT
'Retorna el catálogo de parentescos en la definición de los',
'beneficiarios de la póliza del club de protección.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-06',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_relaciona_ctebancplcpl_club(pEmpresa CHAR(3), pCteBanCoppel CHAR(20), pCteCoppel CHAR(20), pCteCoppelNvo CHAR(20), pTipoCteCpl CHAR(1),pOpcion CHAR(1))
RETURNING CHAR(6) AS Codigo_retorno;

--DEFINICION DE VARIABLES
DEFINE cCodret			 CHAR(6);
DEFINE iSqlErr INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_relaciona_ctebancplcpl_club.out';
    --TRACE ON;
	
	BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
	
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCteBanCoppel,'')) ='' OR TRIM(NVL(pCteCoppel,''))='' OR TRIM(NVL(pTipoCteCpl,''))='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN --Se actualiza la bandera del tipo de cliente coppel desde el soltarc y apertc
				
				SELECT numcte_banco
				INTO pCteBanCoppel
				FROM "informix".si_relacion_ctebcplcpl
				WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
				AND cliente = TRIM(NVL(pCteCoppel,''))
				AND empresa= TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '000002'; --Relación  CteBancoppel - CteCoppel no encontrado
				ELSE
					UPDATE "informix".si_relacion_ctebcplcpl
					SET cliente_prosp = pTipoCteCpl
					WHERE numcte_banco = pCteBanCoppel
					AND cliente = TRIM(NVL(pCteCoppel,''))
					AND empresa= TRIM(NVL(pEmpresa,''));
				END IF
			ELIF TRIM(NVL(pOpcion,''))='2' THEN  --Se actualiza la bandera y guarda el numero de cliente coppel prospecto desde el Alta del Club
				IF TRIM(NVL(pCteCoppelNvo,''))='' THEN
					LET cCodret = '000001'; --Parámetros de entrada vacíos
				ELSE	
					SELECT numcte_banco
					INTO pCteBanCoppel
					FROM "informix".si_relacion_ctebcplcpl
					WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
					AND empresa= TRIM(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --Cliente Bancoppel no encontrado
					ELSE
						UPDATE "informix".si_relacion_ctebcplcpl
						SET cliente=pCteCoppelNvo, cliente_prosp = pTipoCteCpl
						WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
						AND empresa= TRIM(NVL(pEmpresa,''));
					END IF
				END IF
			END IF
		END IF
		RETURN cCodret;
	END
END PROCEDURE
DOCUMENT
"Descripción: Actualiza el tipo de cliente coppel relacionado (titular o prospecto)", 
"también cambia la clave del cliente prospecto por la clave de cliente titular coppel",
"Autor : Leslie Rendón",
"FECHA : 02/07/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_servicio_club
(
	pEmpresa 	CHAR(03),
	pCodServAu	CHAR(05)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(40) AS cEncabezado,
	CHAR(30) AS cProducto;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err			INTEGER;
DEFINE cCodRet			CHAR(06);
DEFINE cEncabezado		CHAR(40);
DEFINE cProducto 		CHAR(40);

DEFINE vccod_tipserv	CHAR(02);
DEFINE vcnombre_serv	CHAR(40);
DEFINE vcactivo			CHAR(01);
DEFINe vcdescripcion	CHAR(40);
DEFINe vcactivoTipo		CHAR(01);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet			= '000000';
LET cEncabezado		= '';
LEt cProducto		= '';

LET vccod_tipserv	= '';
LET vcnombre_serv	= '';
LET vcactivo		= '';
LET vcdescripcion	= '';
LET vcactivoTipo	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_servicio_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cEncabezado, cProducto;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	LET pEmpresa 	= TRIM(pEmpresa);
	LET cEncabezado = TRIM(cEncabezado);
	LET cProducto 	= TRIM(cProducto);
		
	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	IF NVL(pEmpresa, '') = '' OR NVL(pCodServAu, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF;
	
	--BÚSQUEDA DE DATOS
	SELECT cod_tipserv, nombre_serv_au, activo
	INTO vccod_tipserv, vcnombre_serv, vcactivo
	FROM "informix".si_servicios_au
	WHERE empresa = pEmpresa AND cod_serv_au = pCodServAu;
	
	--SI NO REGRESÓ DATOS
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000003';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF
	
	--SI REGRESÓ DATOS Y EL CAMPO ES DIFERENTE A 1
	LET vcactivo = NVL(TRIM(vcactivo), '');
	IF vcactivo = 1 THEN
		SELECT descripcion, activo
		INTO vcdescripcion, vcactivoTipo
		FROM "informix".si_tipo_servicios_au
		WHERE empresa = pEmpresa AND cod_tipserv = vccod_tipserv;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			RETURN cCodRet, cEncabezado, cProducto;
		ELSE
			IF vcactivoTipo = 1 THEN
				LET cProducto	= vcnombre_serv;
				LET cEncabezado = vcdescripcion;
			ELSE
				LET cCodRet = '000004';
				RETURN cCodRet, cEncabezado, cProducto;
			END IF
		END IF
	ELSE
		LET cCodRet = '000004';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF
	RETURN cCodRet, cEncabezado, cProducto;
	
END;
END PROCEDURE

DOCUMENT
'Retorna la descripción para el encabezado y descripción del producto del club de protección.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-04',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_confirmaimportarcofetel()
RETURNING CHAR(5)

------------------------------------------------------------
-- REALIZO: Mohamed Carreón
-- FECHA:      2009-02-14
--FUNCION: Carga el archivo de la COFETEL a
--                    la tabla  si_cattelefonos
-------------------------------------------------------------

--Definición de variables
DEFINE cCodret CHAR(5) ;
DEFINE iSqlErr INTEGER ;
DEFINE cSql CHAR(200);

--Inicializaciòn de variables
LET cCodret ='000';
LET iSqlErr = 0;
LET cSql = '';

--	SET DEBUG FILE TO "/tmp/has/sp_ConfirmaImportarCofetel.out";
--	TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET cCodret = iSqlErr;
        RETURN cCodret;
    END IF;
END EXCEPTION;

    DELETE FROM bdinteg:si_cattelefono;

	INSERT INTO bdinteg: si_cattelefono(clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior)
	SELECT clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior  
	FROM bdinteg: tmp_si_cattelefono;

RETURN cCodret;

END;
END PROCEDURE;