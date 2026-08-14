       // =============================================================
       // PROGRAMA : OLDPRIM  (ILE RPG free-format)
       // PROPOSITO: Calculo de prima (version 2011, reemplazada)
       // LLAMADO POR: --- NINGUN PROGRAMA NI CL LO REFERENCIA ---
       // NOTA      : Sustituido por PRIMCALC. Quedo en la libreria.
       //             [DEAD CODE PLANTADO]
       // =============================================================
       ctl-opt dftactgrp(*no) actgrp('POLIZAS');

       dcl-pi OLDPRIM;
         inTipo   char(2)     const;
         outPrima packed(13:2);
       end-pi;

       dcl-s IVA_VIEJO packed(5:3) inz(0.15);

       // Version anterior usaba IVA 15% y base fija
       select;
         when inTipo = 'AM';
           outPrima = 12000 * (1 + IVA_VIEJO);
         when inTipo = 'LI';
           outPrima = 6000 * (1 + IVA_VIEJO);
         other;
           outPrima = 3000 * (1 + IVA_VIEJO);
       endsl;

       return;