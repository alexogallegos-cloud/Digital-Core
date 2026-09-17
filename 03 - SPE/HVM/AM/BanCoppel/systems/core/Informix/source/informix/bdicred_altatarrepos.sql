Create procedure "informix".altatarrepos(pempresa char(3),
                        pnum_credito    char(20),
                        pnumtarjeta     char(20),
                        pnumcte         char(20),
                        pexpiracion     date,
                        ptipo_tar       char(1),
                        pstatus         char(1),
                        plimite_aut     money (14, 2),
                        pprodtarjeta    char(4),
                        pnombre         char(104),
                        psistema        smallint,
                        pmotivo         char(2),
                        pnumtarjetaant  char(20))

 Returning      char(5);

 define vcodret         char(5);
 define vsiguiente      integer;
 define vexiste         integer;
 define vsqlerr         integer;
 define vtarjeta        char(20);

 let vcodret = "";
 let vsiguiente = 0;
 let vexiste= 0;
 let vsqlerr = 0;
 let vtarjeta = "";

 Begin

        On exception set vsqlerr
           if vsqlerr<>0 then
              let vcodret = vsqlerr;
              return vcodret;
            end if;
        end exception;


 --  set debug file to  '/pisa/pisabanco/pisa_ftes/credito/altatarrepos.out';
--   trace on;

        if pnum_credito is null or pnum_credito="" then
           let vcodret = '100';
           return vcodret;
        end if;

        if pnumtarjetaant is null or pnumtarjetaant = "" then
           let vcodret = '101';
         return vcodret;
        end if;

        if pnumtarjeta is null or pnumtarjeta= "" then
           let vcodret = '101';
         return vcodret;
        end if;

        if pnumcte is null or pnumcte = "" then
           let vcodret= '102';
         return vcodret;
        end if;

      if psistema = 6 then
         select num_tarjeta
           into vtarjeta
           from bdicred:sd_tarjeta
          where empresa = pempresa and num_tarjeta = pnumtarjeta;

          if vtarjeta is not null then
             let vcodret= "430";
             return vcodret;
          end if

           let vcodret = "000";

           select max(secuencia) + 1 into vsiguiente
           from bdicred:sd_tarjeta
           where empresa=pempresa and num_credito=pnum_credito;

           if vsiguiente is null then
              let vsiguiente = 1;
           end if;
           -- Carga los Datos de la Tarjeta Anterior
           select numcte,tipo_tarjeta,nombre
           into   pnumcte,ptipo_tar,pnombre
           from   sd_tarjeta
           where  empresa=pempresa and num_tarjeta=pnumtarjetaant;

           insert into bdicred:sd_tarjeta
                   (empresa, num_credito, secuencia, num_tarjeta, numcte, expiracion, tipo_tarjeta, status_tar, limite_aut, prodtarjeta, nombre, motivo)
             Values(pempresa, pnum_credito, vsiguiente, pnumtarjeta, pnumcte, pexpiracion, ptipo_tar, pstatus, plimite_aut, pprodtarjeta, pnombre, pmotivo);


        end if

      if psistema = 1 then
         select num_tarjeta
           into vtarjeta
           from bdicheq:sc_tarjeta
          where empresa = pempresa and cuenta = pnumtarjeta;

          if vtarjeta is not null then
             let vcodret= "430";
             return vcodret;
          end if

           let vcodret = "000";

           select max(secuencia) + 1 into vsiguiente
           from bdicheq:sc_tarjeta
           where empresa=pempresa and cuenta=pnum_credito;

           if vsiguiente is null then
              let vsiguiente = 1;
           end if;

           -- Carga los Datos de la Tarjeta Anterior
           select numcte,tipo_tarjeta,nombre
           into   pnumcte,ptipo_tar,pnombre
           from   bdicheq:sc_tarjeta
           where  empresa=pempresa and num_tarjeta=pnumtarjetaant;

           insert into bdicheq:sc_tarjeta
                   (empresa, cuenta, secuencia, num_tarjeta, numcte, expiracion, tipo_tarjeta, status_tar, limite_aut, prodtarjeta, nombre, motivo)
             Values(pempresa, pnum_credito, vsiguiente, pnumtarjeta, pnumcte, pexpiracion, ptipo_tar, pstatus, plimite_aut, pprodtarjeta, pnombre, pmotivo);


        end if

        return vcodret;

 end
 end procedure;