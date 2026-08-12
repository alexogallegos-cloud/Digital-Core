CREATE PROCEDURE "informix".sp_consultacatestados(pDesde INTEGER, pHasta INTEGER)
RETURNING CHAR(6), CHAR(80), CHAR(2), CHAR(30);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);

DEFINE v_estado         CHAR(2);
DEFINE v_nombre       CHAR(30);


------------------------------------------------------------

-- Creado: Walber Castro
-- Fecha: 28 de mayo de 2010
-- Crear en BDINTEG
-- Se crea con el objetivo de consultar el catalogo de estados por medio de paginación.
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';

LET v_estado = '';
LET v_nombre = '';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje, v_estado, v_nombre;
	    END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_consultacatestados.out";
--TRACE ON;

foreach
    SELECT SKIP pDesde FIRST pHasta NVL(estado,''), TRIM(NVL(nombre,'')) 
    INTO v_estado, v_nombre
    FROM bdinteg:si_estados
    ORDER BY estado

    RETURN cCod_ret, cMensaje, v_estado, v_nombre WITH RESUME;
    LET cCod_ret = '';
    LET cMensaje = '';
END foreach;

END;
END PROCEDURE;