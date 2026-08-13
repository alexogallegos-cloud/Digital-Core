CREATE PROCEDURE "informix".sp_crdvigente(eEmpresa  CHAR(3))

   RETURNING CHAR(5);     -- Codigo de Retorno

   -- Variables Locales

   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE CodRet                CHAR(5);
   DEFINE vIntVig               DECIMAL(14,2);
   DEFINE vNumCrd               CHAR(20);
   DEFINE vFecCuota             DATE;



   ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "sp_calcintreal.err";
        TRACE sql_err||" * "||isam_err||" * "||error_info;
        LET CodRet = sql_err;
        RETURN CodRet;
   END EXCEPTION;


  --SET DEBUG FILE TO "/tmp/sp_crdvigente.out";
  --TRACE ON;

  LET CodRet          = "000";
  LET sql_err         = 0;
  LET isam_err        = 0;
  LET error_info      = "";
  LET vIntVig         = 0;
  LET vNumCrd         = '';
  LET vFecCuota       = '';

                               --Actualiza De VP a Vigente

  FOREACH
          SELECT nvl(mto_venc_tra_int,0),num_credito
          INTO vIntVig,vNumCrd
          FROM sd_maesdoscrd
          WHERE empresa = eEmpresa
           AND num_credito in('610012993321','610012991176')

         UPDATE sd_maesdoscrd SET sdo_no_exig    = mto_venc_tra_int,
                               provision_normal  = mto_venc_tra_int,
                               mto_venc_tra_int  = 0,
                               sdo_capital       = cap_tras_no_venci,
                               cap_tras_no_venci = 0
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd;

          UPDATE sd_maecredcrd SET status_cred ='AA',
                               pagos_sostenidos  = 0
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd;

         UPDATE sd_amortiza_creditocrd set capital_status = '1',
                                        interes_status = '1'
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd
           AND capital_status <>'5';

  END FOREACH;

              --Actualiza Creditos Con Interes No Devengado

 FOREACH
          SELECT nvl(sdo_no_exig,0),num_credito
          INTO vIntVig,vNumCrd
          FROM sd_maesdoscrd
          WHERE empresa = eEmpresa
           AND num_credito in('610012916199','610012929457','610012991341','610013006206')

          SELECT min(fecha_cuota)
          INTO vFecCuota
          FROM sd_amortiza_creditocrd
          WHERE empresa = eEmpresa
            AND num_credito = vNumCrd
            AND capital_status ='3';

         UPDATE sd_amortiza_creditocrd set capital_status = '1',
                                        interes_status = '1'
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd
           AND capital_status <>'5';

         UPDATE sd_amortiza_creditocrd SET interes_debe = vIntVig
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd
           AND Fecha_cuota = vFecCuota;

          UPDATE sd_maecredcrd SET status_cred ='AA'
         WHERE empresa = eEmpresa
           AND num_credito = vNumCrd;

  END FOREACH;

  FOREACH
         SELECT num_credito
         INTO vNumCrd
         FROM sd_maesdoscrd 
         WHERE empresa = eEmpresa
            AND num_credito in (select  num_credito from sd_maecredcrd WHERE empresa = eEmpresa and status_cred='AA')


         UPDATE sd_maesdoscrd SET dias_acum_mora = 0
         WHERE empresa = eEMpresa and num_credito =vNumCrd;
  END FOREACH;

  
  










        RETURN CodRet;
END PROCEDURE;