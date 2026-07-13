CREATE PROCEDURE "informix".sp_ce_validaclienteinstitucion(p_cliente CHAR(20))
RETURNING CHAR(5) as codigo_retorno;

    DEFINE  sql_err			INTEGER;
    DEFINE  isam_err		INTEGER;
    DEFINE  error_info		CHAR(40);
    DEFINE  cod_ret			CHAR(6);
	DEFINE  vCountCliente	INTEGER;
	DEFINE	vEmpresa		CHAR(3);

    LET cod_ret = '00000';
	LET vCountCliente = 0;
	LET vEmpresa = "001";

    BEGIN

		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cod_ret = sql_err;

			SET DEBUG FILE TO "ErrCliente.err";
			TRACE sql_err||" * "||isam_err|| " * "||error_info;
			RETURN cod_ret;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		--VALIDAR LOS PARAMETROS DE ENTRADA
			IF p_cliente <> ' ' THEN

					--VALIDAR CLIENTE --- consulta SQL

					SET ISOLATION DIRTY READ;


					SELECT count (numcte)
					INTO vCountCliente
					FROM bdinteg:si_cliente
					where empresa = vEmpresa AND numcte = p_cliente; -- Se valida unicamente que exista el cliente.

					IF vCountCliente = 0 THEN
							LET cod_ret = '00433';
						ELSE
							LET cod_ret = '00000';
					END IF;
				ELSE
					LET cod_ret = '00330';
			END IF;
		RETURN cod_ret;
    END
END PROCEDURE;