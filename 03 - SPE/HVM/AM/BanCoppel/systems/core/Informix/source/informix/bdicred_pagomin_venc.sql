CREATE PROCEDURE "informix".pagomin_venc(eEmpresa CHAR(3))


DEFINE NumCred         CHAR(20);
DEFINE SdoCapInsoluto  MONEY(14,2);
DEFINE SdoNoExig       MONEY(14,2);
DEFINE SdoExigInt      MONEY(14,2);
DEFINE SdoCapital      MONEY(14,2);
DEFINE SdoMoratorio    MONEY(14,2);
DEFINE SdoTrab4        MONEY(14,2);
DEFINE TotalAdeudo     MONEY(14,2);
DEFINE vMtoVencido     MONEY(14,2);
DEFINE MontoFinanciado MONEY(14,2);
DEFINE MtoFinanc       MONEY(14,2);

--Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/pagomin_venc.out';
--trace on;


    FOREACH
	SELECT a.num_credito, sdo_cap_insoluto, sdo_no_exig, sdo_exig_int,
	       cap_tras_no_venci, sdo_contab_mora, sdo_trab4,
	       monto_financiado
	  INTO NumCred, SdoCapInsoluto, SdoNoExig, SdoExigInt,
	       SdoCapital, SdoMoratorio, SdoTrab4, MtoFinanc
	  FROM sd_maesdoshist a, sd_maecred b
	 WHERE b.empresa = eEmpresa
	   AND b.status_cred = "BT"
	   AND a.empresa = b.empresa
	   AND a.num_credito =  b.num_credito
	   AND a.fecha = "08/20/2007"

	SELECT sdo_trab4 INTO SdoTrab4
	  FROM sd_maesdoshist
	 WHERE fecha = "07/20/2007"
	   AND empresa = eEmpresa
	   AND num_credito = NumCred;


        SELECT SUM(iva_debe - iva_pagado) +
               SUM(mora_sdo_ordi - mora_sdo_ordi_pag) +
               SUM(mora_sdo_cope - mora_sdo_cope_pag) +
               SUM(mora_iva_debe - mora_iva_pagado)
          INTO TotalAdeudo
          FROM sd_amortiza_credito
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred;

        LET TotalAdeudo = TotalAdeudo + SdoCapInsoluto;

        IF TotalAdeudo < 0 THEN LET TotalAdeudo = 0; END IF

        IF TotalAdeudo > SdoTrab4 THEN
                LET vMtoVencido = (SdoCapInsoluto - SdoCapital) + SdoMoratorio;

                IF vMtoVencido IS NULL THEN
                        LET vMtoVencido = 0;
                END IF

                 LET TotalAdeudo = (SdoCapital / 12) +
                                   (SdoNoExig +  vMtoVencido );

             IF (TotalAdeudo > SdoTrab4) THEN
                LET TotalAdeudo = ROUND(TotalAdeudo,-0);
                LET MontoFinanciado = TotalAdeudo;
             ELSE
                LET MontoFinanciado = SdoTrab4;
             END IF
        ELSE
                LET MontoFinanciado = ROUND(TotalAdeudo,-0);
        END IF;
        LET SdoTrab4 = MontoFinanciado;

	UPDATE sd_maesdos SET monto_financiado = MontoFinanciado,
			      sdo_trab4 = MontoFinanciado
	 WHERE empresa = eEmpresa
           AND num_credito = NumCred;

	UPDATE sd_maesdoshist SET monto_financiado = MontoFinanciado,
			      sdo_trab4 = MontoFinanciado
	 WHERE empresa = eEmpresa
           AND num_credito = NumCred;


   END FOREACH

END PROCEDURE


;