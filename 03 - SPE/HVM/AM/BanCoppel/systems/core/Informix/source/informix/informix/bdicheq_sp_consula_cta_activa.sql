CREATE PROCEDURE "informix".sp_consula_cta_activa(pCuenta CHAR(20))
   returning char(5);

    -- Creado por: Mauricio Leon
    -- Actividad:  Consulta la existencia y el estatus activo de una cuenta
    -- Solicito:   Ismael Hernandez
    -- Fecha:      23/09/2011

    -- Define variables
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE vCont smallint;

    -- Inicializa variables
    LET cod_ret  = "000";
    LET vCont = 0;

    BEGIN

        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                let cod_ret = sql_err;
                RETURN cod_ret;
            END IF ;
        END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;

        SELECT count(*) INTO vCont FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta AND status_cta <> 2;

        IF vCont = 0 THEN
            LET cod_ret = '001';
        END IF ;

		RETURN cod_ret;

    END
END PROCEDURE
;