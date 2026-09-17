CREATE PROCEDURE "informix".sp_cancela_oper_manc_bei(pFecha CHAR(10))
RETURNING char (5);

--RealizÃ³: SOLSER
--Actividad: Actualiza el status de operacioens mancomunadas a Cancelado
--por fecha especificado o menor a la fecha actual
--Fecha:
--ModificaciÃ³n por David Picos  27/01/2014 , campo f_registro y tabla correcta en el 2do qwery

DEFINE sql_err integer;
DEFINE cCod_ret char (5);

LET sql_err = '';
LET cCod_ret = '00000';

--SET DEBUG FILE TO "/home/informix/david/sp_cancela_oper_manc_bei.out";
--TRACE ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cCod_ret = sql_err;
      RETURN  cCod_ret;
   END EXCEPTION;

	SET LOCK MODE TO WAIT 3 ;
    SET ISOLATION DIRTY READ ;

	IF NVL(pFecha,'') ='' THEN

		UPDATE "informix".bei_operacionesmancomunadasoperadorresumen SET
		statusoperacion = 'C',id_usuariocambiastatus = id_usuario
		WHERE statusoperacion ='P' AND f_registro <TODAY;

		UPDATE "informix".bei_operacionesmancomunadasoperador SET
		statusoperacion = 'C',id_usuariocambiastatus = id_usuario
		WHERE statusoperacion ='P' AND f_registro <TODAY;

	ELSE

		UPDATE "informix".bei_operacionesmancomunadasoperadorresumen SET
		statusoperacion = 'C',id_usuariocambiastatus = id_usuario
		WHERE statusoperacion ='P' AND f_registro < TO_DATE(pFecha, '%d/%m/%Y');

		UPDATE "informix".bei_operacionesmancomunadasoperador SET
		statusoperacion = 'C',id_usuariocambiastatus = id_usuario
		WHERE statusoperacion ='P' AND f_registro < TO_DATE(pFecha, '%d/%m/%Y');


	END IF;
	RETURN cCod_ret;

END;
END PROCEDURE;