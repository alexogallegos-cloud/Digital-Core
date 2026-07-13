CREATE PROCEDURE "informix".sp_obtsec_archivo_dispodp_bei(pParam char(9),pCteEmpresa char(9),pRegistros smallint)
	RETURNING char(5), CHAR(17);

	-- Autor: SOLSER
	-- Objetivo: Obtiene el consecutivo para la creacion de archivos para dispersion


    --DECLARACION DE VARIABLES
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vValor INTEGER;
	DEFINE vNombreArchivo CHAR(17);


	--INICIALIZAR VALORES A VARIABLES;
	LET vCodRet='00000';
	LET vValor=0;

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
		SELECT skip pRegistros first 10   SUBSTRING(nombre_archivo FROM 0 FOR 12) as nombre_archivo
		INTO vNombreArchivo
        From   (
            select distinct nombre_archivo
            from bei_operacionesmancomunadasoperador
            where id_cat_operacion = '3004'
            And   nombre_archivo MATCHES( trim(pParam)||'*')
            And   id_cliente = trim(pCteEmpresa)
            And    (statusoperacion = 'P' OR statusoperacion = 'R')
            Union 
            Select distinct archivo 
            From   bei_dispersiones_odp
            Where  tipo_dispersion = '3004'
            And    archivo MATCHES( trim(pParam)||'*')
            And    num_cliente = trim(pCteEmpresa)
        )
        Order By nombre_archivo asc

        LET vValor=1;
        RETURN vCodRet,vNombreArchivo WITH RESUME;
		END FOREACH;

		IF(vValor==0) THEN
			LET vCodRet='00001';
			RETURN vCodRet,'';
		END IF;

	END;
END PROCEDURE;