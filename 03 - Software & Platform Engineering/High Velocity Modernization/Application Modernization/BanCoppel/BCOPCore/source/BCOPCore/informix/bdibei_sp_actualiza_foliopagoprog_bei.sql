CREATE PROCEDURE "informix".sp_actualiza_foliopagoprog_bei(pIdOperacion INTEGER, folioPagoProg CHAR(20))
 returning char(5);
--****************************************************************************************************
-- DESCRIPCION:  Modifica Folio de Pago Programado
-- AUTOR : Solser
-- FECHA : 26/09/2014
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    SET LOCK MODE TO WAIT 4;
    
	LET cod_ret  = "00000";
	BEGIN
	   ON EXCEPTION SET sql_err
			ROLLBACK WORK;
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
			END IF ;
	   END EXCEPTION ;

	   IF(LENGTH(TRIM(NVL(folioPagoProg, ''))) = 0) THEN
			LET cod_ret = "001"; --Folio esta vacio
			RETURN cod_ret;
	   END IF;

	   IF(pIdOperacion <= 0 OR pIdOperacion IS NULL) THEN
			LET cod_ret = "002"; --Id de Operacion incorrecto
			RETURN cod_ret;
	   END IF;

	   Update 	"informix".bei_operacionesmancomunadasoperadorresumen 
	   Set		folioPagoProgramado = folioPagoProg
	   Where 	id_operacion = pIdOperacion;

	   RETURN cod_ret;
	END    
END PROCEDURE;