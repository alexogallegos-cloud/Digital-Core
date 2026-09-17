CREATE PROCEDURE "informix".sp_consultaparametrosbpi(psIdParam CHAR(2))
    RETURNING CHAR(5), CHAR(25), CHAR (100);

--Declaracion de variables

DEFINE vsCodRet  CHAR(5);
DEFINE viSqlErr  INTEGER;
DEFINE sValor  CHAR(25);
DEFINE sDescripcion  CHAR(100);


--SET DEBUG FILE TO "/tmp/sp_ConsultaParametrosBPI.out";
--TRACE ON;


--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET sDescripcion = '';
LET sValor = '';

IF NVL(psIdParam, '') = '' THEN --Valida parámetros
    LET vsCodRet = '00002';
    RETURN vsCodRet, sValor, sDescripcion;
END IF;

--Inicio del procedimiento

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet, sValor, sDescripcion;

        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;


        IF EXISTS(SELECT valor FROM bdibpi:bpi_param WHERE id_param = psIdParam) THEN
            SELECT valor, descripcion INTO sValor, sDescripcion  FROM bdibpi:bpi_param WHERE id_param = psIdParam;
        ELSE
            LET vsCodRet = '00001';
        END IF;

        RETURN vsCodRet, sValor, sDescripcion;

END
END PROCEDURE
DOCUMENT
"Obtiene los valores parametrizados de diferentes conceptos necesarios para la activación del Servicio de Banca Por internet",
"Autor : Dulce Ramírez",
"FECHA : 200911",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_regkey_bex(pc_canal varchar(50), pNumCte varchar(10) ,pc_usuario varchar(20), key_seg varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   integer;

	--SET DEBUG FILE TO "/informix/ireb/bdibpi/sp_regkey_bex.out";
    --TRACE ON; 
	

	LET resultado = '00000';
	LET vcodret   = '00000';
	
BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, resultado;
			END IF;
		END EXCEPTION;

SET ISOLATION TO DIRTY READ;

		
		IF NOT EXISTS (SELECT {+INDEX(bpi_doblesesion idx_bpi_doblesesion)} usuario FROM "informix".bpi_doblesesion WHERE numcliente = pNumCte AND canal in ('PORTALBPI','APPS','BEX'))
			THEN
		
			IF EXISTS (SELECT {+INDEX(  idx_bpi_doblesesion)} usuario FROM "informix".bpi_doblesesion WHERE numcliente = pNumCte)
				THEN
					UPDATE "informix".bpi_doblesesion SET llave = key_seg/*, fecha = CURRENT*/ WHERE numcliente = pNumCte and canal=pc_canal; /*SE DEJA DE ACTUALIZAR LA FECHA*/
					--LET resultado = '00000';
			ELSE
				INSERT INTO "informix".bpi_doblesesion(numcliente, 
														usuario,
														fecha,
														canal,
														id_sesion,
														status,
														llave
														)
												VALUES (pNumCte,
														pc_usuario,
														CURRENT,
														pc_canal,
														'0',
														'0',
														key_seg
														);
								LET resultado = '00000';
			END IF;
		ELSE 
		LET resultado = '00000';
		END IF;
END;	
	RETURN	vcodret, resultado;	
	
END PROCEDURE;