create procedure "informix".trans(ptipo_mov char(4),
                           psucursal char(3),
                           ptipo_docto char(2),
                           pno_docto char(10),
			   pfecha date,
                           pmoneda char(2),
                           pmonto money(14,2),
                           pcomision money(10,2),
                           piva money(10,2),
                           pcomprador char(40),
                           ptel_comp char(10),
                           pdom_comp char(70),
                           pbenef char(40),
                           ptel_benef char(10),
                           pdom_benef char(70),
                           pbco_dest char(3),
                           ppais_dest char(3),
                           pedo_dest char(2),
			   pciudad_dest char(2)) returning char(5);

define v_codret char(5);
define v_hora datetime hour to second;
define v_fechahora datetime year to fraction;
let v_codret="000";
let v_fechahora = current year to second;

if  ptipo_mov="ALTA" then
	insert into st_maetrans values(ptipo_docto, 
					pno_docto, 
					psucursal,
					pmoneda, 
					pmonto, 
					"informix", 
					v_fechahora, 
					pbco_dest,
                           		ppais_dest, 
					pedo_dest, 
					pciudad_dest,
					"",
					"",
					0,
					0,
					0,
					0,
					"",
					0,
					0,
					pbenef,
					"",
					"",
					"",
					"",
					pcomprador,
		                        ptel_comp, 
					pdom_comp, 
					0,
					0,
					0,
					"",
					0,
					"1",
		                        pcomision, 
					100,
					0,
					pcomision,
					"1",
					v_fechahora);

	return v_codret;
end if;
return v_codret;
	
end procedure;