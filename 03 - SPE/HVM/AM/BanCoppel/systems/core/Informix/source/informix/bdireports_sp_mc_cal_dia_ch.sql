CREATE PROCEDURE "informix".sp_mc_cal_dia_ch(dFecha DATE,cTrimestre CHAR(5), 
                                             iMes INTEGER)
       RETURNING CHAR (5), CHAR(500);

/*
#############################################################################%
#   Autor: ACCB                                                              %
#   Fecha: 08/01/2015                                                        %
#   Modificación: Se modifica para que genere el Cálculo Diario Crédito      %
#                 de MasterCard de las tablas históricas.                    %
#                 ban_bin igual al parametro'MCR' --MASTERCARD CRÉDITO       %
#   Autor: L. Montserrat León Amador                                         %
#   Fecha: 02/10/2017                                                        %
#   Modificación: Se modifica spl para quitar de los procesos diarios de     %
#				  Tarjetas de Crédito y de Débito el método actual usado     %
#				  para retiros en ATMs.                                     %
#				                                                             %
#				  Se modifica spl para separar el registro de información    %
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

--SET DEBUG FILE TO "/tmp/mfinis/sp_mc_cal_dia_ch.out";
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
EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_dia_ch_interno(dFecha, cTrimestre, iMes, Vclavetarjeta)
INTO cCodRet, cVarDataErr;

--IF cCodRet::INTEGER = 0 THEN

	LET Vclavetarjeta = 10;
	
	--EJECUCIÓN DE PROCEDIMIENTO CON PRODUCTO ORO
	EXECUTE PROCEDURE bdireports:"informix".sp_mc_cal_dia_ch_interno(dFecha, cTrimestre, iMes, Vclavetarjeta)
	INTO cCodRet, cVarDataErr;
	
--END IF;

RETURN cCodRet,cVarDataErr;

END PROCEDURE;