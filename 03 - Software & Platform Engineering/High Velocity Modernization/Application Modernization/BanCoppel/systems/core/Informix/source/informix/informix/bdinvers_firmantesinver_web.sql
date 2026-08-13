CREATE PROCEDURE "informix".firmantesinver_web(pempresa char(3),
                        pcuenta             char(20),
                        pnumero             smallint,
                        pnombre             char(20),
                        pparentesco         char(2),
                        pnumcte             char(20),
                        ptipo               char(1))

returning           char(5);

    -- Graba y Borra Firmantes de Inversiones
    -- Autor: Frank Gaxiola Gaxiola
    -- Fecha: 17 Sep 2007
    -- BD: bdinvers

    -- **************************************************************************
    -- Define variables
    -- **************************************************************************
        define cod_ret char(5);
        define v_secuencia smallint;
        define sql_err integer;
        define isam_err integer;
        define vtipocte char(1);
        define vnum_cte char(20);
		define vvalnum boolean;
    --set debug file to '/tmp/firmantesinver.out';
    --trace on;

begin
        on exception set sql_err, isam_err
            if sql_err <> 0 or isam_err <> 0 then
                    let cod_ret = sql_err;
                    return cod_ret;
            end if;
        end exception;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
        -- **************************************************************************
        -- Inicializa variables
        -- **************************************************************************
        let cod_ret = "00000";
        let sql_err = 0;
        let isam_err = 0;
		let vvalnum = null;
        if ptipo = "1" then --Insertar
        -- **************************************************************************
        -- Verifica parametros de entrada
        -- **************************************************************************
                if pcuenta     is null or
                        pnumero       is null or
                        pnombre       is null or
                        pparentesco   is null or
                        pnumcte       is null then
                        let cod_ret = "00110";
                        return cod_ret;
                end if;


                -- **************************************************************************
                -- Determina la secuencia a grabar
                -- **************************************************************************
                select max(numero) into v_secuencia
                from sv_cotitular
                where empresa = pempresa and cuenta = pcuenta;

                if v_secuencia is null then
                        let v_secuencia = 1;
                else
                        let v_secuencia = v_secuencia + 1;
                end if;

                select num_cte into vnum_cte
                from sv_maeinv where cuenta = pcuenta;

                if not vnum_cte is null then
                        select tipo_cliente into vtipocte
                        from   bdinteg:si_cliente
                        where  numcte = vnum_cte;
                end if;

                -- **************************************************************************
                -- Graba en la tabla de cotitulares
                -- **************************************************************************
                select num_cte into vnum_cte
                from sv_maeinv where cuenta = pcuenta;

                if not vnum_cte is null then
                        select tipo_cliente into vtipocte
                        from bdinteg:si_cliente
                        where numcte = vnum_cte;
                end if;

                if(select svcte.numcte  from bdinvers:sv_cotitular svcte where svcte.empresa = pEmpresa and svcte.cuenta =  pcuenta and svcte.numcte = pnumcte) = 0 then
					    if length(pcuenta) = 11 then --se valida que la longitud de la cuenta sea la correcta y que sean solo numeros

							execute procedure bdinteg:val_num(pcuenta)	into vvalnum;
								if vvalnum = "t" then
									
									insert into sv_cotitular
											(empresa,cuenta,numero,nombre,parentesco,numcte)
									 values(pempresa,pcuenta,v_secuencia,pnombre,pparentesco,pnumcte);

									 insert into bdinteg:si_cterelacionado
											(empresa,numcte,sistema,cuenta,
											parentesco,tipo_relacion,
											tipo_cliente_ori,user_insert,
											fecha_insert)
									 values (pempresa,pnumcte,"SV",pcuenta,
											pparentesco,"03",vtipocte,USER,
											current);
								else
								let cod_ret = "00110";
								end if;		
                 
						else
						let cod_ret = "00110";
						end if;
				 else
                        let cod_ret = "00333";
                 end if;

        elif ptipo = "2" then --Borrar
                select numero into v_secuencia from bdinvers:sv_cotitular where cuenta = pcuenta and numcte = pnumcte;
                delete from bdinvers:sv_cotitular WHERE cuenta = pcuenta AND numcte = pnumcte;
                if v_secuencia < 2 THEN
                        update bdinvers:sv_cotitular set numero = 1 WHERE cuenta = pcuenta;
                end if;
        else
                let cod_ret = "00111";
        end if;

return cod_ret;
END;
END PROCEDURE;