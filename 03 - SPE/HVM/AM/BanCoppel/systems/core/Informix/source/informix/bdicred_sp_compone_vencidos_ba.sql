CREATE PROCEDURE "informix".sp_compone_vencidos_ba(o_empresa char(3))

RETURNING char(6),char(80);


    DEFINE cCodRet                  char(6);
    DEFINE cMensaje                 char(80);
    DEFINE sql_err                  integer;
    DEFINE isam_err                 integer;
    DEFINE cSql                     char(1024);

----variables de cuadre de vencido
    DEFINE v_numcredito             char(20);
    DEFINE v_sdocapital             DECIMAL(18,2);
    DEFINE v_sdocapinso             DECIMAL(18,2);
    DEFINE v_montovenci             DECIMAL(18,2);
    DEFINE v_montovencihist         DECIMAL(18,2);
    DEFINE v_mtovencitras           DECIMAL(18,2);
    DEFINE v_captrasnovenci         DECIMAL(18,2);
    DEFINE v_sdomora_amor           DECIMAL(18,2);
    DEFINE v_sdocontabmora          DECIMAL(18,2);
    DEFINE v_diasacummora           INTEGER;
    DEFINE v_montofinanciado        DECIMAL(18,2);
    DEFINE v_montofinanciadohist    DECIMAL(18,2);
    DEFINE v_sdotrab4hist           DECIMAL(18,2);
    DEFINE v_fechatrab4hist         DATE;
    DEFINE v_sdo_no_exig            DECIMAL(18,2);

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

    LET cCodRet = "000000";
    LET cMensaje = "PROCESO EXITOSO";
    LET cSql= "";

    LET v_numcredito = "";
    LET v_sdocapital=0;      
    LET v_sdocapinso=0;  
    LET v_montovenci=0;
    LET v_montovencihist=0;
    LET v_mtovencitras=0;
    LET v_captrasnovenci=0;
    LET v_sdomora_amor=0;
    LET v_sdocontabmora=0;
    LET v_diasacummora=0;
    LET v_montofinanciado=0;
    LET v_montofinanciadohist=0;
    LET v_sdotrab4hist=0;
    LET v_fechatrab4hist=DATE(1);
    LET v_sdo_no_exig=0;

  --SET DEBUG FILE TO "/pisa/cas/compone_vencidos_BA.out";
  --TRACE ON;

    FOREACH WITH HOLD 

       SELECT num_credito 
       INTO v_numcredito
       FROM sd_maecred
       WHERE empresa=o_empresa
       AND status_cred='BA'
       AND num_credito in ('600001498432','600003099444','600003149256','600004085392',
                           '600004784010','600005058307')      

      SELECT sdo_capital,sdo_cap_insoluto,monto_vencido,
              mto_venc_trasp ,cap_tras_no_venci,monto_financiado,
              sdo_no_exig
        INTO v_sdocapital,v_sdocapinso,v_montovenci,
             v_mtovencitras,v_captrasnovenci,v_montofinanciado,
             v_sdo_no_exig
        FROM sd_maesdos
       WHERE empresa=o_empresa
         AND num_credito = v_numcredito;
     --    AND (sdo_capital + monto_vencido <>sdo_cap_insoluto or mto_venc_trasp <> 0
      --       or cap_tras_no_venci <> 0);
    BEGIN WORK;

        IF v_sdocapinso <> (v_sdocapital + v_montovenci) and v_sdocapinso>0 THEN
            UPDATE sd_maesdos
            SET sdo_capital=sdo_cap_insoluto-monto_vencido
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
        END IF;

        IF v_sdocapinso <= v_montovenci and v_sdocapinso>0 THEN
            UPDATE sd_maesdos
            SET monto_vencido=sdo_cap_insoluto
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
        END IF;

        IF v_mtovencitras <> 0 or v_captrasnovenci <> 0 THEN
            UPDATE sd_maesdos
            SET mto_venc_trasp=0,
                cap_tras_no_venci=0
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
        END IF;

       SELECT fecha,sdo_trab4,monto_vencido,monto_financiado
       INTO v_fechatrab4hist,v_sdotrab4hist,v_montovencihist,v_montofinanciadohist
       FROM sd_maesdoshist
       WHERE empresa=o_empresa
       AND num_credito = v_numcredito
       AND fecha=(SELECT MAX(fecha) FROM sd_maesdoshist
                  WHERE empresa=o_empresa
                  AND num_credito = v_numcredito); 

        IF v_montofinanciado < 0 THEN
           LET v_montofinanciado=0;
        END IF;   
        IF v_montovenci <= 0 THEN
           LET v_montovenci=0;
        END IF;   


      ---cuadra saldos de mensualidad anterior en 7  
        IF v_montovenci=0 THEN
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_montovencihist,
                capital_debe=v_montovencihist,
                capital_pagado=v_montovencihist,
                capital_status='5'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=DATE(v_fechatrab4hist - 1 UNITS MONTH);

            UPDATE sd_maecred
            SET status_cred='AA'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
         ELSE
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_montovencihist,
                capital_debe=v_montovencihist,
                capital_pagado=v_montovencihist-v_montovenci,
                capital_status='7'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=DATE(v_fechatrab4hist - 1 UNITS MONTH);


            UPDATE sd_maecredanexo
            SET fecha_vencto=DATE(v_fechatrab4hist - 1 UNITS MONTH)
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
            

          END IF;

            UPDATE sd_amortiza_credito 
            SET capital_status='5'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota < DATE(v_fechatrab4hist - 1 UNITS MONTH);
        
      ---cuadra saldos de mensualidad vigente en 1   
        IF v_montovenci=0 and v_montofinanciado<=0 THEN 
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_montofinanciadohist - v_montovencihist,
                capital_debe=v_montofinanciadohist - v_montovencihist,
                capital_pagado=capital_debe,
                capital_status='5'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=v_fechatrab4hist;
        ELSE
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_montofinanciadohist - v_montovencihist,
                capital_debe=v_montofinanciadohist - v_montovencihist,
                capital_pagado=capital_debe - (v_montofinanciado - v_montovenci)
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=v_fechatrab4hist;
        END IF;

----VERIFICA QUE LOS MORATORIOS CUADREN EN SALDOS Y AMORTIZA
              
             SELECT SUM(mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)
             INTO v_sdomora_amor
             FROM sd_amortiza_credito
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito
             AND capital_status IN (7); 

          --   SELECT sdo_contab_mora+sdo_moratorio
          --   INTO v_sdocontabmora
          --   FROM sd_maesdos
          --   WHERE empresa=o_empresa
          --   AND num_credito=v_numcredito;

             IF v_sdomora_amor<0 or v_sdomora_amor is null  THEN
                LET v_sdomora_amor=0;
             END IF;

             IF v_sdocontabmora<0 or v_sdocontabmora is null THEN
                LET v_sdocontabmora=0;
             END IF;

  
                UPDATE sd_maesdos
                SET sdo_contab_mora=v_sdomora_amor,
                    sdo_moratorio=0
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;

                UPDATE sd_amortiza_credito
                SET mora_sdo_ordi=mora_sdo_ordi + mora_provi_ordi,
		    mora_sdo_cope=mora_sdo_cope + mora_provi_cope,
		    mora_sdo_ordi_pag=mora_sdo_ordi,
		    mora_sdo_cope_pag=mora_sdo_cope,
		    mora_provi_ordi=0,
		    mora_provi_cope=0
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
		AND capital_status='5';

		UPDATE sd_maecred 
		set tasa_techo=6
		where empresa=o_empresa
		and num_credito=v_numcredito;

        COMMIT WORK;

    END FOREACH;

--		update sd_maecred 
--		set tasa_techo=null 	
--		where empresa='001' 
--		and status_cred='AA' 
--		and tasa_techo =2;

 RETURN cCodRet,cMensaje;


END PROCEDURE;