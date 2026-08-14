create procedure "informix".cons_chq_bpi_res(pempresa char(3),
                                     pnum_cte char(20),
                                     pmoneda char(2))
   returning char(5),char(20),char(20), char(20);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err , vRegistros integer;
   define v_numcte,v_cuenta, v_numtarjeta char(20);
   define v_producto char(4);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cuenta      = " ";
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_producto = " ";
   let vRegistros = 0;

--set debug file to "cons_chq_bpi.out";
--trace on;

LET v_numcte = pnum_cte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_cuenta, v_numtarjeta;
      end if
   end exception;

        IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmpTarjeta_bpi') THEN
               DROP TABLE bdicheq:tmpTarjeta_bpi;
        END IF;

   select numcte into v_numcte from bdinteg:si_cliente
      where numcte = pnum_cte;
   if v_numcte is null then
      let cod_ret = "104";
      return cod_ret,v_numcte, v_cuenta, v_numtarjeta;
   end if

        select num_cte, cuenta, producto
        from bdicheq:sc_maechq
        where empresa = pempresa and num_cte = pnum_cte and status_cta = 1
        order by cuenta  INTO TEMP tmpTarjeta_bpi WITH NO LOG;

         Select Count(num_cte) into vRegistros From tmpTarjeta_bpi;      

         IF vRegistros > 0 THEN

            Foreach
                Select num_cte, cuenta
                into v_numcte , v_cuenta
                From tmpTarjeta_bpi

                select num_tarjeta                    
                into v_numtarjeta
                from sc_tarjeta
                where empresa = '001' and cuenta = v_cuenta and secuencia <> 0 and status_tar = 'A' and tipo_tarjeta = 'T';

                IF v_numtarjeta is null THEN
                    LET v_numtarjeta = '0000000000000000';
                END IF

                return cod_ret,v_numcte, v_cuenta, v_numtarjeta  WITH RESUME;

           end foreach;

           ELSE
                     let cod_ret = 101; --Cliente No es Titular
                     return cod_ret,v_numcte, v_cuenta, v_numtarjeta WITH RESUME;
           END IF;

         drop table bdicheq:tmpTarjeta_bpi;

      --return cod_ret,v_numcte, v_cuenta, v_numtarjeta, v_status_tar  WITH RESUME;

end
end procedure;