create procedure "informix".sp_conchequerav( pempresa char(3),
                                            pcuenta  char(20),
                                            pconsec integer)
       RETURNING     char(5),   -- vcodret
                     char(20),  -- vnumcte
                     char(20),  -- vcuenta
                     char(20),  -- Reg_firmas, tipo de regimen
                     date,      -- Fecha de Recepcion
                     char(1),   -- Cve Estatus
                     integer,   -- numero de cheque inicial
                     integer,   -- numero de cheque final
                     integer,   -- numero de cheques
                     char(10),  -- consecutivo
                     char(50),  -- Detalle de Estatus
                     char(120);  -- nombre cliente

   -- ********************************************************************
   --
   -- Nombre:              sp_conchequerav
   --
   -- Version              1.0.0
   -- Objetivo:            Consulta de chequeras avanzado
   -- Supuestos:           Ninguno
   -- ModIFicado por:      Alejandro Rueda Sanchez
   -- Ultima Modificacion: Marzo  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************


   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vcuenta         char(20);
   DEFINE vnumcte         char(20);
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vfec_recep      date;
   DEFINE vchqini         integer;
   DEFINE vchqfin         integer;
   DEFINE vconsec         integer;
   DEFINE vimporte        money(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vnumero         integer;
   DEFINE vreg_firmas     integer;
   DEFINE vcuantos        integer;
   DEFINE vdummy          CHAR(100);
   DEFINE vpaterno      char(26);
   define vmaterno      char(26);
   define vnomcte       char(60);
   define vnombre       char(120);


   LET vdummy     = " ";
   LET vcodret     = " ";
   LET vcuenta     = " ";
   LET vnumcte     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfec_recep  = " ";
   LET vchqini     = 0;
   LET vchqfin     = 0;
   LET vconsec     = 0;
   LET vnumero     = 0;
   LET vreg_firmas = 0;
   LET vcuantos    = 0;
   LET vnombre    = "";

   --SET DEBUG FILE TO "/tmp/sp_conchequerav.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,
                 vchqfin,vnumero,vconsec,vdetstatus,vdummy;
       END IF;
    end exception;

    --//Extrae la informacion de la cuenta y cliente
    SELECT a.num_cte, a.cuenta, c.reg_firmas
      INTO vnumcte,vcuenta, vreg_firmas
      FROM bdicheq:sc_maechq a,
           bdicheq:sc_maenoc c
     WHERE a.empresa = pempresa
       AND a.cuenta = pcuenta
       AND a.cuenta = c.cuenta;

    IF vcuenta IS NULL OR vcuenta = "" THEN
       LET vcodret = 100;
       RETURN vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,
              vchqfin,vnumero,vconsec,vdetstatus,vdummy;
    END IF

    --IF pnumcheq = 0 THEN -- Trae todas las Chequeras
       --//Verifica si existen chequeras asociadas...
       FOREACH
          SELECT b.fecha_rec, b.status, b.inicial, b.final, b.consec
            INTO vfec_recep,vstatus,vchqini,vchqfin, vconsec
            FROM bdicntchq:sq_maechqra b
           WHERE b.empresa = pempresa
             AND b.cuenta = vcuenta
             AND b.consec = pconsec

           IF vconsec IS NOT NULL THEN
              EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, vconsec, "")
                        INTO vcodret, vnumero, vfecha_mov, vimporte,vcuantos;
           END IF

           SELECT descripcion
             INTO vdetstatus
             FROM bdicntchq:sq_status_chequera
            WHERE clave = 1
              AND status = vstatus;

          execute procedure cons_nom_cte(pempresa, vnumcte)
                  INTO vcodret, vdummy, vnomcte, vpaterno, vmaterno, vdummy, vdummy, vdummy,vdummy,vdummy,vdummy;

          LET vnombre = vnomcte||" "||trim(vpaterno)||" "||trim(vmaterno);

          RETURN vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,
                 vchqfin,vcuantos,vconsec,vdetstatus,vnombre WITH RESUME;
       END FOREACH

       IF vconsec IS NULL OR vconsec = 0 THEN
          LET vcodret = 994;
          RETURN vcodret,vnumcte,vcuenta,vreg_firmas,vfec_recep,vstatus,vchqini,
                 vchqfin,vnumero,vconsec,vdetstatus,vnombre;
       END IF
end
end procedure ;