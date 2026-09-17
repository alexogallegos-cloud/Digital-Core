create procedure "informix".sp_consclientechq( pempresa char(3),
                                              ptipovalor integer,
                                            pparametro1 char(20))

       returning     char(5), -- vcodret
                     char(20), -- vcuenta
                     char(20), -- vnumcte
                     char(50), -- vnomcte
                     char(13), -- vrfc
                     date,      -- vfec_alta
                     date;      -- vfec_nacim

   -- ********************************************************************
   --
   -- Nombre:              sp_consclientechqt
   --
   -- Version              1.0.0
   -- Objetivo:            Consulta Todos los clientes de chequeras
   -- Supuestos:           Ninguno
   -- Tipo de parametros a pasar por la pantalla de consulta de chequeras y cheques
   --   ptipovalor de fine el caso de consulta a realizar
   -- 1.- Consulta por Cuenta
   --     Parametro1 numero de cuenta a consultar
   -- 2.- Consulta por Numero de Cliente
   --     Parametro1 numero de cliente
   -- 3.- Numero de Tarjeta
   --     Parametro1 Numero de Tarjeta
   -- Creado por:          Mario Escobar
   -- ModIFicado por:      Alejandro Rueda
   -- Ultima Modificacion: Febrero  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************


   -- // Definicion de variables
   define vcodret         char(5);
   define vsqlerr         integer;
   define vcuenta         char(20);
   define vcuenta1        char(20);
   define vnumtarjeta     char(20);
   define vnumcte         char(20);
   define vnomcte         char(50);
   define vrfc            char(13);
   define vfec_alta       date;
   define vfec_nacim      date;
   define vtpo_persona    char(2);
   define vpaterno        char(26);
   define vmaterno        char(26);
   define vnombre1        char(26);
   define vnombre2        char(26);
   define vcurp           char(20);
   define vnacionalidad   char(20);
   define vactividad_esp  char(20);
   define vvalor          char(1);
   define vdummy          char(100);

   LET vcodret = "000";
   LET vcuenta = " ";
   LET vcuenta1 = " ";
   LET vnumtarjeta = " ";
   LET vnumcte = " ";
   LET vnomcte = " ";
   LET vrfc    = " ";
   LET vfec_alta = " ";
   LET vfec_nacim = " ";
   LET vtpo_persona = " ";
   LET vnombre1 = " ";
   LET vnombre2 = " ";
   LET vcurp           = " ";
   LET vnacionalidad   = " ";
   LET vactividad_esp  = " ";
   LET vvalor = " ";
   --SET DEBUG FILE TO "/tmp/sp_consclientechq.out";
   --TRACE ON;

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 then
         LET vcodret = vsqlerr;
         return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
                /*vnumctefir,vnomctefir,vrfcfir,vfecnacfir,vfecaltafir;*/
      END IF;
   end exception;

   --Validacion por tipo

   IF ptipovalor <= 1 then
       LET vcuenta = trim(pparametro1);

      --- Valida exista la cuenta
       FOREACH
	   SELECT num_cte into vnumcte
         FROM bdicheq:sc_maechq
         WHERE empresa = pempresa and cuenta = vcuenta
       UNION
	   SELECT numcte_tf
         FROM bditransfer:tf_maecte
         WHERE cuenta_tf = vcuenta
	   END FOREACH;


       IF vnumcte is null then
          IF ptipovalor = 0 then
             LET vcodret = 100;
          ELSE
            LET vcodret = 104;
          END IF
         return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
       END IF

      -- Valida que la Cuenta contenga Chequera
        LET vcuenta1 = vcuenta;
        LET vcuenta = " ";
        SELECT cuenta, prod.val_chequeras
          INTO vcuenta, vvalor
          FROM bdicheq:sc_maechq mae, bdicheq:sc_producto prod
         WHERE mae.num_cte =  vnumcte
           AND mae.producto = prod.producto
           AND prod.val_chequeras = 'S'
           AND cuenta = vcuenta1;
     
       IF vcuenta is null then
         LET vcodret = 994;
         return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
       ELSE   

       EXECUTE PROCEDURE cons_nom_cte(pempresa,vnumcte)
                    INTO vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, vfec_nacim, vnacionalidad, vfec_alta,vdummy;

       LET vnomcte = trim(vnomcte)||" "||trim(vpaterno)||" "||trim(vmaterno);
      END IF
   ELIF ptipovalor = 2 then

       LET vnumcte = trim(pparametro1);

       --- Valida exista la cuenta
       /*SELECT cuenta into vcuenta
         FROM bdicheq:sc_maechq
         WHERE empresa = pempresa and num_cte = vnumcte;
       IF vcuenta is null then
         LET vcodret = 100;
         return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
       END IF*/

       EXECUTE PROCEDURE cons_nom_cte(pempresa,vnumcte)
       INTO vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, vfec_nacim, vnacionalidad, vfec_alta,vdummy;

       LET vnomcte = trim(vnomcte)||" "||trim(vpaterno)||" "||trim(vmaterno);
       return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;

   ELIF ptipovalor = 3 then

       LET vnumtarjeta = trim(pparametro1);

       SELECT cuenta, numcte  into vcuenta, vnumcte
         FROM bdicheq:sc_tarjeta
         WHERE empresa = pempresa and num_tarjeta = vnumtarjeta;
       IF vcuenta is null then
         LET vcodret = 996;
         return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
       END IF
        
       -- Valida que la Cuenta contenga Chequera
        LET vcuenta1 = vcuenta;
        LET vcuenta = " ";
        SELECT cuenta, prod.val_chequeras
          INTO vcuenta, vvalor
          FROM bdicheq:sc_maechq mae, bdicheq:sc_producto prod
         WHERE mae.num_cte =  vnumcte
           AND mae.producto = prod.producto
           AND prod.val_chequeras = 'S'
           AND cuenta = vcuenta1;

        IF vcuenta is null then
          LET vcodret = 994;
          return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;
        ELSE      


           EXECUTE PROCEDURE cons_nom_cte(pempresa,vnumcte)
                    INTO vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, vfec_nacim, vnacionalidad, vfec_alta,vdummy;

           LET vnomcte = trim(vnomcte)||" "||trim(vpaterno)||" "||trim(vmaterno);
        END IF 
   ELIF ptipovalor = 4 then
        LET vcuenta = trim(pparametro1);
        LET vnumcte = " ";
         FOREACH
          SELECT numcte INTO vnumcte
          FROM bdicheq:sc_firmantes WHERE cuenta = vcuenta

           EXECUTE PROCEDURE cons_nom_cte(pempresa,vnumcte)
              INTO vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, vfec_nacim, vnacionalidad, vfec_alta,vdummy;

           LET vnomcte = trim(vnomcte)||" "||trim(vpaterno)||" "||trim(vmaterno);
           return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim with resume;

       END FOREACH;
      IF vnumcte = " " OR vnumcte IS NULL THEN 
         LET  ptipovalor = 0;
      END IF

   END IF

 IF ptipovalor <>  4 THEN

   IF vcuenta is null then
      LET vcuenta = " ";
   END IF
   IF vnumtarjeta is null then
      LET vnumtarjeta = " ";
   END IF
   IF vnumcte is null then
      LET vnumcte = " ";
   END IF
   IF vnomcte is null then
      LET vnomcte = " ";
   END IF
   IF vrfc is null then
      LET vrfc = " ";
   END IF
   IF vfec_alta is null then
      LET vfec_alta = " ";
   END IF
   IF vfec_nacim is null then
      LET vfec_nacim = " ";
   END IF
   IF vtpo_persona is null then
      LET vtpo_persona = " ";
   END IF
   IF vnombre1 is null then
      LET vnombre1 = " ";
   END IF
   IF vnombre2 is null then
      LET vnombre2 = " ";
   END IF

      return vcodret,vcuenta,vnumcte,vnomcte,vrfc,vfec_alta,vfec_nacim;

 END IF
end
end procedure;