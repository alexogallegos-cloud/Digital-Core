CREATE PROCEDURE "informix".consctapornomcte(pEmpresa CHAR(3),
							 pPatTit CHAR(26), pMatTit CHAR(26), pNom1Tit CHAR(26), pNom2Tit CHAR(26),
							 pPatFir CHAR(26), pMatFir CHAR(26), pNom1Fir CHAR(26), pNom2Fir CHAR(26))

	RETURNING
	CHAR(5),  -- Codigo de retorno
	CHAR(20), -- Numero de cuenta
	CHAR(20); -- Numero de cliene

	DEFINE v_cod_ret char(5);
	DEFINE v_ciclo  smallint;
	DEFINE v_numcte char(20);
	DEFINE v_cuenta char (20);
	DEFINE v_fcuenta char (20);

	LET v_cod_ret  = "000";
	LET v_ciclo    = 0;
	LET v_numcte   = "";
	LET v_cuenta   = "";
	LET v_fcuenta  = "";


	IF pPatFir = "" AND  pNom1Fir = "" THEN
		FOREACH
			SELECT
				 a.numcte, b.num_credito
			INTO
				v_numcte, v_cuenta
			FROM
				bdinteg:si_cliente a,
				bdicred:sd_maecred b
			WHERE
				a.empresa = pEmpresa AND
				a.apell_paterno = pPatTit AND
				a.apell_materno = pMatTit AND
				a.nombre1 = pNom1Tit AND
				a.nombre2 = pNom2Tit AND
				a.numcte = b.numcte
			ORDER BY
				b.num_credito

			IF NOT v_cuenta IS NULL THEN
				LET v_ciclo = v_ciclo + 1;

				RETURN v_cod_ret, v_cuenta, v_numcte WITH RESUME;
			END IF
		END FOREACH;
	ELSE
		FOREACH
			SELECT
				b.num_credito
			INTO
				v_cuenta
			FROM
				bdinteg:si_cliente a,
				bdicred:sd_maecred b
			WHERE
				a.empresa = pEmpresa AND
				a.apell_paterno = pPatTit AND
				a.apell_materno = pMatTit AND
				a.nombre1 = pNom1Tit AND
				a.nombre2 = pNom2Tit AND
				a.numcte = b.numcte
			ORDER BY
				b.num_credito
      			

			SELECT
				s.numcte, f.num_credito
			INTO
				v_numcte, v_fcuenta
			FROM
				bdinteg:si_cliente s,
				bdicred:sd_tarjeta f
			WHERE
				s.apell_paterno = pPatFir AND
				s.apell_materno = pMatFir AND
				s.nombre1 = pNom1Fir AND
				s.nombre2 = pNom2Fir AND
				s.numcte = f.numcte AND
				f.secuencia in (select max(secuencia) from bdicred:sd_tarjeta  where num_credito = v_cuenta) and
				f.num_credito = v_cuenta;
				

			IF v_fcuenta <> "" THEN
				LET v_ciclo = v_ciclo + 1;

				RETURN v_cod_ret, v_fcuenta, v_numcte WITH RESUME;
			END IF
		END FOREACH;
	END IF

	IF  v_ciclo = 0 THEN
		RETURN "101", "", "";
	END IF

end procedure
                                                                                                                                                                                                                ;