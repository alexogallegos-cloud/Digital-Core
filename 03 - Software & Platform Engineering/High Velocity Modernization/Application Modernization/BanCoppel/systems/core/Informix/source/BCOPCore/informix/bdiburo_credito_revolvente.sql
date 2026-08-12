create procedure "informix".credito_revolvente( pempresa char(3),psucursal char(3), pusuario char(8), pnumcte char(20), pnum_solicitud char(20),calificacion_cliente int)
returning char(5), money(9,2);

define numero_cuentas int;
define credito_otorgado money(9,2);
define credito_autorizado money(9,2);
define credito_maximo money(9,2);
define credito_final money(9,2);
define linea_menor money(9,2);
define linea_mayor money(9,2);
define bandera_mayor int;
define bandera_menor int;
define suma_credito_otorgado money(9,2);
define num_credito int;
define continua int;
define existe int;
define comprobante_ingresos char(02);
define credito_solicitado money(9,2);
define egresos money(9,2);
define monto_sugerido money(9,2);
define vpuntos int;
define ingresos money(9,2);

define valor_ini_factor1 int;
define valor_fin_factor1 int;
define valor_ini_factor2 int;
define valor_fin_factor2 int;
define valor_ini_factor3 int;
define valor_fin_factor3 int;
define valor_ini_factor4 int;
define valor_fin_factor4 int;



define factor1 decimal(9,2);
define factor2 decimal(9,2);
define factor3 decimal(9,2);
define factor4 decimal(9,2);

define pago_minimo money(9,2);
define factor_adicional decimal(9,2);
define sql_err int;
define cod_ret char(05);
define comodin char(3);
define cuentas_abiertas int;
define cuentas_pl int;
define media_pl int;
define bandera_pl int;

let comodin = "0.0";
let credito_solicitado = 0; 
let cod_ret = "000";
let credito_final = 0;

BEGIN

ON EXCEPTION SET sql_err
   if sql_err <> 0 then
          RETURN sql_err, comodin;
   end if
END EXCEPTION;            

select valor into  credito_maximo   from br_param where cod_param = 110 ;

select valor into  valor_ini_factor1  from br_param where cod_param = 90 ;

select valor into  valor_fin_factor1  from br_param where cod_param = 91 ;

select valor into  valor_ini_factor2  from br_param where cod_param = 92 ;

select valor into  valor_fin_factor2  from br_param where cod_param = 93 ;

select valor into  valor_ini_factor3  from br_param where cod_param = 94 ;

select valor into  valor_fin_factor3  from br_param where cod_param = 95 ;

select valor into  valor_ini_factor4  from br_param where cod_param = 96 ;

select valor into  valor_fin_factor4  from br_param where cod_param = 97 ;





---------Se establece cuando elcomprobante de ingresos es tarjeta de credito

select count(*) into existe from bdisolicitud:ss_detdocum
    where num_solicitud = pnum_solicitud
     and grupo_docum = "06"
     and num_documen = 21;

if (existe = 1)
   then
       let  comprobante_ingresos = "TC";
   else 
       let comprobante_ingresos = "OT";
end if;


let credito_otorgado = 0;



if (comprobante_ingresos = "TC") 
   then 
       select count(*)  into numero_cuentas from br_tl
          where num_cliente = pnumcte and tl16 is null and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%") ;
          
       select monto_linea into credito_solicitado from bdisolicitud:ss_captrescom
          where num_solicitud = pnum_solicitud
          and numcte = pnumcte;
          
       if (numero_cuentas = 1) 
          then
                select round(tl23 - 1,-3) into credito_otorgado  from br_tl
                    where num_cliente = pnumcte and tl16 is null  and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%");
                    
             
                 if (credito_otorgado > credito_maximo)
                    then
                         let credito_autorizado = credito_maximo;
                    else
                         let credito_autorizado = credito_otorgado;
                 end if;
                 
                  if (credito_autorizado > credito_solicitado)
                     then
                        let credito_final = credito_solicitado;
                     else
                        let credito_final = credito_autorizado;
                  end if;

            elif (numero_cuentas  = 2)
               then 
                   select round(avg(tl23) - 1,-3) into credito_otorgado  from br_tl
                      where num_cliente = pnumcte and tl16 is null  and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%");

                    if (credito_otorgado > credito_maximo)
                       then
                          let credito_autorizado = credito_maximo;
                       else
                         let credito_autorizado = credito_otorgado;
                    end if;

                    if (credito_autorizado > credito_solicitado)
                       then
                          let credito_final = credito_solicitado;
                       else
                          let credito_final = credito_autorizado;
                    end if;


  
              elif (numero_cuentas > 2)
                 then
                     let bandera_mayor = 0;
                     let bandera_menor = 0;
                     let suma_credito_otorgado = 0;
                     let num_credito = 0;
                     
                     FOREACH WITH HOLD
                         select tl23 into credito_otorgado  from br_tl
                               where num_cliente = pnumcte and tl16 is null and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%")
                     
                          let continua = 0;
                          select max(tl23) into linea_mayor  from br_tl
                               where num_cliente = pnumcte and tl16 is null and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%");

                          select min(tl23) into linea_menor  from br_tl
                               where num_cliente = pnumcte and tl16 is null and ( tl02 like "%BANCO%" or tl02 like "%COMERCIAL%");
                          
                           if (credito_otorgado = linea_mayor)
                              then
                                  if (bandera_mayor = 0) 
                                     then 
                                         let bandera_mayor = 1; 
                                     else 
                                        let continua = 1;
                                    end if;
                              elif (credito_otorgado = linea_menor)
                                 then 
                                    if (bandera_menor = 0)
                                       then
                                           let bandera_menor = 1;
                                       else
                                          let continua = 1;
                                    end if;
                              else
                                  let  continua = 1;
                           end if;

                            
                           if (continua = 1)
                              then 
                                 let suma_credito_otorgado = suma_credito_otorgado + credito_otorgado;
                                 let num_credito = num_credito + 1;
                           end if;
                           
                 
                     END  FOREACH;
                     let credito_otorgado = 0;
                     let credito_otorgado = round((suma_credito_otorgado / num_credito) - 1,-3);

                    if (credito_otorgado is null or credito_otorgado = 0 or credito_otorgado = "  " ) 
                       then 
                          let cod_ret = "113";
                          return cod_ret,comodin; 
                     end if;

                     if (credito_otorgado > credito_maximo)
                        then
                           let credito_autorizado = credito_maximo;
                        else
                          let credito_autorizado = credito_otorgado;
                     end if;

                     if (credito_autorizado > credito_solicitado)
                        then
                           let credito_final = credito_solicitado;
                           let cod_ret = "000";
                        else
                           let credito_final = credito_autorizado;
                           let cod_ret = "000";
                     end if;

                    if (credito_final is null or credito_final = 0 or credito_final = "  " ) 
                       then 
                          let cod_ret = "114"; 
                          return cod_ret,comodin;
                   end if;
        
         end if;
       
   else
        let pago_minimo = 0;
        let factor_adicional = 0;
        let credito_solicitado = 0; 
        let credito_final = 0;
        let egresos = 0;
        let ingresos = 0;
        let vpuntos = 0;
        let monto_sugerido = 0;
        let bandera_pl = 0;
    
        select count(*) into cuentas_abiertas from br_tl
          where num_cliente = pnumcte and tl16 is null;       

       select count(*)  into cuentas_pl from br_tl
           where num_cliente = pnumcte and tl16 is null and tl30 = "PL";

       let media_pl = round(cuentas_abiertas  / 2);
    
       if (media_pl >= cuentas_abiertas)
          then
              let bandera_pl = 1;
       end if;
     


        select sum(tl12) into pago_minimo  from br_tl
           where num_cliente = pnumcte and tl16 is null ;

       select monto_linea,egresos_netos,ingresos_netos into credito_solicitado, egresos, ingresos  from bdisolicitud:ss_captrescom
          where num_solicitud = pnum_solicitud
          and numcte = pnumcte;

      SELECT  nvl(sum(calificacion),0) INTO  vpuntos  FROM bdisolicitud:ss_califica 
         WHERE num_solicitud = pnum_solicitud;

     if (vpuntos = 0)
        then
           let cod_ret = "212";
           return cod_ret,comodin;
         else
            LET monto_sugerido = (ingresos) * vpuntos / 100;
         end if;
            

         if (egresos <= pago_minimo)
            then
                    
                 if (bandera_pl = 0)
                    then 
                    
                          select valor into  factor1               from br_param where cod_param = 100 ;

                          select valor into  factor2               from br_param where cod_param = 101 ;

                          select valor into  factor3               from br_param where cod_param = 102 ;

                          select valor into  factor4               from br_param where cod_param = 103 ;

                          if (calificacion_cliente between valor_ini_factor1 and valor_fin_factor1 )  then let factor_adicional = factor1;
                            elif (calificacion_cliente between valor_ini_factor2 and valor_fin_factor2)  then let factor_adicional = factor2;
                            elif (calificacion_cliente between valor_ini_factor3  and valor_fin_factor3)  then let factor_adicional = factor3;
                            elif (calificacion_cliente between valor_ini_factor4 and valor_fin_factor4)  then let factor_adicional = factor4;
                         end if;

                         let credito_otorgado =  round((monto_sugerido * factor_adicional) - 1,-3);
                    else 
                         let credito_otorgado =  round(monto_sugerido - 1,-3);
                 end if;
  
               else
                   let credito_otorgado =  round(monto_sugerido - 1,-3);
          end if;

                   if (credito_otorgado is null or credito_otorgado = 0 or credito_otorgado = "  " ) 
                      then 
                          let cod_ret = "213";
                          return cod_ret,comodin; 
                      end if;

                     if (credito_otorgado > credito_maximo)
                        then
                           let credito_autorizado = credito_maximo;
                        else
                          let credito_autorizado = credito_otorgado;
                     end if;

                     if (credito_autorizado > credito_solicitado)
                        then
                           let credito_final = credito_solicitado;
                           let cod_ret = "000";
                        else
                           let credito_final = credito_autorizado;
                           let cod_ret = "000";
                     end if;

                  if (credito_final is null or credito_final = 0 or credito_final = "  " ) 
                    then 
                       let cod_ret = "214"; 
                       return cod_ret,comodin;
                   end if;


end if;

END;

return cod_ret,credito_final;
end procedure
;