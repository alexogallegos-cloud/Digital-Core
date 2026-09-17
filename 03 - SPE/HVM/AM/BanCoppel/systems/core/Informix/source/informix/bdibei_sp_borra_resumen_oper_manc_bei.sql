CREATE PROCEDURE "informix".sp_borra_resumen_oper_manc_bei()
RETURNING char (5);

--RealizÃ³: SOLSER
--Actividad: Borra el Historial de los ultimos N dias, Esto no afecta la tabla de Concentrado
--Fecha:

DEFINE sql_err integer;
DEFINE cCod_ret char (5);
DEFINE vCantidad smallint;
LET sql_err = '';
LET cCod_ret = '00000';
LET vCantidad = 0;

--SET debug FILE TO "/home/informix/david/sp_borra_resumen_oper_manc_bei.out";
--	Trace ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cCod_ret = sql_err;
      RETURN  cCod_ret;
   END EXCEPTION;

	SET LOCK MODE TO WAIT 3 ;
	SET ISOLATION DIRTY READ ;
	
	SELECT valor
		INTO vcantidad
		FROM bdinteg:"informix".si_param
		WHERE cod_param = 194 and empresa = '001';
		
		IF NVL(vCantidad,-1) = -1 THEN

		DELETE "informix".bei_operacionesmancomunadasoperadorresumen
		WHERE f_aplicacion <=(TODAY-5);
	ELSE
		DELETE "informix".bei_operacionesmancomunadasoperadorresumen
		WHERE f_aplicacion <=(TODAY-vCantidad);
	END IF;

	RETURN cCod_ret;

END;

END PROCEDURE;