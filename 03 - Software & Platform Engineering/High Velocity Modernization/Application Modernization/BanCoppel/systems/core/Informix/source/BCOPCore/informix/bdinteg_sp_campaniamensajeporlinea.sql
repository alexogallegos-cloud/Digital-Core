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