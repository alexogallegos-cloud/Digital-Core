CREATE PROCEDURE "informix".sp_respaldotablasmigracion()
        RETURNING CHAR(6) AS codigo_retorno, CHAR(100) AS Mensaje;

    DEFINE cReturnCode     CHAR(6);
    DEFINE cMessage        CHAR(100);

    DEFINE iSQLException   INTEGER;

    LET iSQLException = 0;

    LET cReturnCode = "000";
    LET cMessage = "";

    --SET DEBUG FILE TO '/tmp/sp_respaldotablasmigracion.out';
    --TRACE ON;

	BEGIN
        ON EXCEPTION SET iSQLException
            IF iSQLException <> 0 THEN
                LET cReturnCode = iSQLException;
                RETURN cReturnCode, cMessage;
			END IF;
		END EXCEPTION;

        DELETE si_profesion11;

        INSERT INTO bdinteg:si_profesion11
        SELECT {+  INDEX(bdinteg:si_ctepf inx_ocupacion) } numcte, profesion FROM bdinteg:si_ctepf WHERE profesion IN ('003','004');


    END;
END PROCEDURE
DOCUMENT
"Autor: Julio Cesar Polanco Inzunza",
"Fecha de Creacion: 03/11/2009",
"Descripcion: Respaldo de tabla si_ctepf campo profesion",
"             por migracion de Alta Unica Paso 2",
"Solicito: Alfonso Velazquez",
"Version  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_migracionpuntocardinalctes()
	RETURNING CHAR(6) AS Codigo_retorno, CHAR(100) as Mensaje;
	
	DEFINE v_numcte     		CHAR(20);
	DEFINE v_puntocardinal		CHAR(3);
	DEFINE v_codigo_retorno		CHAR(3);
	DEFINE vsqlerr				INTEGER;
	DEFINE v_mensaje			CHAR(100);
	DEFINE v_secuencia			INTEGER;
	DEFINE v_tipodir			CHAR(1);
	
	--*********************************************************--
	-- Creado por: Frank Gaxiola Gaxiola		
	--Fecha: 29/Enero/2009
	--Objetivo: Migración de punto cardinal de la dirección de los clientes
	--Modificado: Frank Gaxiola Gaxiola		
	--Fecha: 20/Febrero/2009
	--Modificación: Se agrega validación para que solo se ejecute una vez el procedimiento
	--*********************************************************--
	
	LET vsqlerr = 0;
	LET v_codigo_retorno = "000";
	LET v_mensaje = "Migración de punto cardinal realizada con éxito";
	
		--SET DEBUG FILE TO '/tmp/sp_migracionPuntoCardinalCtes.out';
        --TRACE ON;
	
	BEGIN
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				let v_codigo_retorno = vsqlerr;
				RETURN v_codigo_retorno, v_mensaje;
			END IF;
		END EXCEPTION;
		
--		SELECT {+  INDEX(bdinteg:si_direcciones inx_puntocardinal) } LIMIT 1 TRIM(numcte) INTO v_numcte FROM bdinteg:si_direcciones WHERE puntocardinal = 'P';
	
--		IF v_numcte IS NULL THEN
		
			FOREACH

				SELECT {+  INDEX(bdinteg:si_direcciones inx_puntocardinal) } TRIM(numcte), secuencia, TRIM(tipo_dir), TRIM(puntocardinal) INTO v_numcte, v_secuencia, v_tipodir, v_puntocardinal FROM bdinteg:si_direcciones WHERE puntocardinal <> ""

				IF v_puntocardinal = 'O' THEN
					UPDATE {+  INDEX(bdinteg:si_direcciones inx_puntocardinales) } bdinteg:si_direcciones SET puntocardinal = 'P' WHERE numcte = v_numcte AND secuencia = v_secuencia AND tipo_dir = v_tipodir;
				END IF;
				
				IF v_puntocardinal = 'E' THEN
					UPDATE {+  INDEX(bdinteg:si_direcciones inx_puntocardinales) } bdinteg:si_direcciones SET puntocardinal = 'O' WHERE numcte = v_numcte AND secuencia = v_secuencia AND tipo_dir = v_tipodir;
				END IF;
				
			END FOREACH;
		
--		ELSE
--			LET v_mensaje = "La migración de punto cardinal solo se realiza una vez";
--		END IF;
		
		RETURN v_codigo_retorno, v_mensaje;

	END;
END PROCEDURE;