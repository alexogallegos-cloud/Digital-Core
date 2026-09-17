CREATE PROCEDURE "informix".sp_sn_retrieve_account_benefit(pNumCta CHAR(20),pIdBeneficio SMALLINT)
        RETURNING CHAR(5), SMALLINT, SMALLINT

        DEFINE vcodret	CHAR(5);
        DEFINE sqlErr	INTEGER;
        DEFINE iPorcentaje   SMALLINT;
        DEFINE iExclusion SMALLINT;

        LET vcodret = "00001";
        LET sqlErr = 0;
        LET iPorcentaje = 100;
        LET iExclusion = 0;

BEGIN
	
	ON EXCEPTION SET sqlErr
		IF sqlErr <> 0 THEN
			LET vcodret = sqlErr;
			RETURN vcodret,iExclusion,iPorcentaje;
		END IF;
	END EXCEPTION;

        -- SET DEBUG FILE TO "/INFORMIXDUMP/sp_sn_retrieve_account_benefit.trc";
        -- TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF TRIM(pNumCta) = '' THEN
                RETURN vcodret,iExclusion,iPorcentaje;
        END IF;
	
        SELECT FIRST 1 beneficio.exclusion,beneficio.porcentaje
        INTO iExclusion,iPorcentaje
        FROM "informix".sn_cte_cta_nomina nomina
        INNER JOIN "informix".sn_relacion_gpo_beneficios_cta_nomina gpoBeneficios
                ON gpoBeneficios.idGrupo = nomina.grupoBeneficios
        INNER JOIN "informix".sn_beneficios_cta_nomina beneficio
                ON gpoBeneficios.idBeneficio = beneficio.idBeneficio
        WHERE nomina.numcta = pNumCta
                AND gpoBeneficios.idBeneficio = pIdBeneficio;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                LET vcodret = "00002";
                LET iPorcentaje = 100;
                LET iExclusion = 0; 
        ELSE
                LET vcodret = "00000";
        END IF;

        RETURN vcodret,iExclusion,iPorcentaje;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Este procedimiento almacenado consulta los beneficios que estan relacionados a una cuenta de nomina',
'PETICION: Iniciativa cuenta Nomina',
'AUTOR: Jorge Arturo Astorga',
'FECHA DE CREACION: 2022/08/19',
'BD: bdiadminnomina';