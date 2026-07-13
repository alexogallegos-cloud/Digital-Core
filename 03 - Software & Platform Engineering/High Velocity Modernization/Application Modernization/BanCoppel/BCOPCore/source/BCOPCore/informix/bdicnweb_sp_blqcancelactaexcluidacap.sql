CREATE PROCEDURE "informix".sp_blqcancelactaexcluidacap(cID_USUARIOC CHAR(8),
                                                        cID_FUNCIONC CHAR(10))
       RETURNING CHAR(5) AS codRet;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

DEFINE iExiste           	INTEGER;

--inicializando variables
LET cCodRet 		= "00000";
LET iSql_err 		= 0 ;	

LET iExiste		= 0;

SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	THEN
		LET cCodRet = "00036";
		RETURN cCodRet;
	END IF;	

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,
                                                                       cID_FUNCIONC)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
		RETURN cCodRet;
        END IF;
--
	select {+INDEX (bdicnweb:sc_cuentas_concentradas_excluidas idx_ctaconcentradaex)} count(*)
	into iExiste
	from bdicnweb:"informix".sc_cuentas_concentradas_excluidas where cuenta>0;
			
	if iExiste = 0 then -- La cuenta no existe en la tabnla de sc_cuentas_concentradas_excluidas
		LET cCodRet = "00000";
		RETURN cCodRet;
	end if;
	
	DELETE {+INDEX (bdicnweb:sc_cuentas_concentradas_excluidas idx_ctaconcentradaex)} FROM bdicnweb:"informix".sc_cuentas_concentradas_excluidas where cuenta>0;
	RETURN cCodRet;
END;
	
END PROCEDURE;