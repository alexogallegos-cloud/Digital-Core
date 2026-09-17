CREATE PROCEDURE "informix".sp_mes_siguiente
					(
					pFechaInicial 	DATE,	-->Fecha Calculo Inicial
					pMeses		INT,	-->Numero de Meses Proyectar
					pDiaFechaCorte	INT	-->Numero Dia Corte
					)	
RETURNING CHAR(5),-->Codigo de Retorno
	  DATE ,  -->Fecha de Siguiente
	  INT ;   -->Numero de dias Transcurridos
         
DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;

DEFINE vFechaCorte	DATE;
DEFINE vUltimoDiaMes	DATE;
DEFINE vDiaTras		INT;
	
LET vcodret = "000";

LET vFechaCorte	= " ";
LET vUltimoDiaMes = " ";
LET vDiaTras	= 0;

--SET DEBUG FILE TO "/tmp/sp_mes_siguiente.out";
--TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;
	   
	   RETURN vcodret,--> Codigo de Retorno
	          vFechaCorte,--> Fecha de Otorgamiento
	          vDiaTras;	--> Fecha de Ultimo Pago
	END EXCEPTION;

	LET vFechaCorte = MONTH(pFechaInicial) ||"/01/"|| YEAR(pFechaInicial); 
	LET vFechaCorte = vFechaCorte + pMeses UNITS MONTH;
	
	IF pDiaFechaCorte >= 29 AND MONTH(vFechaCorte) = 2 THEN
	   IF MOD(YEAR(vFechaCorte),4) = 0 THEN
	      LET vFechaCorte = MONTH(vFechaCorte) ||"/"|| "29" ||"/"|| YEAR(vFechaCorte); 		
	   ELSE
	      LET vFechaCorte = MONTH(vFechaCorte) ||"/"|| "28" ||"/"|| YEAR(vFechaCorte); 		
	   END IF
	ELSE
	   LET vUltimoDiaMes = (vFechaCorte + 1 UNITS MONTH) - 1 UNITS DAY;
	   IF pDiaFechaCorte <= DAY(vUltimoDiaMes) THEN
   	      LET vFechaCorte = MONTH(vFechaCorte) ||"/"|| pDiaFechaCorte ||"/"|| YEAR(vFechaCorte); 		
   	   ELSE
	      LET vFechaCorte = MONTH(vFechaCorte) ||"/"|| DAY(vUltimoDiaMes) ||"/"|| YEAR(vFechaCorte); 		
	   END IF

	END IF;

	LET vDiaTras = vFechaCorte - pFechaInicial;
		 
    RETURN vcodret, vFechaCorte, vDiaTras;

END
END PROCEDURE
;