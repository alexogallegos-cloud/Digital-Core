CREATE PROCEDURE "informix".saldosi()
   define v_empresa    char(3);
   define v_ccmayor    char(3);
   define v_ccsub      char(3);
   define v_ccsubsub   char(3);
   define v_ccssubsub  char(3);
   define v_ccsssubsub char(3);
   define v_sector     char(3);
   define v_row        integer;
   define v_nat_cta    char(1);
   define v_nat_movto  char(1);
   define v_cambia_nat char(1);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let v_empresa           = " ";
   let v_ccmayor    = " ";
   let v_ccsub      = " ";
   let v_ccsubsub   = " ";
   let v_ccssubsub  = " ";
   let v_ccsssubsub = " ";
   let v_sector     = " ";
   let v_row        = " ";
   let v_nat_cta    = " ";
   let v_nat_movto  = " ";
   let v_cambia_nat = " ";
-- ***************************************************************************
-- Procesa Informacion
-- ***************************************************************************

   foreach
      select rowid, naturaleza, empresa, ccmayor, ccsub, ccsubsub,
             ccssubsub, ccsssubsub,sector
      into   v_row, v_nat_movto,v_empresa,v_ccmayor,v_ccsub,v_ccsubsub,
             v_ccssubsub,v_ccsssubsub,v_sector
      from   co_detpol

      select naturaleza_cta
      into   v_nat_cta
      from   bdinteg:si_catalog
      where  empresa = v_empresa
      and    ccmayor = v_ccmayor
      and    ccsub   = v_ccsub
      and    ccsubsub = v_ccsubsub
      and    ccssubsub = v_ccssubsub
      and    ccsssubsub = v_ccsssubsub
      and    sector = v_sector;

      if v_nat_movto = "D" then
         if v_nat_cta = "D" then
            let v_cambia_nat = "D";
         end if
         if v_nat_cta = "A" then
            let v_cambia_nat = "C";
         end if
      end if

      if v_nat_movto = "A" then
         if v_nat_cta = "D" then
            let v_cambia_nat = "D";
         end if
         if v_nat_cta = "A" then
            let v_cambia_nat = "C";
         end if
      end if

      update co_detpol
      set naturaleza = v_cambia_nat
      where rowid = v_row;

   end foreach
end procedure;