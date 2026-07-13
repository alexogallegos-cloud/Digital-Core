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