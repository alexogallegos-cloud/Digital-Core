create procedure "informix".califica_buro(pempresa char(03), psucursal char(03), pusuario char(03),pnum_solicitud char(20) )
returning char(05),money(14,2);

define sql_err int;
define cod_postal_cliente char(05);
define rfc_cliente  char(10);
define mop9 int;
define calificacion char(2);
--define calificacion lvarchar;
define cod_ret char(05);
define monto_aut money(9,2);
define monto_pagosf money(9,2);
define media_pf int;
define bandera_pf int;



define revolvente char(04);
define pago_fijo char(04);
define empresarial char(4);
define monto_saldo int;
define num_ctas_mayor int;
define num_ctas_min int;
define cred_no_conc lvarchar;
define cred1 char(1);
define cred_cadena varchar(20);
define clave_producto char(04);
define vfecha_hoy date;
define pnumcte char(20);
define monto_default money (9,2);
define cuentas int;
define cal_bueno_pf int;



define valor_mop_no_con char(1);
define mop_malo int;
define num_meses_max_eva int;
define rango_pago2 lvarchar;
define num_meses_min int;
define cali_buena int;
define cali_reg int;
define cali_mala int;
define valor_ini_buena int;
define valor_fin_buena int;
define valor_ini_rega int;
define valor_fin_rega int;
define valor_ini_regm int;
define valor_fin_regm int;
define valor_ini_mal int;
define valor_fin_mal int;

define valor_ini_buena_pf int;
define valor_fin_buena_pf int;
define valor_ini_mal_pf int;
define valor_fin_mal_pf int;

define val_bueno char(2);
define val_regulara char(2);
define val_regularm char(2);
define val_malo char(2);
define cal_bueno int;
define cal_regulara int;
define cal_regularm int;
define cal_malo int;

define rango_factor1 varchar(7);
define rango_factor2 varchar(7);
define rango_factor3 varchar(7);
define rango_factor4 varchar(7);
define factor1 decimal(9,2);
define factor2 decimal(9,2);
define factor3 decimal(9,2);
define factor4 decimal(9,2);

define longitud int;
define historial_pagos varchar(24);
define historial char(12);
define resta  int;
define valor_hist_pagos char(1);
define caracter_hist char(1);
define i int;
define mop int;
define mop1 int;
define mop2 int;
define mop3 int;
define continua int;
define valor_cuenta  int;
define calificacion_global int;
define cuentas_calificadas int;
define calificacion_cliente int;
define maxima_calificacion int;
define factor_adicional decimal(9,2);
define vcalburo int;
define nrows int;
define existe int;
define ultimo_caracter char(1);


let mop1 = 0;
let mop2 = 0;
let mop3 = 0;
let continua = 0;
let monto_aut = 0;
let calificacion_cliente = 0;

--BEGIN WORK;

BEGIN

ON EXCEPTION SET sql_err
   if sql_err <> 0 then
          --ROLLBACK WORK;
          RETURN sql_err,monto_aut;
   end if
END EXCEPTION;



--- Obtencion de valores de productos ---

let pnumcte = "";
let clave_producto = "";


select numcte, num_producto, monto_linea
into  pnumcte,clave_producto, monto_pagosf from bdisolicitud:ss_captrescom
where num_solicitud = pnum_solicitud;

select valor into revolvente from bdicred:sd_param where cod_param = 95;

select valor into pago_fijo from bdicred:sd_param where cod_param = 94;

select valor into empresarial from bdicred:sd_param where cod_param = 93;

select fecha_hoy   into vfecha_hoy  from bdicred:sd_fechas;

select valor into  monto_saldo           from br_param where cod_param = 10 ;

select valor into  num_ctas_mayor        from br_param where cod_param = 20 ;

select valor into  num_ctas_min          from br_param where cod_param = 21 ;

select valor into  cred_no_conc          from br_param where cod_param = 30 ;

let longitud = length(cred_no_conc);

for i = 1 to longitud step 1
    if (substr(cred_no_conc,i,1) = ",")
       then
           let cred1 = substr(cred_no_conc,i -1,1);
           EXIT FOR;
    end if;
end for;




select valor into  valor_mop_no_con      from br_param where cod_param = 40 ;

select valor into  mop_malo     from br_param where cod_param = 41 ;

select valor into  num_meses_max_eva     from br_param where cod_param = 50 ;

select valor into  rango_pago2           from br_param where cod_param = 51 ;

select valor into  num_meses_min         from br_param where cod_param = 52 ;

select valor into  cali_buena            from br_param where cod_param = 60 ;

select valor into  cali_reg              from br_param where cod_param = 61 ;

select valor into  cali_mala             from br_param where cod_param = 62 ;

select valor into  valor_ini_buena    from br_param where cod_param = 70 ;

select valor into  valor_fin_buena    from br_param where cod_param = 71 ;

select valor into  valor_ini_rega    from br_param where cod_param = 72 ;

select valor into  valor_fin_rega    from br_param where cod_param = 73 ;

select valor into  valor_ini_regm   from br_param where cod_param = 74 ;

select valor into  valor_fin_regm   from br_param where cod_param = 75 ;

select valor into  valor_ini_mal      from br_param where cod_param = 76 ;

select valor into  valor_fin_mal      from br_param where cod_param = 77 ;

select valor into  valor_ini_buena_pf    from br_param where cod_param = 120 ;

select valor into  valor_fin_buena_pf   from br_param where cod_param = 121 ;

select valor into  valor_ini_mal_pf      from br_param where cod_param = 122;

select valor into  valor_fin_mal_pf      from br_param where cod_param = 123 ;


select valor into  val_bueno             from br_param where cod_param = 80 ;

select valor into  val_regulara          from br_param where cod_param = 81 ;

select valor into  val_regularm          from br_param where cod_param = 82 ;

select valor into  val_malo              from br_param where cod_param = 83 ;


select valor into  cal_bueno             from br_param where cod_param = 84 ;

select valor into  cal_regulara          from br_param where cod_param = 85 ;

select valor into  cal_regularm          from br_param where cod_param = 86 ;

select valor into  cal_malo              from br_param where cod_param = 87;

select valor into  cal_bueno_pf             from br_param where cod_param = 88;

select valor into  rango_factor1         from br_param where cod_param = 90 ;

select valor into  rango_factor2         from br_param where cod_param = 91 ;

select valor into  rango_factor3         from br_param where cod_param = 92 ;

select valor into  rango_factor4         from br_param where cod_param = 93 ;

select valor into  factor1               from br_param where cod_param = 100 ;

select valor into  factor2               from br_param where cod_param = 101 ;

select valor into  factor3               from br_param where cod_param = 102 ;

select valor into  factor4               from br_param where cod_param = 103 ;




---- Validacion Inicial

select  cod_postal into cod_postal_cliente from bdinteg:si_direcciones
   where numcte = pnumcte;

select count(*) into existe from br_pa
   where trim(num_cliente) = trim(pnumcte)
   and pa05 =  cod_postal_cliente;

if (existe = 0)
   then
        update bdisolicitud:ss_captrescom
             set status_solicitud = "AB",
                   comentario = "DIRECCION NO CORRESPONDE A BURO"
        where num_solicitud = pnum_solicitud;

        INSERT INTO bdisolicitud:ss_bitacora
        VALUES(pnum_solicitud,vfecha_hoy,pusuario,val_malo,"DIRECCION NO CORRESPONDE A BURO");

       INSERT INTO bdisolicitud:ss_califica
	          (num_solicitud,status_solicitud,
	          calificacion) values(pnum_solicitud,val_malo,cal_malo);

        let cod_ret = "265";
    else
       let continua = continua + 1;
end if;

if (continua = 1)
   then
      select  substr(rfc,1,10)   into rfc_cliente from bdinteg:si_cliente
          where trim(numcte) = trim(pnumcte);

      select count(*) into existe from br_pn
          where trim(num_cliente) = trim(pnumcte)
               and substr(pn05,1,10)  =  rfc_cliente;

       if (existe = 0)
          then
              update bdisolicitud:ss_captrescom
                  -- set status_solicitud = val_malo,
                     set status_solicitud = "AB",
                          comentario = "RFC NO CORRESPONDE A BURO"
              where num_solicitud = pnum_solicitud;

              INSERT INTO bdisolicitud:ss_bitacora
              VALUES(pnum_solicitud,vfecha_hoy,pusuario,val_malo,"RFC NO CORRESPONDE A BURO");

              INSERT INTO bdisolicitud:ss_califica
	          (num_solicitud,status_solicitud,
	          calificacion) values(pnum_solicitud,val_malo,cal_malo);

              let cod_ret = "265";

           else
              let continua =  continua + 2;
         end if;
end if;

if (continua = 3)
   then
      select count(*)  into existe from br_tl a, br_pn b
          where trim(a.num_cliente) = trim(pnumcte)
          and a.num_cliente = b.num_cliente
         -- and substr(a.tl27,length(a.tl27),1) not in ("D", "U","-","X","0");
          and substr(a.tl27,1,1) not in ("D", "U","-","X","0");
      let cod_ret = "000";

      if (existe > 0)
         then
             let continua =  continua + 4;
          else
             	let nrows = 0;
                let calificacion = val_regulara;
                let vcalburo = cal_regulara;

               if (clave_producto = revolvente) then  select valor into  monto_default      from br_param where cod_param = 111 ;
                  elif (clave_producto = pago_fijo) then let monto_default = monto_pagosf;
               end if;

	   INSERT INTO bdisolicitud:ss_califica
	          (num_solicitud,status_solicitud,
	          calificacion) values(pnum_solicitud,calificacion,vcalburo);
	let  nrows = dbinfo("sqlca.sqlerrd2");

	if (nrows = 1)
	   then

                        update bdisolicitud:ss_captrescom
                            --set status_solicitud = val_regulara,
                            set status_solicitud = "AT",
                                  puntaje = puntaje + cal_regulara,
                                  comentario = "NO HAY INFORMACION BURO, MONTO DEFAULT",
                                  monto_linea = monto_default
                        where num_solicitud = pnum_solicitud;
			let monto_aut = monto_default;
	        INSERT INTO bdisolicitud:ss_bitacora
	        VALUES(pnum_solicitud,vfecha_hoy,pusuario,calificacion,"NO HAY INFORMACION BURO");
                        let cod_ret = "000";
	   else
	     let cod_ret = "111";
	end if ;

      end if;
end if;



if(continua = 7)
  then
		if (clave_producto = revolvente)
		then
		        let mop9 = 0;
		        select count(*)  into mop9 from br_tl
		        where trim(num_cliente) = trim(pnumcte)
		        and  tl38 in ("96","97","99") --> 0  antes tl35
		        and tl22 > monto_saldo ;
		        

		        if (mop9 = num_ctas_mayor ) then
		          select count(*)  into mop9 from br_tl
		          where trim(num_cliente) = trim(pnumcte)
		          and  tl38 in ("96","97","99")
		          and tl22 < monto_saldo ;

		             if (mop9  >  num_ctas_min)  then
		                  let calificacion = val_malo;
                                  let vcalburo = cal_malo;
		              else
		                   let valor_cuenta = 0;
		                   let calificacion_global = 0;
		                   let cuentas_calificadas = 0;
		                   let calificacion_cliente = 0;
		                   FOREACH WITH HOLD
		                   select trim(tl27) into  historial_pagos from  br_tl
		                   where trim(num_cliente) = trim(pnumcte)
		                   and tl16 is null
		                   and tl22 > monto_saldo  and tl06 != cred1  and trim(tl02)  not like "%COMUNICACION%"

		                   let longitud = length(historial_pagos);


		                  if (longitud >= num_meses_max_eva ) then
		                 --   let calificacion = num_meses_max_eva;
		                     let continua = 0;
		                     let resta = 1;
--		                     if  (longitud = num_meses_max_eva ) then let resta = 1;end if;
		                     let historial = substr(historial_pagos, resta,num_meses_max_eva);
                                     let ultimo_caracter = substr(historial,1,1) ;


		                     for valor_hist_pagos in ("D", "U","-","X","0")
		                     if (  ultimo_caracter = valor_hist_pagos) then  let continua = 0; EXIT FOR;
		                     else
		                       let continua = 1;
		                     end if;
		                     end for;
			             
			             if (continua = 1)
		                      then
  			                     if ( ultimo_caracter >= mop_malo)
			                     then
			                           let valor_cuenta = cali_mala;
		        	                   let calificacion_global = calificacion_global + valor_cuenta;
		                	           let cuentas_calificadas = cuentas_calificadas + 1;
		                        	   let continua = 0;
			                     end if;
			              end if;

		                      if (continua = 1)
		                      then
		                           let mop1 = 0;
		                           let mop2 = 0;
		                           let mop3 = 0;
		                            for i = 1  to num_meses_max_eva  step 1 -- -1
		                                if substr(historial,i,1) not in ("D", "U","-","X","0") then
		                                 let valor_hist_pagos = substr(historial,i,1);
		                                 if (valor_hist_pagos = 1) then let mop1 = mop1 + 1; end if;
		                                 if (valor_hist_pagos = 2) then let mop2 = mop2 + 1; end if;
		                                 if (valor_hist_pagos = 3) then let mop3 = mop3 + 1; end if;
		                                end if;
		                             end for;


		                            if (mop1 >= 7 and ultimo_caracter <= 2 )
		                            then
		                                  let valor_cuenta = cali_buena;
		                                  let calificacion_global = calificacion_global + valor_cuenta;
		                                  let cuentas_calificadas = cuentas_calificadas + 1;
		                            elif (mop1 <= 6 and ultimo_caracter  <= 2)
		                               then
		                                      let valor_cuenta = cali_reg;
		                                      let calificacion_global = calificacion_global + valor_cuenta;
		                                      let cuentas_calificadas = cuentas_calificadas + 1;
		                            end if;

		                       end if;

		                   elif (longitud between 6 and 11 ) then
		                    --      let calificacion = longitud;
		                         let historial = historial_pagos;
		                         let continua = 0;
		                     for valor_hist_pagos in ("D", "U","-","X","0")
		                           let caracter_hist = substr(historial,1,1);
		                           if ( caracter_hist = valor_hist_pagos) then  let continua = 0; EXIT FOR;
		                           else
		                                 let continua = 1;
		                            end if;
		                     end for;

		                      let caracter_hist = substr(historial,longitud,1);

		                      if ( caracter_hist >= mop_malo)
		                      then
		                             let valor_cuenta = cali_mala;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                             let continua = 0;
		                      end if;

		                      if (continua = 1)
		                      then
		                           let mop1 = 0;
		                           let mop2 = 0;
		                           let mop3 = 0;
		                            for i = 1  to longitud  step 1 -- -1
		                                if substr(historial,i,1) not in ("D", "U","-","X","0") then
		                                 let valor_hist_pagos = substr(historial,i,1);
		                                 if (valor_hist_pagos = 1) then let mop1 = mop1 + 1; end if;
		                                 if (valor_hist_pagos = 2) then let mop2 = mop2 + 1; end if;
		                                 if (valor_hist_pagos = 3) then let mop3= mop3 + 1; end if;
		                                end if;
		                             end for;

 		                            let caracter_hist = substr(historial,longitud,1);
		                             if (mop1 >= 4 and caracter_hist <= 2 )
		                             then
		                                   let valor_cuenta = cali_buena;
		                                   let calificacion_global = calificacion_global + valor_cuenta;
		                                   let cuentas_calificadas = cuentas_calificadas + 1;
		                             elif (mop1 <= 3 and caracter_hist <= 2)
		                                then
		                                       let valor_cuenta = cali_reg;
		                                       let calificacion_global = calificacion_global + valor_cuenta;
		                                       let cuentas_calificadas = cuentas_calificadas + 1;
		                             end if;
		                         end if;

		                       elif (longitud <=  num_meses_min) then
		                         let historial = historial_pagos;
		                         let caracter_hist = substr(historial,1,1);
		                         if (caracter_hist = 1)
		                         then
		                             let valor_cuenta = cali_reg;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                         end if;

		                         if (caracter_hist >= 2 )
		                         then
		                             let valor_cuenta = cali_mala;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                         end if;

		                       end if;
		                   END  FOREACH;
		                 if cuentas_calificadas = 0 or cuentas_calificadas is null then -- MEL
				    let nrows = 0;
		                    let calificacion = val_regulara;
		                    let vcalburo = cal_regulara;
 			            if (clave_producto = revolvente) then
 			               select valor into  monto_default from br_param where cod_param = 111 ;
		                    elif (clave_producto = pago_fijo) then
		                         let monto_default = monto_pagosf;
		                    end if

			  	    INSERT INTO bdisolicitud:ss_califica
				          (num_solicitud,status_solicitud,
				          calificacion) values(pnum_solicitud,calificacion,vcalburo);

				    let  nrows = dbinfo("sqlca.sqlerrd2");
                	                --set status_solicitud = val_regulara
			   	    if (nrows = 1) then
		                        update bdisolicitud:ss_captrescom
                             		set status_solicitud = "AT",
	                                puntaje = puntaje + cal_regulara,
	                                comentario = "NO HAY INFORMACION BURO, MONTO DEFAULT",
	                                monto_linea = monto_default
		                        where num_solicitud = pnum_solicitud;
					let monto_aut = monto_default;
				        INSERT INTO bdisolicitud:ss_bitacora
				        VALUES(pnum_solicitud,vfecha_hoy,pusuario,calificacion,"NO HAY INFORMACION BURO");
		                        let cod_ret = "000";
			  	     else
				        let cod_ret = "111";
				     end if ;
				     return cod_ret,monto_aut;
				 else
		                    let  maxima_calificacion = cuentas_calificadas * 10;
		                    let  calificacion_cliente = (calificacion_global * 100) / maxima_calificacion;

		                    if (calificacion_cliente between valor_ini_buena and valor_fin_buena)
                                                     then  let calificacion = val_bueno;
                                                              let vcalburo = cal_bueno;
		                      elif (calificacion_cliente between valor_ini_rega and valor_fin_rega)
                                                         then  let calificacion = val_regulara;
                                                                let vcalburo = cal_regulara;
		                       elif (calificacion_cliente between valor_ini_regm and valor_fin_regm )
                                                          then  let calificacion = val_regularm;
                                                                   let vcalburo = cal_regularm;
                                                                   let monto_aut = 0;
		                       elif (calificacion_cliente between valor_ini_mal and valor_fin_mal)
                                                          then  let calificacion = val_malo;
                                                                   let vcalburo = cal_malo;
                                                                   let monto_aut = 0;
		                    end if;
		                 end if

		             end if;
		         else
		            let calificacion = val_malo;
		            let vcalburo =cal_malo;
		         end if;

		elif (clave_producto = pago_fijo)
		   then

                                        let mop9 = 0;
                                        let cuentas = 0;
                                        let media_pf = 0;
                                        let bandera_pf = 0;
                                        let longitud = 0;

                                        select count(*) into cuentas from br_tl
                                        where trim(num_cliente) = trim(pnumcte);

		        select count(*)  into mop9 from br_tl
		        where trim(num_cliente) = trim(pnumcte)
		        and  tl38 in ("96","97","99");


                                        let media_pf = round(cuentas  / 2);

                                        if (media_pf >= cuentas)
                                           then
                                               let bandera_pf = 1;
                                               let cuentas_calificadas = 0;
                                               let calificacion_global = 0;
                                       end if;

                                       if (bandera_pf = 0)
                                          then
                                             FOREACH WITH HOLD
		             select trim(tl27) into  historial_pagos from  br_tl
		                where trim(num_cliente) = trim(pnumcte)
		                 and tl16 is null  and tl06 != cred1

                                             let longitud = length(historial_pagos);

		                  if (longitud >= num_meses_max_eva ) then
		                     let continua = 0;
		                     if  (longitud = num_meses_max_eva ) then let resta = 1;end if;
		                     let historial = substr(historial_pagos, resta,num_meses_max_eva);
                                                     let ultimo_caracter = substr(historial,1,1) ;


		                     for valor_hist_pagos in ("D", "U","-","X","0")
		                     if ( ultimo_caracter = valor_hist_pagos)
		                     then  let continua = 0; EXIT FOR;
		                     else
		                       let continua = 1;
		                     end if;
		                     end for;

		                     if ( ultimo_caracter  >= mop_malo)
		                     then
		                           let valor_cuenta = cali_mala;
		                           let calificacion_global = calificacion_global + valor_cuenta;
		                           let cuentas_calificadas = cuentas_calificadas + 1;
		                           let continua = 0;
		                     end if;

		                      if (continua = 1)
		                      then
                                                           let mop = 0;
		                           for i = 1  to num_meses_max_eva step 1 -- -1
		                               if substr(historial,i,1) not in ("D", "U","-","X","0") then
		                                 let valor_hist_pagos = substr(historial,i,1);
		                                 if (valor_hist_pagos = 1) then let mop = mop + 1; end if;
		                                 if (valor_hist_pagos = 2) then let mop = mop + 1; end if;
		                                 if (valor_hist_pagos = 3) then let mop = mop + 1; end if;
		                               end if;
		                             end for;


		                            if (mop >= 7 and ultimo_caracter <= 2 )
		                            then
		                                  let valor_cuenta = cali_buena;
		                                  let calificacion_global = calificacion_global + valor_cuenta;
		                                  let cuentas_calificadas = cuentas_calificadas + 1;
		                            elif (mop <= 6 and ultimo_caracter  <= 2)
		                               then
		                                      let valor_cuenta = cali_reg;
		                                      let calificacion_global = calificacion_global + valor_cuenta;
		                                      let cuentas_calificadas = cuentas_calificadas + 1;
		                            end if;

		                       end if;

		                   elif (longitud between 6 and 11 ) then
		                         let historial = historial_pagos;
		                         let continua = 0;
		                     for valor_hist_pagos in ("D", "U","-","X","0")
		                           let caracter_hist = substr(historial,1,1);
		                           if ( caracter_hist = valor_hist_pagos) then  let continua = 0; EXIT FOR;
		                           else
		                                 let continua = 1;
		                            end if;
		                     end for;

		                      let caracter_hist = substr(historial,longitud,1);

		                      if ( caracter_hist >= mop_malo)
		                      then
		                             let valor_cuenta = cali_mala;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                             let continua = 0;
		                      end if;

		                      if (continua = 1)
		                      then
		                           let mop = 0;
		                            for i = 1  to longitud  step 1 -- -1
		                                if substr(historial,i,1) not in ("D", "U","-","X","0") then
		                                 let valor_hist_pagos = substr(historial,i,1);
		                                 if (valor_hist_pagos = 1) then let mop = mop + 1; end if;
		                                 if (valor_hist_pagos = 2) then let mop = mop + 1; end if;
		                                 if (valor_hist_pagos = 3) then let mop = mop + 1; end if;
		                                end if;
		                             end for;

		                            let caracter_hist = substr(historial,longitud,1);
		                            if (mop >= 4 and caracter_hist <= 2 )
		                            then
		                                  let valor_cuenta = cali_buena;
		                                  let calificacion_global = calificacion_global + valor_cuenta;
		                                  let cuentas_calificadas = cuentas_calificadas + 1;
		                            elif (mop <= 3 and caracter_hist <= 2)
		                               then
		                                      let valor_cuenta = cali_reg;
		                                      let calificacion_global = calificacion_global + valor_cuenta;
		                                      let cuentas_calificadas = cuentas_calificadas + 1;
		                            end if;
		                         end if;

		                       elif (longitud <= num_meses_min) then
		                         let historial = historial_pagos;
		                         let caracter_hist = substr(historial,1,1);
		                         if (caracter_hist <= 3)
		                         then
		                             let valor_cuenta = cali_reg;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                         end if;

		                         if (caracter_hist >3 )
		                         then
		                             let valor_cuenta = cali_mala;
		                             let calificacion_global = calificacion_global + valor_cuenta;
		                             let cuentas_calificadas = cuentas_calificadas + 1;
		                         end if;

		                       end if;

                                             END  FOREACH;

		             let  maxima_calificacion = cuentas_calificadas * 10;
		             let  calificacion_cliente = (calificacion_global * 100) / maxima_calificacion;


		                  if (calificacion_cliente between valor_ini_buena_pf and valor_fin_buena_pf )
                                                     then  let calificacion = val_bueno;
                                                              let vcalburo = cal_bueno_pf;
		                       elif (calificacion_cliente between valor_ini_mal_pf and valor_fin_mal_pf )
                                                          then  let calificacion = val_malo;
                                                                   let vcalburo = cal_malo;
                                                                   let monto_aut = 0;
		                  end if;

                                          else
                                            let calificacion = val_malo;
                                            let vcalburo = cal_malo;
                                       end if;


		elif (clave_producto = empresarial)
		   then let cod_ret = "04";

	                else let cod_ret = "111";

		end if;

	let nrows = 0;

	   INSERT INTO bdisolicitud:ss_califica
	          (num_solicitud,status_solicitud,
	          calificacion) values(pnum_solicitud,calificacion,vcalburo);
	   let  nrows = dbinfo("sqlca.sqlerrd2");


	if (nrows = 1)
	   then
	            if calificacion = val_malo then
                       update bdisolicitud:ss_captrescom
--                            set status_solicitud = calificacion,
			      set status_solicitud = "RB",
			      puntaje = puntaje + vcalburo,
                                  comentario = "CALIFICACION BURO"
                        where num_solicitud = pnum_solicitud;

	                INSERT INTO bdisolicitud:ss_bitacora
	                VALUES(pnum_solicitud,vfecha_hoy,pusuario,calificacion,"CALIFICACION BURO");
                        let cod_ret = "260";	                
	             else
                       update bdisolicitud:ss_captrescom
--                            set status_solicitud = calificacion,
			      set status_solicitud = "AT",
			      puntaje = puntaje + vcalburo,
                                  comentario = "CALIFICACION BURO"
                        where num_solicitud = pnum_solicitud;

	                INSERT INTO bdisolicitud:ss_bitacora
	                VALUES(pnum_solicitud,vfecha_hoy,pusuario,calificacion,"CALIFICACION BURO");
                        let cod_ret = "000";
	             end if


	   else
	     let cod_ret = "111";
	end if ;


                          if (clave_producto = revolvente)
                             then
		   if (calificacion_cliente between valor_ini_rega and valor_fin_buena )
                                      then call  credito_revolvente ( " "," ", " ", pnumcte, pnum_solicitud ,calificacion_cliente) returning cod_ret, monto_aut;
	                   end if;

                              elif (clave_producto = pago_fijo)
                                      then
		           if (calificacion_cliente between valor_ini_buena_pf and valor_fin_buena_pf)
                                              then
                                                  let  monto_aut = monto_pagosf;
                                                  let cod_ret = "000";
                                              else
                                                  let monto_aut = 0;
                                                  let cod_ret = "000";
                                           end if;

                             end if;

                if (cod_ret = "000")
                     then
                       update bdisolicitud:ss_captrescom
                            set monto_linea  =  monto_aut
                        where num_solicitud = pnum_solicitud;

                        let cod_ret = "000";
                end if;


end if;



END;

--if (cod_ret = "000")
--   then
--       let cod_ret = "000";
--       COMMIT WORK;
--    else
--       ROLLBACK WORK;
--       let cod_ret = "111";
--end if;




return  cod_ret,monto_aut;
end procedure
;