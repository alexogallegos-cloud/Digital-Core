CREATE PROCEDURE "informix".sp_buscararchivo(cEmpresa CHAR(3))
RETURNING

CHAR(5) AS cCodRet,
CHAR(1) AS cBandera;


--DEFINICION DE VARIABLES--
DEFINE cCodRet        CHAR(5);
DEFINE iSqlErr        INTEGER;
DEFINE vNombreArchivo VARCHAR (100);
DEFINE vRuta          VARCHAR (100);

DEFINE cBandera		  CHAR(1);
DEFINE lCadSql	      LVARCHAR(500);
DEFINE vLinea	      VARCHAR(50);

--INICIALIZACION DE VARIABLES--
LET   lCadSql	      = '';
LET   cBandera	      = 'F';
LET   vLinea		  = '';
LET   vNombreArchivo  = '';
LET   vRuta           = '';
LET   cCodRet         = '00000';
LET   iSqlErr         = 0;

BEGIN

	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
        END IF;

        RETURN cCodRet,'';

    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO "/tmp/sp_buscararchivo.out";
--	TRACE ON;

	IF NVL(cEmpresa, '') = '' THEN
		LET cCodRet = '00001';	--Faltan Parámetros
		RETURN cCodRet, cBandera;
	END IF;

	SELECT valor
	INTO   vRuta
	FROM   bdinteg:"informix".si_param
	WHERE  cod_param = '137';

	IF NVL(vRuta,'') = '' THEN
		LET cCodRet = '00002';	--No existe el Parámetro
		RETURN cCodRet, cBandera;
	END IF;

	SELECT valor
	INTO   vNombreArchivo
	FROM   bdinteg:"informix".si_param
	WHERE  cod_param = '138';

	IF NVL(vNombreArchivo,'') = '' THEN
		LET cCodRet = '00002';	--No existe el Parámetro
		RETURN cCodRet, cBandera;
	END IF;

		--- BORRA LA TABLA TEMPORAL EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tme_busca_archivo') THEN
			DROP TABLE tme_busca_archivo;
		END IF

		--- CREA LA TABLA
		CREATE TABLE tme_busca_archivo
		(linea LVARCHAR(50));

		--- CORRE EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
		LET lCadSql = 'ls ' || TRIM(vRuta) || ' > ' || TRIM(vRuta) || 'buscar.bus';
		SYSTEM lCadSql;

		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO  *.SQL
		LET lCadSql = 'echo "LOAD FROM ' || TRIM(vRuta) || 'buscar.bus' || ' INSERT INTO tme_busca_archivo" > '|| TRIM(vRuta) || 'EjecutaBusqueda_sp_BuscarArchivo.sql';
		SYSTEM lCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		LET lCadSql = 'dbaccess bdinteg ' || TRIM(vRuta) || 'EjecutaBusqueda_sp_BuscarArchivo.sql';
		SYSTEM lCadSql;


		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO vLinea
			FROM tme_busca_archivo

			IF vLinea = vNombreArchivo THEN
				LET cBandera = "V";
				EXIT FOREACH;
			END IF

		END FOREACH

		DROP TABLE tme_busca_archivo;

	RETURN cCodRet, cBandera;

END;
END PROCEDURE
DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 30/04/2012",
"Descripcion: Consulta la existencia de un archivo en determinada ruta",
"Si existe regresa 'V' y si no existe regresa 'F' ",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_campaniamensajeporlinea(sIdMensaje SMALLINT, sOrden SMALLINT)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consulta el mensaje asignado a una campaña y lo retorna renglón por renglón
--Realizó: Nancy Sevilla Camacho
--Fecha: 19/04/2012
--BD: BDINTEG
--------------------------------------------------------------------
-- MODIFICACIÓN
--Se limpian variables dentro del WHILE
--Modificó: Nancy Sevilla Camacho
--Fecha: 27/06/2012
--BD: BDINTEG
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5)  AS codigo_retorno,
CHAR(55) AS mensaje;

--DEFINICION DE VARIABLES--
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(5);
DEFINE iRows       INTEGER; --27/06/2012
DEFINE cMensaje    CHAR(55);
DEFINE cMensajeInc CHAR(55);
DEFINE cVariable   CHAR(20);
DEFINE cValorVar   CHAR(10);
DEFINE i           INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSqlErr     = 0;
LET cCodRet     = '00000';
LET iRows        = 0;  --27/06/2012
LET cMensaje    = '';
LET cMensajeInc = '';
LET cVariable   = '';
LET cValorVar   = '';
LET i           = 0;

	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_campaniamensajeporlinea.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cMensaje;
			END IF;
		END EXCEPTION;

		--Valida parámetros de entrada
		IF sIdMensaje IS NOT NULL AND sOrden IS NOT NULL THEN

		-- Se obtiene el mensaje de la campaña
			SELECT mensaje
			  INTO cMensajeInc
			  FROM bdinteg:"informix".si_detcamp
			 WHERE	empresa = '001'
				AND idmensaje = sIdMensaje
               			AND orden = sOrden;

			LET i = 1;
			LET cVariable = "";
			LET cMensaje = "";

			WHILE i <= LENGTH(cMensajeInc)
				IF SUBSTR(cMensajeInc,i,1) = "<" THEN
					LET i = i + 1;
					WHILE SUBSTR(cMensajeInc,i,1) != ">"
						--27/06/2012
					   IF SUBSTR(cMensajeInc,i,1) <> " " tHEN
							LET cVariable = Trim(cVariable) || SUBSTR(cMensajeInc,i,1);
					   ELSE
							LET cVariable = Trim(cVariable) || "|";
					   END IF;
						LET i = i + 1;
                    END WHILE;

					--27/06/2012
					--Se reemplaza caracter para respetar el espacio en blanco
					LET cVariable =  REPLACE(cVariable, "|" ," ");

					IF TRIM(cVariable) <> "" THEN
						-- Se obtiene el valor de la variable
						SELECT valor
						  INTO cValorVar
						  FROM bdinteg:"informix".si_cat_variables
						 WHERE nomvar = cVariable;

						--27/06/2012
						LET iRows = DBINFO("sqlca.sqlerrd2");
						IF iRows = 0 THEN
						   -- No se encontraron registros para ese Id de Mensaje
						   LET cCodRet = '00002';
							RETURN cCodRet,
								   cMensaje;
						END IF;

						--IF cValorVar <> "" THEN  --27/06/2012
							LET cMensaje =  REPLACE(cMensajeInc,"<" || TRIM(cVariable) || ">" ,TRIM(cValorVar));
							--27/06/2012
							LET cVariable = "";
							LET cMensajeInc = cMensaje;
							LET i = 1;
						--27/06/2012
						/*ELSE
						    LET cMensaje =  cMensajeInc;
						END IF;*/
					END IF;
				END IF;
				LET i = i + 1;
			END WHILE;

			--Si no encuentra variables en el texto se asigna el texto original
			IF TRIM(cMensaje) = "" THEN
			    LET cMensaje =  cMensajeInc;
			END IF;

			RETURN cCodRet,
				   cMensaje;
		ELSE

			--Párametros de entrada vacíos
			LET cCodRet = '00001';

			RETURN cCodRet,
				   cMensaje;

		END IF;

	END
END PROCEDURE;