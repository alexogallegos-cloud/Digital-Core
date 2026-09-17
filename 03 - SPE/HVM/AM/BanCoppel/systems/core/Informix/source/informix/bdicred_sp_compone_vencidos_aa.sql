CREATE PROCEDURE "informix".sp_compone_vencidos_aa(o_empresa char(3))

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
    DEFINE v_mtovencitras           DECIMAL(18,2);
    DEFINE v_captrasnovenci         DECIMAL(18,2);
    DEFINE v_sdomora                DECIMAL(18,2);
    DEFINE v_sdocontabmora          DECIMAL(18,2);
    DEFINE v_diasacummora           INTEGER;
    DEFINE v_montofinanciado        DECIMAL(18,2);
    DEFINE v_sdotrab4hist              DECIMAL(18,2);
    DEFINE v_fechatrab4hist             DATE;
    DEFINE v_sdo_no_exig            DECIMAL(18,2);
    DEFINE v_interes_vig            DECIMAL(18,2);

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
    LET v_mtovencitras=0;
    LET v_captrasnovenci=0;
    LET v_sdomora=0;
    LET v_sdocontabmora=0;
    LET v_diasacummora=0;
    LET v_montofinanciado=0;
    LET v_sdotrab4hist=0;
    LET v_fechatrab4hist=DATE(1);
    LET v_sdo_no_exig=0;
    LET v_interes_vig=0;

 -- SET DEBUG FILE TO "compone_vencidos_AA.out";
 -- TRACE ON;

    FOREACH WITH HOLD 

       SELECT a.num_credito 
       INTO v_numcredito
       FROM sd_maecred a, sd_maesdos b
       WHERE a.empresa='001'
       and a.empresa = b.empresa
       and a.num_credito = b.num_credito
       AND status_cred='AA'
--       AND tasa_techo is null 
       AND a.num_credito IN ('600000062387','600000194768','600000447083','600000479664','600000539889','600000550217',
            '600000585312','600000610458','600000554680','600000661311','600000717444','600000819737',
            '600000829769','600000830007','600000838125','600000748472','600001001012','600001008553',
            '600001062717','600001148870','600001151627','600001201760','600001242137','600001244562',
            '600001271516','600000906849','600001345294','600004898190','600001363008','600001372983',
            '600001404117','600001416616','600001471827','600001479705','600001515524','600001520227',
            '600001655775','600001687570','600001706735','600001726139','600001119376','600001818522',
            '600001828927','600001849071','600001906020','600001927984','600001946752','600001964672',
            '600001881876','600002011747','600002053301','600002102884','600002158530','600002164132',
            '600001469011','600002234133','600002237607','600002383500','600000396777','600002496708',
            '600002605621','600002625215','600001319349','600002720479','600002761127','600002772900',
            '600004149040','600002820386','600002825831','600002841341','600002912431','600002913892',
            '600003203905','600003214530','600003312698','600003340228','600003399083','600003408140',
            '600003481907','600003400873','600003710172','600003483903','600003823959','600003866578',
            '600003920409','600004104342','600003582803','600004115553','600004289036','600004164288',
            '600004297948','600004095029','600004290497','600004487911','600004916463','600005265571',
            '600001026407','600005352916','600005537862','600006109570','600008544089','600006361429',
            '600006208695','600000244597','600006772658','600006801820','600006723701','600006809252',
            '600007180422','600007460204','600007868570','600007918961','600000817996','600002522461',
            '600000752011','600002287164','600002385471','600002112313','600002713011','600004085392',
            '600004784010')

       
       

       SELECT fecha,sdo_trab4
       INTO v_fechatrab4hist,v_sdotrab4hist
       FROM sd_maesdoshist
       WHERE empresa=o_empresa
       AND num_credito = v_numcredito
       AND fecha=(SELECT MAX(fecha) FROM sd_maesdoshist
                  WHERE empresa=o_empresa
                  AND num_credito = v_numcredito); 

       IF v_fechatrab4hist IS NULL OR v_sdotrab4hist IS NULL  THEN
          CONTINUE FOREACH;
       END IF;

      SELECT sdo_capital,sdo_cap_insoluto,monto_vencido,
              mto_venc_trasp ,cap_tras_no_venci,sdo_moratorio,
              sdo_contab_mora ,dias_acum_mora,monto_financiado,
              sdo_no_exig
        INTO v_sdocapital,v_sdocapinso,v_montovenci,
             v_mtovencitras,v_captrasnovenci,v_sdomora,
             v_sdocontabmora,v_diasacummora,v_montofinanciado,
             v_sdo_no_exig
        FROM sd_maesdos
       WHERE empresa=o_empresa
         AND num_credito = v_numcredito;

    BEGIN WORK;

        IF v_montovenci <> 0 or v_mtovencitras <> 0 or v_captrasnovenci <> 0 
           or v_sdomora+v_sdocontabmora <> 0 or  v_diasacummora <> 0 or v_sdocapinso<>v_sdocapital  THEN
            UPDATE sd_maesdos
            SET monto_vencido=0,
                mto_venc_trasp=0,
                cap_tras_no_venci=0,
                sdo_moratorio=0,
                sdo_contab_mora=0,
                dias_acum_mora=0,
                sdo_capital=sdo_cap_insoluto
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;
        END IF;
     
        IF v_montofinanciado < 0 or v_montofinanciado is null THEN
           LET v_montofinanciado=0;
        END IF;   
            
        IF v_montofinanciado <= 0 THEN
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_sdotrab4hist,
                capital_debe=v_sdotrab4hist,
                capital_pagado=v_sdotrab4hist,
                capital_status='5'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=v_fechatrab4hist;
        ELSE
            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_sdotrab4hist,
                capital_debe=v_sdotrab4hist,
                capital_pagado=v_sdotrab4hist-v_montofinanciado
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=v_fechatrab4hist;
        END IF;

        select interes_debe-interes_pagado
        into v_interes_vig
        from sd_amortiza_credito 
        where empresa=o_empresa 
        and num_credito=v_numcredito 
        and fecha_cuota=v_fechatrab4hist;

	IF v_interes_vig < 0 or v_interes_vig is null then
	   LET v_interes_vig =0;
	END IF;
        

        IF v_sdo_no_exig <> v_interes_vig THEN
           UPDATE sd_maesdos
           SET sdo_no_exig=v_interes_vig,
               int_tra_no_exig= case when (int_tra_no_exig - v_interes_vig)<0 then 0 
				else int_tra_no_exig - v_interes_vig end
           WHERE empresa=o_empresa 
           AND num_credito=v_numcredito;
        END IF;

        UPDATE sd_amortiza_credito 
        SET mora_sdo_ordi=mora_sdo_ordi + mora_provi_ordi,
            mora_provi_ordi=0,
            mora_sdo_cope=mora_sdo_cope + mora_provi_cope,
            mora_provi_cope=0,
            mora_sdo_ordi_pag=mora_sdo_ordi,
            mora_sdo_cope_pag=mora_sdo_cope,
            mora_iva_pagado=mora_iva_debe
--            capital_status=5
        WHERE empresa=o_empresa
        AND num_credito=v_numcredito
        AND capital_status <> 5
        AND fecha_cuota < v_fechatrab4hist ;


		UPDATE sd_maecred
		set tasa_techo=5
		where empresa=o_empresa
		and num_credito=v_numcredito;  

        COMMIT WORK;

    END FOREACH;

 RETURN cCodRet,cMensaje;

END PROCEDURE;