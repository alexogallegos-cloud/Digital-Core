       // =============================================================
       // PROGRAMA : PRIMCALC  (ILE RPG free-format)
       // PROPOSITO: Calcula la prima anual de la poliza
       // LLAMADO POR: POLVAL
       // LLAMA A    : (ninguno)
       // =============================================================
       ctl-opt dftactgrp(*no) actgrp('POLIZAS');

       dcl-f TARIFA keyed usage(*input);

       dcl-pi PRIMCALC;
         inTipo   char(2)     const;
         inFactor packed(5:3) const;
         outPrima packed(13:2);
       end-pi;

       dcl-s IVA packed(5:3) inz(0.16);

       chain inTipo TARIFA;
       if not %found(TARIFA);
         outPrima = 0;
         return;
       endif;

       // RN-103: prima = base * factor de riesgo * (1 + IVA)
       //         IVA = 16% hardcoded
       outPrima = TARBASE * inFactor * (1 + IVA);

       // RN-104: la prima no puede ser menor a la prima minima de la tarifa
       if outPrima < TARMINIMO;
         outPrima = TARMINIMO;
       endif;

       return;