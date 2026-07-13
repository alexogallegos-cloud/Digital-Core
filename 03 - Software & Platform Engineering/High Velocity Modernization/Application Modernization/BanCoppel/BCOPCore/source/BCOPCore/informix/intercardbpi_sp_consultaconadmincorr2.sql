CREATE PROCEDURE "informix".sp_consultaconadmincorr2(psArchivoOrigen CHAR(3), pdFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING       CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
                        CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(16) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
                        CHAR(19) AS cuentaa, CHAR(16) AS foliosif, MONEY(16,6) AS montosif, CHAR(8) AS usuario;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen          CHAR(3);
DEFINE vsnomarchivo325          CHAR(23);
DEFINE vsnomarchivocom          CHAR(23);
DEFINE vdfecharegistro          DATE;
DEFINE vdfecha                          DATE;
DEFINE vsprodtarjeta            CHAR(4);
DEFINE vstarjeta                        CHAR(16);
DEFINE vscuenta                         CHAR(12);
DEFINE vstipomov                        CHAR(1);
DEFINE vstran_central           CHAR(4);
DEFINE vsfolio325                       CHAR(16);
DEFINE vmmonto325                       MONEY(16,6);
DEFINE vsestatus                        CHAR(1);
DEFINE vstxnliberacion          CHAR(4);
DEFINE vscuentac                        CHAR(19);
DEFINE vscuentaa                        CHAR(19);
DEFINE vsfoliosif                       CHAR(16);
DEFINE vmmontosif                       MONEY(16,6);
DEFINE vsusuario                        CHAR(8);

DEFINE viSqlErr                         INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivocom = '';
LET vdfecharegistro = CURRENT;
LET vdfecha = CURRENT;
LET vsprodtarjeta = '';
LET vstarjeta = '';
LET vscuenta = '';
LET vstipomov = '';
LET vstran_central = '';
LET vsfolio325 = '';
LET vmmonto325 = 0.0;
LET vsestatus = '';
LET vstxnliberacion = '';
LET vscuentac = '';
LET vscuentaa = '';
LET vsfoliosif = '';
LET vmmontosif = 0.0;
LET vsusuario = '';

LET viSqlErr = 0;

--SET debug file to "/home/sysifx/conciliacion/Corresponsales/_consultaconadmincorr.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario;
        END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
        --El campo archivo origen esta en blanco o nulo.
        LET vsarchivoorigen = '001';
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
        --El campo fecha esta en blanco o nulo.
        LET vsarchivoorigen = '002';
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario;
ELSE
        --Devuelve los registros de tabla conadmin correspondientes al tipo de archivoorigen.
        FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
                   cuentac, cuentaa, foliosif, montosif, usuario
        INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario
        FROM   intercard:conadmin
        WHERE  archivoorigen = psArchivoOrigen AND pdFecha BETWEEN fecha AND fecha ORDER BY keyx ASC

        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
        END FOREACH
END IF;

END
END PROCEDURE;