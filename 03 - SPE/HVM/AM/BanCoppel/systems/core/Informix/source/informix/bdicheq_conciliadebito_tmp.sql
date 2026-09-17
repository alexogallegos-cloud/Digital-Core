create procedure "informix".conciliadebito_tmp(pempresa char(3),
                                	       pnum_tarjeta char(16),
                                	       psucursal char(4),
                                	       pusuario char(8),
                                	       ptipomov char(1),
                                	       ptransacc char(4),
                                	       pfoliosuc char(16),
                                	       pmonto_tot money(14,2),
                                	       pdivisa char(2),
                                	       preferencia char(40),
                                	       pfolioori char(16),
					       pvRfcComer char (20),
					       pvRef23 char(23))
 returning char(5),char(1);

   define vcodret 	char(5);
   define vsqlerr 	integer;
   define vbandera 	char(1);
   define vcuenta 	char(20);
   define vtranret 	char(4);
   define vnum_serial 	integer;
   define vcancelad 	char(1);
   define vfecapli 	date;
   define vsdodisp 	money(14,2);
   define vmtoapli 	money(14,2);
   define vTranResp 	CHAR(4);
   define vTipoTran 	char(2);

   --set debug file to "conciliadebito_tmp.out";
   --trace on;

   begin

   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vbandera;
      end if
   end exception;

   let vcodret = "000";
   let vbandera = "E";
   let vsqlerr = 0;
   let vcuenta = "";
   let vtranret = "";
   let vnum_serial = 0;
   let vcancelad = "";
   let vfecapli = "";
   let vsdodisp = 0;
   let vmtoapli = 0;
   let vTranResp = "";
   let vTipoTran = "";


   select cuenta into vcuenta
    from sc_tarjeta
   where empresa = pempresa 
     and num_tarjeta = pnum_tarjeta;

   if vcuenta is null then
      let vcodret = "111";
      let vbandera = "E";
      return vcodret,vbandera;
   end if

   select num_serial,cancelad
     into vnum_serial,vcancelad
     from sc_movhis_old
    where empresa = pempresa 
      and cuenta = vcuenta 
      and folio_suc = pfoliosuc 
      and transacc = ptransacc;

   IF vnum_serial IS NULL THEN  -- Temporal
      select num_serial,cancelad
        into vnum_serial,vcancelad
        from sc_movhis_old
       where empresa = pempresa 
         and cuenta = vcuenta 
         and folio_suc = pfoliosuc 
         and monto_tot = pmonto_tot;
   END IF


   LET vTranResp = ptransacc;

   SELECT NVL(tranlibprot,"0000"),tipo_tran
     INTO ptransacc,vTipoTran
     FROM bdinteg:si_transacc
    WHERE empresa = pempresa
      AND numero = ptransacc
      AND sistema = "01";

   if ptipomov = "C" then
      if vTipoTran  in ("00","01","02") then
         let vbandera = "C";
	 return vcodret,vbandera;
      end if;

      IF ptransacc = "0000" OR ptransacc = " " THEN
         LET ptransacc = vTranResp;
      END IF

      call cargo_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                     pfoliosuc,vcuenta,0,pmonto_tot,pdivisa,preferencia,
                     pnum_tarjeta,"")
      returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;

      if vcodret <> "000" and vcodret <> "400" then
         let vbandera = "E";
         return vcodret,vbandera;
      elif vcodret = "400" then
         let vbandera = "0";
         return vcodret,vbandera;
      else
         let vbandera = "C";
         return vcodret,vbandera;
      end if
   end if

   if ptipomov = "A" then
      LET ptransacc = "0813";

      call abono_ref(pempresa,psucursal,pusuario,ptransacc,ptransacc,
                     pfoliosuc,vcuenta,0,pmonto_tot,pmonto_tot,0,0,0,
                     pdivisa,preferencia,pnum_tarjeta,"")
      returning vcodret;

      if vcodret <> "000" then
         let vbandera = "E";
         return vcodret,vbandera;
      else
         let vbandera = "C";
         return vcodret,vbandera;
      end if
   end if

   if ptipomov = "R" then
      call reversiontd(pempresa,psucursal,pusuario,pfolioori,"A",
                       vcuenta,ptransacc)
      returning vcodret;

      if vcodret <> "000" then
         let vbandera = "E";
         return vcodret,vbandera;
      else
         let vbandera = "C";
         return vcodret,vbandera;
      end if
   end if

   return vcodret,vbandera;

   end;

end procedure;