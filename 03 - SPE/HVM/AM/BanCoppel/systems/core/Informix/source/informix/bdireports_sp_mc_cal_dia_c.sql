CREATE PROCEDURE "informix".sp_mc_cal_dia_c(dFecha DATE, cTrimestre CHAR(5),
                                            iMes SMALLINT)
       RETURNING CHAR (5), CHAR(500);

/*
#############################################################################%
#				                                                             %
#            Se modifica spl para separar el registro de información         %
#				  por Producto: Platino y Oro.                               %
#############################################################################%
*/

--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(500);
DEFINE cCodret                    CHAR(5);

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO 
DEFINE Vclavetarjeta 			  SMALLINT;

ON EXCEPTION SET iSqlErr
   IF iSqlErr <> 0 THEN
      LET cVarDataErr = cVarDataErr||'ERROR NO CONTROLADO (' || iSqlErr || ').';
      LET cCodret='-1';
      RETURN cCodret, cVarDataErr;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/ifxsif01/ilopez/Pruebas_SP/sp_mc_cal_dia_c.out";
--TRACE ON;

--MANEJO DE ERRORES
LET iSqlErr = 0; 
LET cCodret = '00000';
LET cVarDataErr = '';

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
LET Vclavetarjeta = 9;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--EJECUCIÓN DE PROCEDIMIENTO CON PRODUCTO PLATINO
EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_dia_c_interno(dFecha, cTrimestre, iMes, Vclavetarjeta)
INTO cCodRet, cVarDataErr;

--IF cCodRet::INTEGER = 0 THEN

	LET Vclavetarjeta = 10;
	
	--EJECUCIÓN DE PROCEDIMIENTO CON PRODUCTO ORO
	EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_dia_c_interno(dFecha, cTrimestre, iMes, Vclavetarjeta)
	INTO cCodRet, cVarDataErr;
	
--END IF;		

RETURN cCodRet,cVarDataErr;

END PROCEDURE;