CREATE PROCEDURE "informix".consctapornomcte_web(pempresa char(3),
									    ppaterno char(26),
									    pmaterno char(26),
									    pnombre1 char(26),
									    pnombre2 char(26),
									    fpaterno char(26),
									    fmaterno char(26),
									    fnombre1 char(26),
									    fnombre2 char(26))

	RETURNING char(5), char(20), char(20);

	DEFINE v_cod_ret char(5);
	DEFINE v_ciclo   smallint;
	DEFINE v_numcte  char(20);
	DEFINE v_cuenta  char (20);
	DEFINE v_fcuenta char (20);
	DEFINE v_fnumcte char(20);
	DEFINE v_ordenar char(1);
	
	LET v_cod_ret  = "00000";
	LET v_ciclo    = 0;
	LET v_numcte   = "";
	LET v_cuenta   = "";
	LET v_fnumcte  = "";
	LET v_fcuenta  = "";
	LET v_ordenar = "";

	--SET DEBUG FILE TO '/tmp/consctapornomcte';
	---TRACE ON;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	if fpaterno = "" and  fmaterno = "" and fnombre1 = "" then

		FOREACH
			select
				a.numcte, b.cuenta,
				CASE WHEN b.cuenta[2] = '1' THEN 1 else 0 end
			into
				v_numcte, v_cuenta, v_ordenar
      		from
				bdinteg:si_cliente a,
				bdicheq:sc_maechq b
      		where
				a.empresa = pempresa and
				a.apell_paterno matches ppaterno and
				a.apell_materno matches pmaterno and
				a.nombre1 matches pnombre1 and
				a.nombre2 matches pnombre2 and
				a.numcte = b.num_cte
      		order by
				3,2,1

				if not v_cuenta is null then
					LET v_ciclo = v_ciclo + 1;
					return v_cod_ret, v_cuenta, v_numcte with resume;
				end if

		END FOREACH;
	else
		foreach
			select
				t.cuenta,
				CASE WHEN t.cuenta[2] = '1' THEN 1 else 0 end
			into
				v_cuenta, v_ordenar
      		from
				bdinteg:si_cliente c,
				bdicheq:sc_maechq t
      		where
				c.empresa = pempresa and
				c.apell_paterno matches ppaterno and
				c.apell_materno matches pmaterno and
				c.nombre1 matches pnombre1 and
				c.nombre2 matches pnombre2 and
				c.numcte = t.num_cte
      		order by
				2,1


				select
					s.numcte, f.cuenta
				into
					v_fnumcte, v_fcuenta
      			from
					bdinteg:si_cliente s,
					bdicheq:sc_firmantes f
      			where
					s.apell_paterno matches fpaterno and
					s.apell_materno matches fmaterno and
					s.nombre1 matches fnombre1 and
					s.nombre2 matches fnombre2 and
					s.numcte = f.numcte and
					f.cuenta = v_cuenta;

				if v_fcuenta <> "" then
					LET v_ciclo = v_ciclo + 1;
					return v_cod_ret, v_fcuenta, v_fnumcte with resume;
				end if

		end foreach;
	end if

	if  v_ciclo = 0 then
		return "00101", "", "";
	end if
END PROCEDURE;