CREATE PROCEDURE "informix".sp_mc_cal_men_c(cTrimestre CHAR(5),iMes INTEGER)
       RETURNING CHAR (5), CHAR(500);

/*drop procedure sp_mc_cal_men_c
####################################################################################
#                                                                                  #
# Ejecuta "sp_mc_cal_men" para calculo Mensual de los productos Oro,Platino        #
####################################################################################
*/

--- GENERALES
DEFINE cCodret                   CHAR(5);
DEFINE cVarDataErr               CHAR(500);
DEFINE iSqlErr                   INTEGER;

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO 
DEFINE Vclavetarjeta 		    SMALLINT;

  ON EXCEPTION SET iSqlErr
     LET cVarDataErr = ' ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
     LET cCodret = '-1';
     RETURN cCodret, cVarDataErr;
  END EXCEPTION;

--- GENERALES
LET cCodret = '00000';
LET cVarDataErr = ' ';
LET iSqlErr = 0; 

--VARIABLES QUE IDENTIFICAN EL TIPO DE PRODUCTO
LET Vclavetarjeta = 9;

--SET DEBUG FILE TO "/respaldos/sp_mc_cal_men_c.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--EJECUCIÓN DE PROCEDIMIENTO CON PRODUCTO PLATINO
EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_men_c_interno(cTrimestre, iMes, Vclavetarjeta)
INTO cCodRet, cVarDataErr;

--IF cCodRet::INTEGER = 0 THEN

	LET Vclavetarjeta = 10;
	
	--EJECUCIÓN DE PROCEDIMIENTO CON PRODUCTO ORO
	EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_men_c_interno(cTrimestre, iMes, Vclavetarjeta)
	INTO cCodRet, cVarDataErr;
	
--END IF;

RETURN cCodret,cVarDataErr;

END PROCEDURE;