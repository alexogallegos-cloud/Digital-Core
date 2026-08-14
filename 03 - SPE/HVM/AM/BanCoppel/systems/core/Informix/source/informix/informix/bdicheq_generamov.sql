create procedure "informix".generamov(pfecha date)
       returning char(5);

   define vcodret     char(5);
   define vsqlerr     integer;
   define vsql  char(800);
   define vnomtabla char(30);


  let vcodret = "000";
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   let vsql = " select fech_alt,lpad(num_serial,10,0),cuenta," ||
       "rpad((transacc||' '||trim(descripcion)),50,' ')," ||
       "naturaleza,lpad(monto_tot,16,0),rpad(referencia,40,' '),";
   let vnomtabla = "movcap"||lpad(day(pfecha),2,0)||
                   lpad(month(pfecha),2,0)||year(pfecha)||".txt";
   let vsql = 'echo "UNLOAD TO ' || TRIM(vnomtabla) ||
              ' ' ||trim(vsql) ||'"  > query.sql';
   let vsql = vsql;
   SYSTEM vsql;
   let vsql = 'echo "'||"rpad(folio_suc,16,' '),rpad(usuario,8,' '),"||
              "rpad(cancelad,1,' ') from sc_movmes, bdinteg:si_transacc " ||
              "where fech_alt = '" ||pfecha ||
              "' and numero = transacc order by 1,3,2";
   let vsql = trim(vsql) ||'" >> query.sql';
   let vsql = vsql;
   SYSTEM vsql;
   LET vsql = "dbaccess bdicheq query.sql";
   SYSTEM vsql;

   let vsql = " select fech_alt,lpad(num_serial,10,0),cuenta," ||
       "rpad((transacc||' '||trim(descripcion)),50,' ')," ||
       "naturaleza,lpad(monto_tot,16,0),rpad(folio_suc,16,' ')," ||
       "rpad(usuario,8,' '),rpad(cancelad,1,' ') ";
   let vnomtabla = "movcer"||lpad(day(pfecha),2,0)||
                   lpad(month(pfecha),2,0)||year(pfecha)||".txt";
   let vsql = 'echo "UNLOAD TO ' || TRIM(vnomtabla) ||
              ' ' ||trim(vsql) ||'"  > query.sql';
   let vsql = vsql;
   SYSTEM vsql;
   let vsql = 'echo "'||"from sv_movmes, bdinteg:si_transacc " ||
               "where fech_alt = '" ||pfecha ||
               "' and numero = transacc order by 1,3,2";
   let vsql = trim(vsql) ||'" >> query.sql';
   let vsql = vsql;
   SYSTEM vsql;
   LET vsql = "dbaccess bdinvers query.sql";
   SYSTEM vsql;

   return vcodret;
end
end procedure;