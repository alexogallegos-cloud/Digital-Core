create procedure "informix".conchequera(pempresa char(3),
                                        pcuenta char(20))
       returning char(5),char(50),char(20),integer,integer,date,integer;

   define vcodret    char(5);
   define vsqlerr    integer;
   define vnomcte    char(50);
   define vmoneda    char(20);
   define vchqini    integer;
   define vchqfin    integer;
   define vfecrec    date;
   define vultchq    integer;
   define vnumcte    char(20);
   define vdivisa    char(2);
   define vapepat    char(20);
   define vapemat    char(20);
   define vnombr1    char(20);
   define vnombr2    char(20);
   define vtotreg    smallint;


   let vcodret = "000";
   let vnomcte = " ";
   let vmoneda = " ";
   let vchqini = 0;
   let vchqfin = 0;
   let vfecrec = "";
   let vultchq = 0;
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vnomcte,vmoneda,vchqini,vchqfin,vfecrec,vultchq;
      end if;
   end exception;

   --- Valida exista la cuenta
   select num_cte, ult_chq into vnumcte, vultchq
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   if vnumcte is null then
      let vcodret = 100;
      return vcodret,vnomcte,vmoneda,vchqini,vchqfin,vfecrec,vultchq;
   end if

   --- Extrae el nombre del cliente
   select razon_social, apell_paterno, apell_materno, nombre1, nombre2
      into vnomcte, vapepat, vapemat, vnombr1, vnombr2
      from bdinteg:si_cliente
      where numcte = vnumcte;
   if vnomcte is null then
      let vnomcte = " ";
   end if
   if vapepat is null then
      let vapepat = " ";
   end if
   if vapemat is null then
      let vapemat = " ";
   end if
   if vnombr1 is null then
      let vnombr1 = " ";
   end if
   if vnombr2 is null then
      let vnombr2 = " ";
   end if
   let vnomcte = trim(vnomcte)||trim(vnombr1)||" "||trim(vnombr2)||
                 " "||trim(vapepat)||" "||trim(vapemat);

   select count(*) into vtotreg
      from bdicntchq:sq_reqctes
      where cuenta = pcuenta and estado = "E";
   if vtotreg = 0 or vtotreg is null then
      return vcodret,vnomcte,vmoneda,vchqini,vchqfin,vfecrec,vultchq;
   end if

   foreach
      select divisa,inicial,final,fecha_rec
         into vdivisa, vchqini, vchqfin, vfecrec
         from bdicntchq:sq_reqctes
         where cuenta = pcuenta and estado = "E"
      select descripcion into vmoneda
         from bdinteg:si_divisas
         where empresa = pempresa and divisa = vdivisa;
      let vmoneda = vdivisa||" "||trim(vmoneda);
      return vcodret,vnomcte,vmoneda,vchqini,vchqfin,vfecrec,vultchq
             with resume;
   end foreach
end
end procedure;