CREATE PROCEDURE "informix".sp_consulta_tkn_parametros(pIdParam CHAR(2))
	RETURNING CHAR(5), CHAR(2), CHAR(50), CHAR(100);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizo: Solser
-- Descripcion: Obtiene el detalle del parametro con el id enviado
-- Fecha de Construccion: 13/08/2018 
-----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER;
    DEFINE vIdParam CHAR(2);
	DEFINE vValor CHAR(50);
	DEFINE vDescripcion CHAR(100);
	
	LET vCodRet = '00000';
    LET vIdParam = '';
	LET vValor = '';
	LET vDescripcion = '';
	

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_tkn_parametros.out";
 -- TRACE ON;
	
	 SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;
	 
	 
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, vIdParam, vValor, vDescripcion;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		IF(NVL(pIdParam, '') == '') THEN
            LET vCodRet = '00001'; -- Algun parametro requerido es nulo
            RETURN vCodRet, vIdParam, vValor, vDescripcion;
        END IF;

        SELECT NVL(id_param, ''), NVL(valor, ''), NVL(descripcion, '')
            INTO vIdParam, vValor, vDescripcion
        FROM bdibpi:tkn_parametros 
            WHERE id_param = pIdParam;

		RETURN vCodRet, vIdParam, vValor, vDescripcion;

	END
END PROCEDURE;