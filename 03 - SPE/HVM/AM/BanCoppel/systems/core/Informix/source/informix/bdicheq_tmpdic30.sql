create procedure "informix".tmpdic30()

returning char(5), char(20), date,decimal(14,2), smallint,date;

--//Definicion de variables

define vcodret		char(5);
define vsqlerr		integer;
define vstatus		integer;

--//Variables para el FOR
DEFINE global vtcuenta  CHAR(20) default '';
DEFINE global cuantos smallint   default 0;
DEFINE vtfecha_alta   DATE;
DEFINE vMtoInt        decimal(14,2);
DEFINE vsdoactual     decimal(14,2);
DEFINE vvaltasa       DECIMAL(9,6);


define vdia  integer;
define vmes  integer;
define vanio integer;
define falta date;
define fhoy  date;
define fpago  date;
define fprox  date;
define fultima date;
define vultima char(10);
define bandera smallint;
DEFINE vgtrans_pag_int  CHAR(4);
DEFINE vgsucursal  CHAR(4);
DEFINE pempresa    CHAR(3);
DEFINE vgusuario   CHAR(8);
DEFINE vhora       DATETIME HOUR TO FRACTION;
DEFINE vhoraw      CHAR(15);
DEFINE vfolio_suc  CHAR(16);
DEFINE vnum_tarjeta CHAR(16);
DEFINE vmaxsec 	   SMALLINT;
DEFINE vgproducto  CHAR(4);
DEFINE importe decimal(14,2);



     on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
              return vcodret,vtcuenta,'',cuantos,0,"";
	end if
     end exception;

     --set debug file to "/tmp/tmpdic30.out";
     --trace on;

     let vcodret = "000";
     let vstatus = 0;
     LET vgtrans_pag_int = "3276";
     LET vgusuario = USER;
     LET pempresa = '001';
     LET importe = 0;
     LET cuantos = 0;
     let vtfecha_alta = null;

     -- Folio Operaciones
     LET vhora = current hour to fraction;
     LET vhoraw = vhora;
     LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
     LET vfolio_suc = vgusuario||vhoraw[1,8];



     FOREACH
        select mc.cuenta, mn.fecha_alta , ts.fin_periodo, mc.sdo_actual, mc.sucursal, mc.producto
          into vtcuenta, vtfecha_alta, fhoy, vsdoactual, vgsucursal, vgproducto
          from sc_maechq mc, sc_maenoc mn, sc_producto pr,
               bdinteg:si_cliente cl,bdinteg:si_tipper tp, sc_tasa_variable ts
         where mc.empresa = pempresa
           and status_cta not in("0","2","8","9")
           and mc.empresa = mn.empresa
           and mc.cuenta = mn.cuenta
           and mc.cuenta = ts.cuenta
           and pr.empresa = mc.empresa
           and pr.producto = mc.producto
           and cl.numcte = mc.num_cte
           and tp.tpo_persona = cl.tpo_persona
           and mc.producto = '1100'
           and mn.fecha_alta = '12/03/2007'
           and ts.fin_periodo < current
         order by mc.cuenta,ts.fin_periodo

         let fhoy = fhoy -1;
         let fprox = fhoy +1;
         let vultima = month(fhoy)||"/01/"||YEAR(fhoy);
         let fultima = vultima::date + 1 units month;
         let fultima = fultima - 1;
         let vMtoInt = 0;
         let vnum_tarjeta = 0;

         LET vdia = DAY(vtfecha_alta);
         LET vmes = MONTH(fhoy);
         LET vanio = year(fhoy);

         IF vtfecha_alta = fhoy THEN 
            LET vdia = 0;
            --continue for;
         END IF;

         IF vdia > DAY(fultima) OR vdia < 1 THEN
            LET fpago = fultima;
         ELSE
            LET fpago = LPAD(vmes,2,"0")||"/"||
                        LPAD(vdia,2,"0")||"/"||vanio;

            If DAY(fpago)= 1  THEN
               let fpago = fpago + 1 units month;
            END IF
            let fpago = fpago -1;
         END IF

         IF fpago >= fhoy AND fpago < fprox THEN
             --//Trae el Interes acumulado a la fecha 
                SELECT int_acum,valor_tasa INTO vMtoInt, vvaltasa
            	  FROM sc_tasa_variable
              	 WHERE empresa = pempresa
              	   AND cuenta = vtcuenta
                  AND fin_periodo=(SELECT MIN(fin_periodo)
                                     FROM sc_tasa_variable
                                    WHERE empresa = pempresa
                                      AND cuenta = vtcuenta
                                      AND fin_periodo >= fhoy);

             --//Verifica si se aplico la capitalizacion
             IF EXISTS(select cuenta 
                         from sc_movhis
                        where transacc = '3276'
                          AND empresa = pempresa
                          AND cancelad <> 'S'
                          AND (year(fech_alt) = year(fpago)
                          AND month(fech_alt)= month(fpago))
                          and cuenta = vtcuenta UNION
                       select cuenta 
                         from sc_movdia
                        where transacc = '3276'
                          AND empresa = pempresa
                          AND cancelad <> 'S'
                          --AND fech_alt = current   
                          AND monto_tot = vMtoInt   
                          and cuenta = vtcuenta) THEN
                CONTINUE FOREACH;
             END IF;
        
             --//Extrae el numero de tarjeta
            SELECT MAX(secuencia) INTO vmaxsec
              FROM sc_tarjeta
             WHERE empresa = pempresa 
               AND cuenta = vtcuenta 
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta INTO vnum_tarjeta
              FROM sc_tarjeta
             WHERE empresa = pempresa 
               AND cuenta = vtcuenta 
               AND secuencia = vmaxsec;

             --//Capitaliza los intereses
            INSERT INTO sc_movdia
               VALUES (0,vfolio_suc,vgsucursal,vgusuario,current,
                       current,vhora,vgtrans_pag_int,vgsucursal,vgproducto,
                       pempresa,vtcuenta, "",0,vMtoInt,vMtoInt,0,0,0,"","1",
                       vsdoactual,"0000"," ",vvaltasa,vnum_tarjeta,"");

            UPDATE sc_maechq
               SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                    ultpagoint) =
                   (current,num_abonos_mes + 1,
		    imp_abonos_mes + vMtoInt,
                    sdo_actual + vMtoInt, current)
               WHERE empresa = pempresa AND cuenta = vtcuenta;

            LET importe = importe + vMtoInt;
            LET cuantos = cuantos + 1;
            --return vcodret,vtcuenta, vtfecha_alta,vsdoactual,vMtoInt,fpago with resume;
         END IF;
     END FOREACH;


return vcodret,'ok',vtfecha_alta,importe,cuantos,current;
end procedure;