CREATE PROCEDURE "informix".trace_movimientos_cons(pFolio CHAR(30), pRuta CHAR(200)) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de movimientos en archivo
-- AUTOR : Jose Leon Arellano 
-- FECHA : 13/Julio/2016
-- BD: bdibei
-- FECHA DE LIBERACIï¿½?N: 29/Julio/2016
-- Fecha de Modificacion: 04/Abril/2017
--Modificacion: Se modifica el ORDER de los queries de movimientos a solo fecha y hora, debido a un descuadre del ID SERIAL
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 08 Diciembre 2022

--Modificacion: A solicitud de usuario, se reversa el cambio del 8 de Diciembre porque no resolvÃ­o el problema de ordenamiento de raiz
--Modifico: Armando Barrientos - BanCoppel - Internet.
--FechaMod: 14 Diciembre 2022
--****************************************************************************************************

-- Definicion de variables
    DEFINE vFile CHAR(300);
    DEFINE vSql CHAR(300);
    DEFINE vCommand CHAR(900);
-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
	DEFINE vRegistos INTEGER;
    DEFINE cod_ret CHAR(5);
	LET cod_ret  = '00000';
	
    --set debug file to "/informix/gaby/ArchivosOut/trace_movimientos_cons.out";
    --Trace on;
	
BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
--    LET vFile = '/home/sysemnet/movempresanet/'||TRIM(pFolio)|| '.txt';
--    LET vSql = '/home/sysemnet/movempresanet/sqlConMovsBatch.sql';
    LET vFile = TRIM(pRuta)||TRIM(pFolio)|| '.txt';
    LET vSql = TRIM(pRuta)||'sqlConMovsBatch.sql';
	LET vRegistos = 0;
	 
	SELECT count(*) INTO vRegistos FROM "informix".bei_movimientos_cons WHERE folio = pFolio;
	 
    IF (vRegistos > 0) THEN
        LET vCommand = 'echo " UNLOAD TO '||vFile||' DELIMITER ' || '''|'' '||
                       'SELECT folio,fecha,transacc,naturaleza,saldo,importe,descripcion,referencia,cuenta '||
                       'FROM bei_movimientos_cons AS movs WHERE folio='||pFolio||'  ORDER BY movs.fecha DESC,movs.num_serial DESC" > '||vSql;
		IF (vCommand <> '') THEN 
			SYSTEM vCommand;
			LET vCommand = 'dbaccess bdibei '||vSql;
			SYSTEM vCommand;
            LET vCommand = 'rm -r '||vSql;
            SYSTEM vCommand;
		END IF;
    ELSE
        LET cod_ret = '00005';
    END IF;

	RETURN cod_ret;
END;
END PROCEDURE;