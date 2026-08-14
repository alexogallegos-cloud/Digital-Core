create procedure "informix".consnombcta(pempresa char(3),
        ppaterno char(26),
        pmaterno char(26),
        pnombre1 char(26),
        pnombre2 char(26),
        prfc     char(13))

        returning char(5), char(20), char(20);

        DEFINE v_cod_ret char(5);
        DEFINE v_ciclo smallint;
        DEFINE v_numcte char(20);
        DEFINE v_cuenta char (20);


        LET v_cod_ret  = "000";
        LET v_ciclo    = 0;
        LET v_numcte   = "";
        LET v_cuenta   = "";


                foreach
                select
                                a.numcte, b.cuenta
                into
                                v_numcte, v_cuenta
                from
                                bdinteg:si_cliente a,
                                bdicheq:sc_maechq b
                where
                                a.empresa = pempresa and
                                a.apell_paterno matches ppaterno and
                                a.apell_materno matches pmaterno and
                                a.nombre1 matches pnombre1 and
                                a.nombre2 matches pnombre2 and
                                a.rfc = prfc and
                                a.numcte = b.num_cte and
                                b.status_cta = '1'
                order by
                                b.cuenta

                                if not v_cuenta is null then
                                        LET v_ciclo = v_ciclo + 1;

                                        return v_cod_ret, v_cuenta, v_numcte with resume;
                                end if

                end foreach;


        if  v_ciclo = 0 then
                return "141", "", "";
        end if

end procedure
;