       // =============================================================
       // PROGRAMA : POLVAL  (ILE RPG free-format)
       // PROPOSITO: Valida y autoriza la emision de una poliza de auto
       // LLAMADO POR: PROCNOC (CL)
       // LLAMA A    : PRIMCALC, RIESGOEV
       // =============================================================
       ctl-opt dftactgrp(*no) actgrp('POLIZAS');

       dcl-f CLIMAST keyed usage(*input);

       dcl-pr PRIMCALC extpgm('PRIMCALC');
         tipo   char(2)   const;
         factor packed(5:3) const;
         prima  packed(13:2);
       end-pr;

       dcl-pr RIESGOEV extpgm('RIESGOEV');
         cliente packed(10:0) const;
         siniest packed(3:0)  const;
         factor  packed(5:3);
       end-pr;

       dcl-pi POLVAL;
         inCli   packed(10:0) const;
         inTipo  char(2)      const;
         outRes  char(2);
         outPrima packed(13:2);
       end-pi;

       dcl-s wFactor   packed(5:3);
       dcl-s wPrima    packed(13:2);
       dcl-s EDAD_MIN  int(5) inz(18);
       dcl-s MAX_SINI  int(5) inz(5);

       outRes = 'PE';
       outPrima = 0;

       // RN-101: el cliente debe existir y estar activo
       chain inCli CLIMAST;
       if not %found(CLIMAST);
         outRes = 'RE';
         return;
       endif;
       if CLIESTADO <> 'AC';
         outRes = 'RE';
         return;
       endif;

       // RN-102: edad minima del conductor = 18 (hardcoded EDAD_MIN)
       if CLIEDAD < EDAD_MIN;
         outRes = 'RE';
         return;
       endif;

       // RN-106: rechazo automatico si siniestros previos > 5 (hardcoded)
       if CLISINIEST > MAX_SINI;
         outRes = 'RE';
         return;
       endif;

       // Evaluacion de riesgo (puede llamar scoring externo dinamicamente)
       RIESGOEV(inCli : CLISINIEST : wFactor);

       // Calculo de prima
       PRIMCALC(inTipo : wFactor : wPrima);

       outPrima = wPrima;
       outRes = 'AP';
       return;