       // =============================================================
       // PROGRAMA : POLALT  (SQLRPGLE - embedded SQL)
       // PROPOSITO: Da de alta una poliza autorizada en POLMAST
       // LLAMADO POR: PROCNOC (CL)
       // LLAMA A    : (ninguno)
       // =============================================================
       ctl-opt dftactgrp(*no) actgrp('POLIZAS');

       dcl-pi POLALT;
         inCli   packed(10:0) const;
         inTipo  char(2)      const;
         inPrima packed(13:2) const;
         inSuma  packed(13:2) const;
         outRes  char(2);
       end-pi;

       outRes = 'OK';

       exec sql
         INSERT INTO POLMAST
           (POLCLI, POLTIPO, POLPRIMA, POLSUMASEG, POLESTADO)
         VALUES
           (:inCli, :inTipo, :inPrima, :inSuma, 'VI');

       if sqlcode <> 0;
         outRes = 'ER';
       endif;

       return;