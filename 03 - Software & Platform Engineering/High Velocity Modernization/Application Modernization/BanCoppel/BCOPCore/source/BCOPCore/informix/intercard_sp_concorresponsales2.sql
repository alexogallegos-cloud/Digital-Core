CREATE PROCEDURE "informix".sp_concorresponsales2(
psArchivoOrigen CHAR(3),
pdFecha DATE,
pRegistros INTEGER, 
pRecuperacion INTEGER
)

RETURNING	CHAR(4) AS idterminal,
			DATETIME YEAR TO FRACTION(5) AS fechamov, 
			MONEY(16,6) AS monto,
			MONEY(16,6) AS comision, 
			MONEY(16,6) AS comisioniva,
			MONEY(16,6) AS idtpooperacion;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsidterminal			CHAR(4);
DEFINE vdfechamov			DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto				MONEY(16,6);
DEFINE vmcomision			MONEY(16,6);
DEFINE vmcomisioniva		MONEY(16,6);
DEFIne vmidtpooperacion     MONEY(16,6);

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsidterminal = '';
LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;
LET vmidtpooperacion = 0.0;

LET viSqlErr = 0;

--SET DEBUG FILE TO "/home/sysifx/conciliacion/corresponsales/sp_concorresponsales.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0);
	END IF;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0);
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0);
ELSE
	--Se formatea el parametro fecha para realizar la consulta
	LET pdFecha = MDY(MONTH(pdFecha), DAY(pdFecha), YEAR(pdFecha)) -1 UNITS DAY;
	--Verifica si el archivoorigen proporcionado corresponde al archivo comisiones interrredes.
	IF((psArchivoOrigen = 'ACI') OR (psArchivoOrigen = 'ACC') OR (psArchivoOrigen = 'ACT'))THEN
		FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion idterminal, fechamov, monto, comision, comisioniva, idtpooperacion
		INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva, vmidtpooperacion
		FROM   intercard:conarchcomisiones
		WHERE  archivoorigen = psArchivoOrigen AND fechamov::DATE = pdFecha ORDER BY keyx ASC
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
		END FOREACH
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que tome en cuenta las TRANSFERENCIAS DE PRESTAMOS.',
'Fecha: 31/05/2011',
'VERSION: 20110531.1747';,
'',
'Modifico:  L.I.A. Ricardo ResÃ©ndiz MartÃ­nez'
'Modificacion: SE modifica retorno para agregar campo de que almacena los tipos de identificadores de las operaciones por nuevo archivo de corresponsales.',
'Solicito: Jose Luis Puebla Salinas'
'Fecha: 14/10/2015',
'VERSION: 20151014.1747'; */           ;

CREATE PROCEDURE "informix".sp_concorresponsales2_totales(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(4) AS idterminal,
			INTEGER AS no_registros;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsidterminal			CHAR(4);
DEFINE vnoregistros             INTEGER;

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsidterminal = '';
LET vnoregistros = 0;

LET viSqlErr = 0;

--SET DEBUG FILE TO "/home/sysifx/conciliacion/corresponsales/sp_concorresponsales.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN  NVL(vsidterminal,''), 
				vnoregistros;
	END IF;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN  NVL(vsidterminal,''), 
			vnoregistros;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN  NVL(vsidterminal,''), 
			vnoregistros;
ELSE
	--Se formatea el parametro fecha para realizar la consulta
	LET pdFecha = MDY(MONTH(pdFecha), DAY(pdFecha), YEAR(pdFecha)) -1 UNITS DAY;
	--Verifica si el archivoorigen proporcionado corresponde al archivo comisiones interrredes.
	IF((psArchivoOrigen = 'ACI') OR (psArchivoOrigen = 'ACC') OR (psArchivoOrigen = 'ACT'))THEN

		SELECT COUNT(*)
        INTO   vnoregistros
		FROM   intercard:conarchcomisiones
		WHERE  archivoorigen = psArchivoOrigen AND fechamov::DATE = pdFecha;
		
		RETURN  NVL(vsidterminal,''), 
				vnoregistros;
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que tome en cuenta las TRANSFERENCIAS DE PRESTAMOS.',
'Fecha: 31/05/2011',
'VERSION: 20110531.1747';,
'',
'Modifico:  L.I.A. Ricardo ResÃ©ndiz MartÃ­nez'
'Modificacion: SE modifica retorno para agregar campo de que almacena los tipos de identificadores de las operaciones por nuevo archivo de corresponsales.',
'Solicito: Jose Luis Puebla Salinas'
'Fecha: 14/10/2015',
'VERSION: 20151014.1747'; */ ;

CREATE PROCEDURE "informix".sp_consultaconadmin2(psArchivoOrigen CHAR(3), pdFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING       CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
                        CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(15) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
                        CHAR(19) AS cuentaa, CHAR(15) AS foliosif, MONEY(16,6) AS montosif, CHAR(7) AS secintercard, MONEY(16,6) AS montointcrd, DATETIME YEAR TO FRACTION(5) AS fechahorainauth, CHAR(4) AS idterminal,
                        CHAR(1) AS tipooperacion, CHAR(8) AS usuario, DATETIME YEAR TO FRACTION(5) AS fechamov, MONEY(16,6) AS monto, MONEY(16,6) AS comision, MONEY(16,6) AS comisioniva;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de interredes, obtiene informacion de tabla conadmin y conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 01/19/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen          CHAR(3);
DEFINE vsnomarchivo325          CHAR(23);
DEFINE vsnomarchivo                     CHAR(23);
DEFINE vsnomarchivocom          CHAR(23);
DEFINE vdfecharegistro          DATE;
DEFINE vdfecha                          DATE;
DEFINE vsprodtarjeta            CHAR(4);
DEFINE vstarjeta                        CHAR(16);
DEFINE vscuenta                         CHAR(12);
DEFINE vstipomov                        CHAR(1);
DEFINE vstran_central           CHAR(4);
DEFINE vsfolio325                       CHAR(15);
DEFINE vmmonto325                       MONEY(16,6);
DEFINE vsestatus                        CHAR(1);
DEFINE vstxnliberacion          CHAR(4);
DEFINE vscuentac                        CHAR(19);
DEFINE vscuentaa                        CHAR(19);
DEFINE vsfoliosif                       CHAR(15);
DEFINE vmmontosif                       MONEY(16,6);
DEFINE vssecintercard           CHAR(7);
DEFINE vmmontointcrd            MONEY(16,6);
DEFINE vdfechahorainauth        DATETIME YEAR TO FRACTION(5);
DEFINE vsidterminal                     CHAR(4);
DEFINE vstipooperacion          CHAR(1);
DEFINE vsusuario                        CHAR(8);

DEFINE vdfechamov                       DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto                          MONEY(16,6);
DEFINE vmcomision                       MONEY(16,6);
DEFINE vmcomisioniva            MONEY(16,6);


DEFINE viSqlErr                         INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivo        = '';
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
LET vssecintercard = '';
LET vmmontointcrd = 0.0;
LET vdfechahorainauth = CURRENT;
LET vsidterminal = '';
LET vstipooperacion = '';
LET vsusuario = '';

LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;

LET viSqlErr = 0;

--set debug file to "/informixuc7/perifericos/prueba.out";
--Trace on;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF viSqlErr <> 0 THEN
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
        END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
        --El campo archivo origen esta en blanco o nulo.
        LET vsarchivoorigen = '001';
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
        --El campo fecha esta en blanco o nulo.
        LET vsarchivoorigen = '002';
        RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
ELSE
        --Verifica si el archivoorigen proporcionado fue archivo de comisiones(ADC).
        IF(psArchivoOrigen = 'ADC')THEN
        LET pdFecha = MDY(Month(pdFecha),day(pdFecha),year(pdFecha)) -1 units day;
        FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion idterminal, fechamov, monto, comision, comisioniva
                INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva
                FROM   intercard:conarchcomisiones
        WHERE  fechamov::DATE = pdFecha ORDER BY keyx ASC
                RETURN '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
                           NVL(vsidterminal,''), '', '', NVL(vdfechamov,CURRENT), NVL(vmmonto,0.0), NVL(vmcomision,0.0), NVL(vmcomisioniva,0.0) WITH RESUME;
                END FOREACH
        ELSE
                IF (psArchivoOrigen = 'TCD') THEN
                        LET vsnomarchivo = TRIM ('BCPLTCD_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
                ELSE
                        LET vsnomarchivo = TRIM ('BCPLTCC_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
                END IF; 
        
                FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion {+index (intercard:conadmin idx_conadmin4)} archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
                           cuentac, cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario
                INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                           vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario
                FROM   intercard:conadmin
                WHERE  archivoorigen = psArchivoOrigen and nomarchivo325 = vsnomarchivo ORDER BY keyx ASC

                RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
                           vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '' WITH RESUME;
               
        END FOREACH
        END IF;
END IF;

END
END PROCEDURE;