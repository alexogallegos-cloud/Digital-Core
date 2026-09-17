CREATE PROCEDURE "informix".miomio_web()
RETURNING  VARCHAR(5), DATE, DATETIME YEAR TO MONTH;

define fecha    DATETIME YEAR TO MONTH;
define fechahoy DATE;
define cCodRet  VARCHAR(5);

LET cCodRet = '00000';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO fechahoy
   FROM sd_fechas;
   
LET fecha = fechahoy;

RETURN
 cCodRet, fechahoy, fecha;
END PROCEDURE;