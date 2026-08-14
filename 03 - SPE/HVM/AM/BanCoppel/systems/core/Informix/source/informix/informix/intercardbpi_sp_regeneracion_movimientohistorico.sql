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