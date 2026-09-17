CREATE PROCEDURE "informix".sp_consultaconadmincorr(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
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
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsnomarchivo325		CHAR(23);
DEFINE vsnomarchivocom		CHAR(23);
DEFINE vdfecharegistro		DATE;
DEFINE vdfecha				DATE;
DEFINE vsprodtarjeta		CHAR(4);
DEFINE vstarjeta			CHAR(16);
DEFINE vscuenta				CHAR(12);
DEFINE vstipomov			CHAR(1);
DEFINE vstran_central		CHAR(4);
DEFINE vsfolio325			CHAR(16);
DEFINE vmmonto325			MONEY(16,6);
DEFINE vsestatus			CHAR(1);
DEFINE vstxnliberacion		CHAR(4);
DEFINE vscuentac			CHAR(19);
DEFINE vscuentaa			CHAR(19);
DEFINE vsfoliosif			CHAR(16);
DEFINE vmmontosif			MONEY(16,6);
DEFINE vsusuario			CHAR(8);

DEFINE viSqlErr				INTEGER;

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
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
	END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vsusuario WITH RESUME;
ELSE
	--Devuelve los registros de tabla conadmin correspondientes al tipo de archivoorigen.
	FOREACH
	SELECT archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
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
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conadmin.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard'*/;

CREATE PROCEDURE "informix".sp_regeneracion_movimientohistorico
(
pdFechaInicial DATETIME YEAR TO FRACTION (5),
pdFechaFinal DATETIME YEAR TO FRACTION (5)
)
RETURNING INTEGER AS X, CHAR(500) AS DescripcionError, DATETIME YEAR TO FRACTION (5) AS InicioT, DATETIME YEAR TO FRACTION (5) AS FinT,
          INTEGER AS NUMREG;

--****************************************************************************************************
-- DESCRIPCION: Regenera secuencias extendidas y Surcharge de los movimientos históricos Intercard
-- AUTOR : Luis Antonio Gómez Santiago
-- FECHA : 13/07/2010
-- BD: Intercard
-- SISTEMA : SIF
--***************************************************************************************************

DEFINE vsDecripcionError CHAR(500);
DEFINE viSqlErr INTEGER;

DEFINE vsFlagEnTransaccion CHAR(1);
DEFINE viContadorRegistros INTEGER;
DEFINE viContadorRegistrosTot INTEGER;

DEFINE v_secuencia VARCHAR(7);
DEFINE v_numtarjeta VARCHAR(16);
DEFINE v_fechahorainauth DATETIME YEAR TO FRACTION (5);
DEFINE v_prodind VARCHAR(2);
DEFINE v_montosurcharge DECIMAL(19,4);
DEFINE v_fechalocaltransaccion VARCHAR(4);
DEFINE v_horalocaltransaccion VARCHAR(6);
DEFINE vdInicio DATETIME YEAR TO FRACTION (5);
DEFINE vdFin DATETIME YEAR TO FRACTION (5);

LET vsDecripcionError = "";
LET viSqlErr = 0;
LET v_secuencia = "";
LET v_numtarjeta = "";
LET v_fechahorainauth = CURRENT;
LET v_prodind = "";
LET v_montosurcharge = 0.0;
LET vdInicio = CURRENT;
LET vdFin = CURRENT;
LET v_fechalocaltransaccion = "";
LET v_horalocaltransaccion = "";

BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN 
		RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/secuencia.out";
--TRACE ON;

IF(pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 1 ;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

IF (pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 2;	
    RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END IF;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
LET viContadorRegistrosTot = 0;

FOREACH WITH HOLD                  
           select {+INDEX(intercard:movimientohistorico idx_movimiento3)}                         
                secuencia, numtarjeta, fechahorainauth, prodind, montosurcharge 
           into v_secuencia, v_numtarjeta, v_fechahorainauth, v_prodind, v_montosurcharge 
           from intercard:movimientohistorico
           where fechahorainauth between pdFechaInicial and pdFechaFinal      
           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           IF (v_prodind = '01' AND v_montosurcharge > 0.0) THEN
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                             (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia),
                         surcharge = 'V'
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           ELSE
               update {+INDEX(intercard:movimientohistorico idx_movimiento3)}         
                         intercard:movimientohistorico
                     set secuenciaextendida = 
                         (fechalocaltransaccion || substring(horalocaltransaccion from 1 for 4)  || secuencia) 
                     where fechahorainauth = v_fechahorainauth and
                           numtarjeta = v_numtarjeta and
                           secuencia = v_secuencia; 
           END IF;

           LET viContadorRegistros = viContadorRegistros + 1;           

           IF (viContadorRegistros = 10000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;           
           LET vsFlagEnTransaccion = 'F';
           LET viContadorRegistrosTot = viContadorRegistrosTot + viContadorRegistros;
        END IF;
END
LET vdFin = current;
RETURN viSqlErr, vsDecripcionError, vdInicio, vdFin, viContadorRegistrosTot;
END PROCEDURE;