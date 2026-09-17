create procedure "informix".reversa_nomina()



	define v_folio char(16);
	define v_cta   char(20);
	define v_codret char(5);

	create temp table regreso (cuenta char(20), retorno char(5));

	foreach select cuenta, folio_suc
	          into v_cta, v_folio from sc_movdia
		where folio_suc like "nomina%"



	execute procedure reversion("001",
                                      "001" ,
                                      "informix",
                                      v_folio ,
                                      "1")
	into v_codret;

	if v_codret <> "000" then
		insert into regreso values(v_cta, v_codret);
	end if

	end foreach






end procedure;