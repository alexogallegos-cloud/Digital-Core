       // =============================================================
       // PROGRAMA : RIESGOEV  (ILE RPG free-format)
       // PROPOSITO: Determina el factor de riesgo del cliente
       // LLAMADO POR: POLVAL
       // LLAMA A    : (dinamico) programa de scoring segun wProgScore
       // =============================================================
       ctl-opt dftactgrp(*no) actgrp('POLIZAS');

       dcl-pr scoreExt extpgm(wProgScore);
         cliente packed(10:0) const;
         score   packed(3:0);
       end-pr;

       dcl-pi RIESGOEV;
         inCli    packed(10:0) const;
         inSinies packed(3:0)  const;
         outFactor packed(5:3);
       end-pi;

       // El nombre del programa de scoring se resuelve en runtime
       // [DYNAMIC CALL PLANTADO] - no resoluble por analisis estatico
       dcl-s wProgScore char(10) inz('SCOREXT');
       dcl-s wScore     packed(3:0);
       dcl-s UMBRAL     int(5) inz(500);

       scoreExt(inCli : wScore);

       // Factor base segun siniestros previos
       select;
         when inSinies = 0;
           outFactor = 1.000;
         when inSinies <= 2;
           outFactor = 1.200;
         other;
           outFactor = 1.400;
       endsl;

       // RN-105: si el score externo < 500, recargo de 1.5x (umbral hardcoded)
       if wScore < UMBRAL;
         outFactor = outFactor * 1.500;
       endif;

       return;