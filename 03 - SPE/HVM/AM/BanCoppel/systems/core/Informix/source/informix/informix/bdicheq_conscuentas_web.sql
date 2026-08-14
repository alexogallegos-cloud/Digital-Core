create procedure "informix".conscuentas_web(pempresa char(3), pNumCte char(20))

        returning char(5), char(20);

        DEFINE v_cod_ret char(5);
        DEFINE v_ciclo smallint;
        DEFINE v_cuenta char (20);
        DEFINE v_fcuenta char (20);


        LET v_cod_ret  = "00000";
        LET v_ciclo    = 0;
        LET v_cuenta   = "";
        LET v_fcuenta  = "";


                foreach

                select
                                cuenta
                into
                                v_cuenta
                from

                                bdicheq:sc_firmantes
                where
                                empresa = pempresa and
                                numcte = pNumCte

                                if not v_cuenta is null then
                                        LET v_ciclo = v_ciclo + 1;

                                        return v_cod_ret, v_cuenta with resume;
                                end if

                end foreach;


        if  v_ciclo = 0 then
                return "00101", "";
        end if

end procedure
;