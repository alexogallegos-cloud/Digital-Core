CREATE PROCEDURE "informix".sp_consultaconadmincorr2_totales(psArchivoOrigen CHAR(3), pdFecha DATE)
RETURNING       CHAR(3) AS archivoorigen, INTEGER AS total_registros;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen          CHAR(3);
DEFINE vnoregistros             INTEGER;
DEFINE viSqlErr                         INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vnoregistros = 0;
LET viSqlErr = 0;

--SET debug file to "/home/sysifx/conciliacion/Corresponsales/_consultaconadmincorr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
        RETURN vsarchivoorigen, vnoregistros;
        END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
        --El campo archivo origen esta en blanco o nulo.
        LET vsarchivoorigen = '001';
        RETURN vsarchivoorigen, vnoregistros;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
        --El campo fecha esta en blanco o nulo.
        LET vsarchivoorigen = '002';
        RETURN vsarchivoorigen, vnoregistros;
ELSE
        --Devuelve los registros de tabla conadmin correspondientes al tipo de archivoorigen.
        SELECT COUNT(*)
        INTO   vnoregistros
        FROM   intercard:conadmin
        WHERE  archivoorigen = psArchivoOrigen AND pdFecha BETWEEN fecha AND fecha;

        RETURN vsarchivoorigen, vnoregistros;
END IF;

END
END PROCEDURE;