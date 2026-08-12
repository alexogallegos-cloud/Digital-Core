create procedure "informix".arr_pagaint()
returning char(5), integer, integer;

   DEFINE vhoraw           CHAR(15);
   DEFINE vhora            DATETIME HOUR TO FRACTION;
   DEFINE vfolio_suc       CHAR(16);
   DEFINE vgtrans_pag_int  CHAR(4);
   DEFINE vgtranprov       CHAR(4);
   DEFINE vfecha_hoy       DATE;
   define vcta char(20);
   define vint decimal(14,2);
   define vintfalta decimal(14,2);
   define vsdo decimal(14,2);
   define vsuc char(4);
   define vprod char(4);
   define vstatus char(1);
   define vsqlerr integer;
   define isam_err integer;
   define error_info char(50);
   define contdia1, contdia2 integer;  
   define vcodret char(5);
 

   ON EXCEPTION SET vsqlerr, isam_err, error_info
      IF vsqlerr <> 0 THEN
	 let vcodret = vsqlerr;
         RETURN vcodret, contdia1, contdia2;
      END IF;
   END EXCEPTION;

let vcodret ="000";
let contdia1 = 0;
let contdia2 = 0;

--set debug file to "arrint.out";
--trace on;


   SELECT valor INTO vgtranprov
     FROM sc_param
    WHERE empresa = "001"
      AND codparam = "tranprov";

   SELECT valor INTO vgtrans_pag_int
     FROM sc_param
    WHERE empresa = "001"
      AND codparam = "tranpagint";

   SELECT fecha_hoy INTO vfecha_hoy
     FROM sc_fechas;

   LET vhora = current hour to fraction;
   LET vhoraw = vhora;
   LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
   LET vfolio_suc = "informix" ||vhoraw[1,8];



foreach select a.cuenta, int_acum, (sdo_actual - (sdo_retenido + sdo_cong)),
	       sucursal, producto, status_cta
	  into vcta, vint, vsdo, vsuc, vprod, vstatus
	  from sc_maechq a, sc_maenoc b
	 where a.empresa ="001"
	   and a.producto IN ("2000", "1400")
	   and b.empresa = a.empresa
	   and b.cuenta = a.cuenta
	   and day(b.fecha_alta) = 1
	   and a.ultpagoint <> vfecha_hoy

	if vsdo > 0 then
	   let vintfalta = (vsdo * .04) /360;
	else
	   let vintfalta = 0;
	end if

	if vintfalta > 0 THEN -- Movto de Provision
         INSERT INTO sc_movdia
          VALUES (0,vfolio_suc,vsuc,"informix",vfecha_hoy,
                  vfecha_hoy,vhora,vgtranprov,vsuc,vprod,"001",
                  vcta, "",0,vintfalta,vintfalta,0,0,0,"",vstatus,
                  vsdo,"0000"," ",0,"","");
	end if

	if (vintfalta + vint) > 0 THEN -- Movto de Pago de Int
         INSERT INTO sc_movdia
          VALUES (0,vfolio_suc,vsuc,"informix",vfecha_hoy,
                  vfecha_hoy,vhora,vgtrans_pag_int,vsuc,vprod,"001",
                  vcta, "",0,(vintfalta + vint),(vintfalta + vint),0,0,0,"",
		  vstatus, vsdo,"0000"," ",0,"","");

            UPDATE sc_maechq
               SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                    ultpagoint) =
                   (vfecha_hoy,num_abonos_mes + 1,
                    imp_abonos_mes + (vintfalta + vint),
                    sdo_actual + (vintfalta + vint),
                    vfecha_hoy)
               WHERE empresa = "001" AND cuenta = vcta;
	else
	  let contdia1 = contdia1 + 1;	
	  continue foreach;
	end if

	UPDATE sc_maenoc 
	   SET int_acum = 0,
	       acum_sdo_int = (vintfalta * 2),
	       dias_acum_int = 2
	 where empresa = "001"
	   and cuenta = vcta;
		

	let contdia1 = contdia1 + 1;	
end foreach 

-- Los del dia 2

foreach select a.cuenta, monto_tot, sdo_cuenta,
               sucursal, producto, edo_cta
          into vcta, vint, vsdo, vsuc, vprod, vstatus
          from pagaint a, sc_maenoc b
         where a.empresa ="001"
           and a.cuenta = a.cuenta
           and a.fech_alt = "12/31/2007"
           and transacc = "3381"
           and b.empresa = a.empresa
           and b.cuenta = a.cuenta
           and day(fecha_alta) = 2
           and b.fecha_alta <> "01/02/2008"


        if vsdo > 0 then
           let vintfalta = (vsdo * .04) /360;
        else
           let vintfalta = 0;
        end if

        if (vintfalta * 2) > 0 THEN -- Movto de Provision
         INSERT INTO sc_movdia
          VALUES (0,vfolio_suc,vsuc,"informix",vfecha_hoy,
                  vfecha_hoy,vhora,vgtranprov,vsuc,vprod,"001",
                  vcta, "",0,vintfalta,vintfalta,0,0,0,"",vstatus,
                  vsdo,"0000"," ",0,"","");
        end if

        if ((vintfalta * 2) + vint) > 0 THEN -- Movto de Pago de Int
         INSERT INTO sc_movdia
          VALUES (0,vfolio_suc,vsuc,"informix",vfecha_hoy,
                  vfecha_hoy,vhora,vgtrans_pag_int,vsuc,vprod,"001",
                  vcta, "",0,((vintfalta * 2) + vint),
		  ((vintfalta * 2) + vint),0,0,0,"",
                  vstatus, vsdo,"0000"," ",0,"","");

            UPDATE sc_maechq
               SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                    ultpagoint) =
                   (vfecha_hoy,num_abonos_mes + 1,
                    imp_abonos_mes + ((vintfalta * 2) + vint),
                    sdo_actual + ((vintfalta * 2) + vint),
                    vfecha_hoy)
               WHERE empresa = "001" AND cuenta = vcta;
        else
          let contdia2 = contdia2 + 1;
          continue foreach;
        end if

        UPDATE sc_maenoc
           SET int_acum = 0,
               acum_sdo_int = vintfalta ,
               dias_acum_int = 1
         where empresa = "001"
           and cuenta = vcta;


        let contdia2 = contdia2 + 1;
end foreach






return vcodret, contdia1, contdia2;
end procedure
;