create procedure "informix".bonifica(pempresa char(3),
                           psucursal  char(4),
                           pusuario   char(8),
                           pfolio_suc char(16),
                           pcuenta    char(20),
                           ptransacc char(4),
                           pmonto_com money(10,2))
 returning char(5), char(60),money(10,2);

 define vcodret char(5);
 define vfecha date;
 define vmoneda char(2);
 define vplaza char(3);
 define vproducto char(4);
 define vtasaiva decimal(9,6);
 define vivacom money(10,2);
 define vtotcom money(10,2);
 define vtransuc char(4);
 define vtranrel char(4);
 define vsqlerr integer;
 define vnaturaleza char(1);
 define vdocto integer;
 define vnombre char(60);
 define vrazon char(60);
 define vnumcte char(20);
 define vusuario char(8);
 define vtasabaseiva decimal(6,3);


 -- ****************************************************************************
 -- Inicializa variables
 -- ****************************************************************************
 let vcodret     = "000";
 let vivacom=0;
 let vdocto = 0;
 let vtransuc = "0000";
 let vnombre = " ";
 begin
    on exception set vsqlerr
       if vsqlerr <> 0 then
          let vcodret = vsqlerr;
          return vcodret, vnombre,vivacom;
       end if;
    end exception;

   select fecha_hoy into vfecha from sc_fechas where empresa = pempresa;

if pmonto_com = 0 then
   let vcodret = "110";
   return vcodret, vnombre, vivacom;
end if

select ejecutivo into vusuario from bdinteg:si_ejecut
   where ejecutivo = pusuario;
if vusuario <> pusuario or vusuario is null then
   let vcodret = "106";
   return vcodret, vnombre, vivacom;
end if

 select num_cte,producto,s.plaza, iva
    into vnumcte, vproducto, vplaza, vtasaiva
    from sc_maechq m, bdinteg:si_sucursales s
    where m.empresa = pempresa and cuenta = pcuenta
          and s.empresa = m.empresa and s.sucursal = m.sucursal;
if vproducto is null then
   let vcodret = "100";
   return vcodret, vnombre, vivacom;
end if
if vtasaiva is null then
   let vtasaiva = 0;
end if

select valor into vtasabaseiva
   from bdinteg:si_param
   where empresa = pempresa and cod_param = 47;

select apell_paterno||apell_materno||nombre1||nombre2, razon_social
   into vnombre, vrazon from bdinteg:si_cliente
   where numcte = vnumcte;

if vrazon is null or vrazon = " " then
else
   let vnombre = vrazon;
end if

if vnombre is null then
   let vnombre = " ";
end if

if vtasaiva <> vtasabaseiva then
   select trancivaesp into ptransacc
      from bdinteg:si_transacc
      where empresa = pempresa and numero=ptransacc;
end if

   select naturaleza, tran_relac into vnaturaleza,vtranrel
      from bdinteg:si_transacc
      where empresa = pempresa and numero=ptransacc;

if vnaturaleza <> "A" then
   let vcodret = "552";
   return vcodret, vnombre, vivacom;
end if;

if vtranrel is null or vtranrel = " " then
   let vtasaiva=0;
end if;

select divisa into vmoneda
        from sc_producto
        where empresa = pempresa and producto = vproducto;
if vmoneda is null then
        let vcodret="110";
        return vcodret, vnombre, vivacom;
end if;
let vivacom=pmonto_com*vtasaiva;

-- Bonifica comision

   call abono_ref(pempresa,psucursal, pusuario, ptransacc,
              vtransuc, pfolio_suc, pcuenta, vdocto, pmonto_com,
              pmonto_com, vdocto, vdocto, vdocto, vmoneda,"","","")
        returning vcodret;
   if vcodret="999" then
          return vcodret, vnombre,vivacom;
   end if;

-- Bonifica IVA de  comision
if vivacom > 0 then
   call abono_ref(pempresa, psucursal, pusuario, vtranrel,
              vtransuc, pfolio_suc, pcuenta, vdocto, vivacom,
              vivacom, vdocto, vdocto, vdocto, vmoneda,"","","")
        returning vcodret;
   if vcodret="999" then
          return vcodret, vnombre,vivacom;
   end if;
end if;

return vcodret, vnombre, vivacom;
end
end procedure;