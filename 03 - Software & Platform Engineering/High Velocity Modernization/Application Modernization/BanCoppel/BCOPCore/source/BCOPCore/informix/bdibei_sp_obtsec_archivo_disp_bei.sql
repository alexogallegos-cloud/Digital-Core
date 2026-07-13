CREATE PROCEDURE "informix".sp_obtsec_archivo_disp_bei(pParam char(11),pCteEmpresa char(9),pRegistros smallint)
	RETURNING char(5), CHAR(17);

	-- Autor: SOLSER
	-- Objetivo: Obtiene el consecutivo para la creacion de archivos para dispersion
	-- SolicitÃ³:
	-- Fecha:

--DECLARACION DE VARIABLES
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vValor INTEGER;
	DEFINE vNombreArchivo CHAR(17);


	--INICIALIZAR VALORES A VARIABLES;
	LET vCodRet='00000';
	LET vValor=0;

	--SET debug FILE TO "/home/informix/ivonne/sp_obtsec_archivo_disp_bei.out";
	--Trace ON;

	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, '';
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		FOREACH
		SELECT skip pRegistros first 10  nombre_archivo
		INTO vNombreArchivo
		FROM (
			SELECT  nombre_archivo
			FROM bdibpi:"informix".bpi_dispersarchivo
			WHERE cte_empresa=TRIM(pCteEmpresa)
			AND tipo_dispersion IN (1,2)
			AND nombre_archivo  MATCHES (pParam||'*' )
			UNION
			SELECT nombre_archivo
			FROM "informix".bei_archivos
			WHERE cte_empresa=TRIM(pCteEmpresa)
			AND nombre_archivo  MATCHES (pParam||'*' )
			)
		ORDER BY nombre_archivo

				LET vValor=1;

				RETURN vCodRet,vNombreArchivo WITH RESUME;
		END FOREACH;

		IF(vValor=0) THEN
			LET vCodRet='00001';
			RETURN vCodRet,'';
		END IF;

	END;
END PROCEDURE;