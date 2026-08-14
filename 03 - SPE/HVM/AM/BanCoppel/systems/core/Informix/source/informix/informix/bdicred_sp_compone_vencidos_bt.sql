CREATE PROCEDURE "informix".sp_compone_vencidos_bt(o_empresa char(3))

RETURNING char(6),char(80);


    DEFINE cCodRet                  char(6);
    DEFINE cMensaje                 char(80);
    DEFINE sql_err                  integer;
    DEFINE isam_err                 integer;
    DEFINE cSql                     char(1024);

----variables de cuadre de vencido
    DEFINE v_numcredito             char(20);
    DEFINE v_pagosamortiza          DECIMAL(14,2);
    DEFINE v_fechacuota             DATE;
    DEFINE v_debe_amortiza          DECIMAL(14,2);
    DEFINE v_debe_maesdos           DECIMAL(14,2);
    DEFINE v_debe_pagar             DECIMAL(14,2);
    DEFINE v_fecha_transi           DATE;
    DEFINE v_fecha_transiaux        DATE;
    DEFINE v_fecha_vig              DATE;

--variables de recalculo
    DEFINE v_meses_venci_amort      INTEGER;
    DEFINE v_meses_venci_maes       INTEGER;
    DEFINE v_meses_venci_amort1     INTEGER;
    DEFINE v_recalculo_iva          DECIMAL(14,2);
    DEFINE v_interes                DECIMAL(14,2);
    DEFINE v_factor_mes             DECIMAL(14,6);


--variables recorrido de interes
    DEFINE v_iva_interes            DECIMAL(14,2);

--variables de cuadre de saldos y amortiza
    DEFINE v_saldo_interes          DECIMAL(14,2);
    DEFINE v_int_amortiza_venci     DECIMAL(14,2);
    DEFINE v_int_amortiza           DECIMAL(14,2);
    DEFINE v_interes_cuadre         DECIMAL(14,2);
    DEFINE v_interesaux             DECIMAL(14,2);
    DEFINE v_mto_venc_trasp         DECIMAL(14,2);
    DEFINE v_cap_tras_no_venci      DECIMAL(14,2);             
    DEFINE v_sdo_cap_insoluto       DECIMAL(14,2);
    DEFINE v_monto_vencido          DECIMAL(14,2);
    DEFINE v_sdo_capital            DECIMAL(14,2);
    DEFINE v_sdo_no_exig            DECIMAL(14,2);
    DEFINE v_capitaldebeamor        DECIMAL(14,2);
    DEFINE v_difmontovenci          DECIMAL(14,2);
    DEFINE v_paga_cap_amor          DECIMAL(14,2);
    DEFINE v_sdo_trab4hist          DECIMAL(14,2);
    DEFINE v_mto_venc_trasphist     DECIMAL(14,2);
    DEFINE v_interes_vig            DECIMAL(18,2);

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      ROLLBACK WORK;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

    LET cCodRet = "000000";
    LET cMensaje = "PROCESO EXITOSO";
    LET cSql= "";

    LET v_numcredito = "";
    LET v_debe_amortiza=0;
    LET v_debe_maesdos=0;
    LET v_debe_pagar=0;
    LET v_meses_venci_amort=0;
    LET v_meses_venci_maes=0;
    LET v_meses_venci_amort1=0;
    LET v_recalculo_iva=0;
    LET v_interes=0;
    LET v_fecha_transi=DATE(1);
    LET v_fecha_transiaux=DATE(1);
    LET v_fecha_vig=DATE(1);
    LET v_mto_venc_trasp=0;
    LET v_cap_tras_no_venci=0;             
    LET v_sdo_cap_insoluto=0;
    LET v_monto_vencido=0;
    LET v_sdo_capital=0;
    LET v_sdo_no_exig=0;
    LET v_capitaldebeamor=0;
    LET v_difmontovenci=0;
    LET v_paga_cap_amor=0;
    LET v_sdo_trab4hist=0;
    LET v_mto_venc_trasphist=0;
    LET v_factor_mes=0;
    LET v_saldo_interes=0;
    LET v_interes_vig=0;

    --SET DEBUG FILE TO "/pisa/cas/compone_vencidos_BT.out";
    --TRACE ON;

    FOREACH WITH HOLD 

       SELECT num_credito 
       INTO v_numcredito
       FROM sd_maecred
       WHERE empresa=o_empresa
       AND status_cred='BT'
       AND num_credito in  ('600000131760', '600000248341',  '600000437845',  '600000456654', 
                            '600000500733',  '600000622792',  '600000652948',  '600000775772', 
                            '600000778305',  '600000806411',  '600000863339',  '600001013082', 
                            '600001056115',  '600001114138',  '600001262879',  '600001279709', 
                            '600001296505',  '600001348736',  '600001369716',  '600001518171', 
                            '600001659165',  '600001708582',  '600001785762',  '600001825402', 
                            '600001894820',  '600001973863',  '600002156153',  '600002184742', 
                            '600002190798', '600002214408', '600002265483',  '600002445416', 
                            '600002537709',  '600002591094',  '600002662309',  '600002702303', 
                            '600002795679',  '600003047138',  '600003060743',  '600003149975', 
                            '600003261267',  '600003272868',  '600003425201',  '600003431126', 
                            '600003486484',  '600003540249',  '600003584692',  '600003652358', 
                            '600003811244',  '600003850713',  '600003974240',  '600004077852', 
                            '600004194525',  '600004225071',  '600004229891',  '600004257249', 
                            '600004358757',  '600004448350',  '600004479694',  '600004562648', 
                            '600005166134',  '600005228009',  '600005695561',  '600005716250', 
                            '600005822744',  '600005846420',  '600006252305',  '600006262221', 
                            '600006294729',  '600006396359',  '600006427683',  '600006642034', 
                            '600006684572',  '600006718800',  '600006827999',  '600006886524', 
                            '600007022905',  '600007294660',  '600007331801',  '600007396275', 
                            '600007466359',  '600007553941',  '600007568766',  '600007634949', 
                            '600007885475',  '600007893859',  '600008175967',  '600008366400', 
                            '600008995570')
 --      AND tasa_techo is null 
		
        select max(fecha)
        into v_fecha_transi
        from sd_maesdoshist 
        where empresa=o_empresa
        and num_credito = v_numcredito
        and monto_vencido > 0;

        LET v_fecha_transiaux=DATE(v_fecha_transi - 1 UNITS MONTH);

            select max(fecha)
            into v_fecha_vig
            from sd_maesdoshist 
            where empresa=o_empresa
            and num_credito = v_numcredito;     

   BEGIN WORK;

        UPDATE sd_amortiza_credito
        SET capital_status='5'
        where empresa=o_empresa
        and num_credito = v_numcredito 
        AND fecha_cuota<v_fecha_transiaux;

        UPDATE sd_amortiza_credito
        SET capital_status='2'
        where empresa=o_empresa
        and num_credito = v_numcredito 
        AND fecha_cuota >= v_fecha_transiaux
        and capital_status in ('2','7','5');


--ACTUALIZA FECHAVENCIMIENTO
     --       UPDATE sd_maecredanexo 
     --       SET fecha_vencto=v_fecha_transiaux
     --       WHERE empresa=o_empresa 
      --      AND num_credito=v_numcredito;

--HACE QUE LOS SALDOS EN MAESDOS CUADREN
--cas
                SELECT mto_venc_trasp,cap_tras_no_venci,sdo_cap_insoluto,
                       monto_vencido,sdo_capital,sdo_no_exig
                INTO v_mto_venc_trasp,v_cap_tras_no_venci,v_sdo_cap_insoluto,
                     v_monto_vencido,v_sdo_capital,v_sdo_no_exig 
                FROM sd_maesdos         
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;

                IF v_monto_vencido <> 0 OR v_sdo_capital <> 0 OR v_sdo_no_exig <> 0 THEN
                    UPDATE sd_maesdos 
                    SET monto_vencido=0,sdo_capital=0,
                        sdo_no_exig=0
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito; 
                END IF;

                IF v_mto_venc_trasp > v_sdo_cap_insoluto  and v_sdo_cap_insoluto>0 THEN
                    UPDATE sd_maesdos 
                    SET mto_venc_trasp=v_sdo_cap_insoluto,
                        cap_tras_no_venci=0
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito; 
                END IF;

                IF v_mto_venc_trasp<0 THEN
                   LET v_mto_venc_trasp=0;
                END IF;

                IF (v_mto_venc_trasp + v_cap_tras_no_venci) <> v_sdo_cap_insoluto AND v_sdo_cap_insoluto >= v_mto_venc_trasp    THEN
                    UPDATE sd_maesdos
                    SET  cap_tras_no_venci=sdo_cap_insoluto-mto_venc_trasp
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito;                     
                END IF;

              SELECT sdo_trab4,mto_venc_trasp
              INTO  v_sdo_trab4hist,v_mto_venc_trasphist
              FROM sd_maesdoshist
              WHERE empresa=o_empresa
              AND num_credito=v_numcredito
              AND fecha=v_fecha_vig;

                UPDATE sd_amortiza_credito
                SET capital_mto_cuota = v_sdo_trab4hist - v_mto_venc_trasphist,
                    capital_debe = v_sdo_trab4hist - v_mto_venc_trasphist
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND fecha_cuota=v_fecha_vig;     

                IF v_sdo_cap_insoluto<0 THEN
                    UPDATE sd_maesdos
                    SET  cap_tras_no_venci=0,
                         sdo_capital=v_sdo_cap_insoluto
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito;    
--                        COMMIT WORK;
--                    CONTINUE FOREACH;
                END IF;
---cas

--        IF v_meses_venci_amort > v_meses_venci_maes THEN
--            LET v_fecha_transiaux =v_fecha_transi;
--PAGA EL PRIMER MES
--            UPDATE sd_amortiza_credito 
--            SET capital_pagado=capital_debe,
--            capital_status='5'
--            WHERE empresa=o_empresa
--            AND num_credito=v_numcredito
--            AND fecha_cuota=v_fecha_transi;
--         ELSE
--            LET v_fecha_transiaux =DATE(v_fecha_transi - 1 UNITS MONTH);
--        END IF;

---RECONSTRUYE SALDOS DE AMORTIZA DESDE MAESDOSHIST            
            FOREACH 
                SELECT fecha,monto_financiado-mto_venc_trasp-monto_vencido
                INTO   v_fechacuota,v_pagosamortiza
                FROM sd_maesdoshist 
                WHERE empresa=o_empresa 
                AND num_credito=v_numcredito
                AND fecha >= v_fecha_transiaux

		IF v_pagosamortiza<0 THEN
		   LET v_pagosamortiza=0;
                    UPDATE sd_amortiza_credito 
                    SET capital_mto_cuota=v_pagosamortiza,
                        capital_debe=v_pagosamortiza,
                        capital_pagado=0,
			capital_status=1
                    WHERE empresa=o_empresa 
                    AND num_credito=v_numcredito
                    AND fecha_cuota =v_fechacuota;
		ELSE
                    UPDATE sd_amortiza_credito 
                    SET capital_mto_cuota=v_pagosamortiza,
                        capital_debe=v_pagosamortiza,
                        capital_pagado=0
                    WHERE empresa=o_empresa 
                    AND num_credito=v_numcredito
                    AND fecha_cuota =v_fechacuota;	
		END IF;


          END FOREACH;  
      

--- HACE MACH CON MAESDOS Y RECONOCE LOS PAGOS
          SELECT mto_venc_trasp ,(SELECT SUM(capital_debe-capital_pagado) 
                                    FROM sd_amortiza_credito 
                                    WHERE EMPRESA=o_empresa 
                                    AND NUM_CREDITO=v_numcredito
                                    AND capital_status=2)
          INTO v_debe_maesdos,v_debe_amortiza
          FROM  SD_MAESDOS 
          WHERE EMPRESA=o_empresa
          AND NUM_CREDITO=v_numcredito;

          LET v_debe_pagar=v_debe_amortiza-v_debe_maesdos;


        IF v_debe_pagar>0 THEN --2
   
          FOREACH 

            SELECT fecha_cuota,capital_debe
            INTO v_fechacuota,v_pagosamortiza
            FROM sd_amortiza_credito 
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito
            AND fecha_cuota >= v_fecha_transiaux
            order by fecha_cuota

            LET v_fechacuota=v_fechacuota;
            LET v_pagosamortiza=v_pagosamortiza;

            IF v_debe_pagar>=v_pagosamortiza and v_pagosamortiza>0 and v_debe_pagar>0 THEN

                UPDATE sd_amortiza_credito 
                SET capital_pagado=v_pagosamortiza,
                    capital_status=5
                WHERE empresa=o_empresa 
                AND num_credito=v_numcredito
                AND fecha_cuota = v_fechacuota;

                LET v_debe_pagar=v_debe_pagar-v_pagosamortiza;

            ELSE

                LET v_pagosamortiza=v_debe_pagar;

                UPDATE sd_amortiza_credito 
                SET capital_pagado=v_pagosamortiza
                WHERE empresa=o_empresa 
                AND num_credito=v_numcredito
                AND fecha_cuota = v_fechacuota;

                LET v_debe_pagar=0;

                UPDATE sd_maecredanexo 
                SET fecha_vencto=v_fechacuota
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;

                EXIT FOREACH;

             END IF;    

          END FOREACH;

        ELSE

            LET v_debe_pagar=v_debe_pagar*(-1);
            
            UPDATE sd_amortiza_credito
            SET capital_mto_cuota=capital_mto_cuota+v_debe_pagar,
                capital_debe=capital_debe+v_debe_pagar,
                capital_pagado=0
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito
            AND fecha_cuota = v_fecha_transi;

       END IF;   --2

---RECALCULA EL IVA DEL INTERES
/*{
      FOREACH --1

        SELECT  fecha_cuota,nvl(interes_debe-interes_pagado,0),nvl(iva_debe-iva_pagado,0)
        INTO v_fechacuota,v_interes,v_iva_interes
        FROM sd_amortiza_credito
        WHERE empresa=o_empresa
        AND num_credito=v_numcredito
        and (interes_debe-interes_pagado)> 0
        and (iva_debe-iva_pagado)> 0
--        AND interes_status=3
        ORDER BY fecha_cuota

        IF v_interes IS NULL THEN
            LET v_interes=0;
        END IF;
        IF v_iva_interes IS NULL THEN
            LET v_iva_interes=0;
        END IF;

--???? QUE PASA SI EL IVA DEL INTRES ES MENOR
   --     IF v_interes>0 AND v_iva_interes>0 THEN
            IF v_fechacuota=MDY('01','20','2008') THEN
                LET v_factor_mes=0.135423;
            END IF;

            IF v_fechacuota=MDY('02','20','2008') THEN
                LET v_factor_mes=0.136584;
            END IF;
            
            IF v_fechacuota=MDY('03','20','2008') THEN
                LET v_factor_mes=0.138331;
            END IF;
                
            IF v_fechacuota=MDY('04','20','2008') THEN
                LET v_factor_mes=0.127157;
            END IF;

            IF v_fechacuota=MDY('05','20','2008') THEN
                LET v_factor_mes=0.141591;
            END IF;

            IF v_fechacuota=MDY('06','20','2008') THEN
                LET v_factor_mes=0.15;
            END IF;

            IF v_fechacuota=MDY('07','20','2008') THEN
                LET v_factor_mes=0.137856;
            END IF;

            IF v_fechacuota=MDY('08','20','2008') THEN
                LET v_factor_mes=0.132742;
            END IF;

            IF v_fechacuota=MDY('09','20','2008') THEN
                LET v_factor_mes=0.132955;
            END IF;

            IF v_fechacuota=MDY('10','20','2008') THEN
                LET v_factor_mes=0.129627;
            END IF;

            IF v_fechacuota=MDY('11','20','2008') THEN
                LET v_factor_mes=0.130140;
            END IF;

            LET v_recalculo_iva=v_interes*v_factor_mes;
---ACTUALIZA EL RECALCULO DEL IVA
            UPDATE sd_amortiza_credito 
            SET iva_debe=v_recalculo_iva,
            iva_pagado=0
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=v_fechacuota;
      END FOREACH;
---RECORRE LOS INTERESES QUE EL CLIENTE NO HA PAGADO SI ESTA EN VENCIDO

        select count(*)
        into v_meses_venci_amort1
        from bdicred:sd_amortiza_credito 
        where empresa=o_empresa
        and num_credito = v_numcredito 
        and capital_status in ('2','7');

            IF v_meses_venci_amort1>0 THEN --3
                
                SELECT  SUM(interes_debe-interes_pagado),sum(iva_debe-iva_pagado)
                INTO v_interes,v_iva_interes
                FROM sd_amortiza_credito
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND capital_status=5;
                
                IF v_interes IS NULL THEN
                   LET v_interes=0;
                END IF;
                IF v_iva_interes IS NULL THEN
                   LET v_iva_interes=0;
                END IF;

                SELECT MIN(fecha_cuota) 
                INTO v_fechacuota
                FROM sd_amortiza_credito                
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND capital_status=2;

                IF v_fechacuota IS NOT NULL THEN
                    UPDATE sd_amortiza_credito
                    SET interes_debe=nvl(interes_debe,0)+v_interes,
                    iva_debe=iva_debe+v_iva_interes,
                    interes_status=3
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito
                    AND fecha_cuota=v_fechacuota;

--PAGA LOS INTERESES RECORRIDOS

                    FOREACH 
                        SELECT fecha_cuota
                        INTO v_fechacuota
                        FROM sd_amortiza_credito
                        WHERE empresa=o_empresa
                        AND num_credito=v_numcredito
                        AND capital_status=5
                        order by fecha_cuota
                        
                        UPDATE sd_amortiza_credito
                        SET interes_pagado=nvl(interes_debe,0),
                        iva_pagado=iva_debe,
                        interes_status=5
                        WHERE empresa=o_empresa
                        AND num_credito=v_numcredito
                        AND fecha_cuota=v_fechacuota;
                    END FOREACH;    --1
                        
               END IF;
             END IF;  --3
}*/
--- VERIFICA QUE LOS INTRESES ESTEN IGUALES EN SALDOS Y EN AMORTIZA
        select count(*)
        into v_meses_venci_amort1
        from bdicred:sd_amortiza_credito 
        where empresa=o_empresa
        and num_credito = v_numcredito 
        and capital_status in ('2','7');

             SELECT int_tra_no_exig
             INTO v_saldo_interes
             FROM sd_maesdos
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito;

             SELECT SUM(interes_debe-interes_pagado)
             INTO v_int_amortiza_venci
             FROM sd_amortiza_credito
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito
             AND capital_status=2;        

             SELECT nvl(interes_debe-interes_pagado,0)
             INTO v_int_amortiza
             FROM sd_amortiza_credito
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito
             AND fecha_cuota=v_fecha_vig;

------SI EL DATO DE SALDOS ES MAYOR QUE EL DE AMORTIZA, A AMORTIZA SE LE SUMA LA DIFERENCIA PARA QUE QUEDEN IGUALES

             IF v_int_amortiza_venci+v_int_amortiza < v_saldo_interes THEN --4
                
                LET v_interes_cuadre=v_saldo_interes-v_int_amortiza_venci-v_int_amortiza;

                    SELECT MIN(fecha_cuota)
                    INTO v_fechacuota
                    FROM sd_amortiza_credito 
                    WHERE empresa=o_empresa
                    AND num_credito=v_numcredito
                    AND capital_status=2;
                    
                        UPDATE sd_amortiza_credito
                        SET interes_debe=nvl(interes_debe,0)+v_interes_cuadre
                        WHERE empresa=o_empresa
                        AND num_credito=v_numcredito
                        AND fecha_cuota=v_fechacuota;
                        

             ELIF v_int_amortiza_venci+v_int_amortiza > v_saldo_interes THEN

------SI EL DATO DE SALDOS ES MENOR QUE EL DE AMORTIZA, SE COLOCA EL INETRES DE AMORTIZA EN SALDOS
                
                LET v_interes_cuadre=v_int_amortiza_venci+v_int_amortiza-v_saldo_interes;

                 UPDATE sd_maesdos
                 SET int_tra_no_exig=v_int_amortiza_venci+v_int_amortiza
                 WHERE empresa=o_empresa
                 AND num_credito=v_numcredito;

--                FOREACH 

--                    SELECT fecha_cuota,nvl(interes_debe-interes_pagado,0)
--                    INTO v_fechacuota,v_interesaux
--                    FROM sd_amortiza_credito 
--                    WHERE empresa=o_empresa
--                    AND num_credito=v_numcredito
--                    AND capital_status=2
--                    order by fecha_cuota
                    
--                  IF v_interes_cuadre>0 THEN

--                    IF v_interesaux <= v_interes_cuadre THEN

--                        UPDATE sd_amortiza_credito
--                        SET interes_pagado=interes_pagado+v_interesaux,
--                        interes_status=5
--                        WHERE empresa=o_empresa
--                        AND num_credito=v_numcredito
--                        AND fecha_cuota=v_fechacuota;

 --                       LET v_interes_cuadre=v_interes_cuadre-v_interesaux;
 --                   ELSE

--                        UPDATE sd_amortiza_credito
--                        SET interes_pagado=interes_pagado+v_interes_cuadre
--                        WHERE empresa=o_empresa
--                        AND num_credito=v_numcredito
--                        AND fecha_cuota=v_fechacuota;
                        
 --                       EXIT FOREACH;
                        
 --                   END IF;
 --                 END IF;
  
 --                END FOREACH;    --1
                    
               END IF; --4
                  
--- VERIFICA QUE LOS INTRESES MORATORIOS ESTEN IGUALES EN SALDOS Y EN AMORTIZA

            FOREACH--1

                SELECT fecha_cuota
                INTO v_fechacuota
                FROM sd_amortiza_credito
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND capital_status <> 2
                AND fecha_cuota<>v_fecha_vig

                 UPDATE sd_amortiza_credito
                 SET mora_sdo_ordi=mora_sdo_ordi+mora_provi_ordi,
                 mora_sdo_cope=mora_sdo_cope+mora_provi_cope,
                 mora_provi_ordi=0,mora_provi_cope=0,
                 mora_sdo_ordi_pag=mora_sdo_ordi,
                 mora_sdo_cope_pag=mora_sdo_cope
                 WHERE empresa=o_empresa
                 AND num_credito=v_numcredito
                 AND fecha_cuota=v_fechacuota;

             END FOREACH;  --1  
   
             SELECT SUM(mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)
             INTO v_int_amortiza_venci
             FROM sd_amortiza_credito
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito
             AND capital_status=2;

             SELECT (case when sdo_moratorio<0 then sdo_contab_mora else (sdo_moratorio+sdo_contab_mora) end)
             INTO v_saldo_interes
             FROM sd_maesdos
             WHERE empresa=o_empresa
             AND num_credito=v_numcredito;

             IF v_saldo_interes<0 THEN
                LET v_saldo_interes=0;
             END IF;

             IF v_int_amortiza_venci<0 THEN
                LET v_int_amortiza_venci=0;
                UPDATE sd_amortiza_credito
                SET mora_provi_ordi=0,
                    mora_provi_cope=0,
                    mora_sdo_ordi_pag=mora_sdo_ordi,
                    mora_sdo_cope_pag=mora_sdo_cope
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND capital_status=2;
                LET v_int_amortiza_venci=0;
             END IF;   
             
                        SELECT MIN(fecha_cuota)
                        INTO v_fechacuota
                        FROM sd_amortiza_credito 
                        WHERE empresa=o_empresa
                        AND num_credito=v_numcredito
                        AND capital_status=2;

             IF v_int_amortiza_venci>v_saldo_interes THEN
                UPDATE sd_maesdos
                SET sdo_contab_mora=v_int_amortiza_venci,
                    sdo_moratorio=0
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;
             ELSE
                UPDATE sd_amortiza_credito
                SET mora_sdo_ordi=mora_sdo_ordi+(v_saldo_interes-v_int_amortiza_venci)
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND fecha_cuota=v_fechacuota;    
             END IF;

                  UPDATE sd_maesdos
                SET sdo_moratorio=(case when sdo_moratorio<0 then 0 else sdo_moratorio end)
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;              

---VALIDA QUE EL CREDITO SIGA EN VENCIDO Y VALIDA SUS SALDOS, SI NO LO PASA A VIGENTE
                   UPDATE sd_maecredanexo
                   SET fecha_vencto=v_fechacuota
                   WHERE empresa=o_empresa
                   and num_credito=v_numcredito;

            IF v_sdo_cap_insoluto<=0 or v_meses_venci_amort1=0 THEN  --5
                UPDATE sd_maecred
                SET status_cred='AA'
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;

                select interes_debe-interes_pagado
                into v_interes_vig
                from sd_amortiza_credito 
                where empresa=o_empresa 
                and num_credito=v_numcredito 
                and fecha_cuota=v_fecha_vig; 

                IF v_interes_vig< 0 OR v_interes_vig IS NULL THEN
                    LET v_interes_vig=0;
                END IF;

                UPDATE sd_maesdos
                SET sdo_moratorio=0,
                    sdo_contab_mora=0,
                    dias_acum_mora=0,
                    sdo_capital=sdo_cap_insoluto,
                    monto_vencido=0,
                    mto_venc_trasp=0,
                    cap_tras_no_venci=0,
                    int_tra_no_exig=case when (int_tra_no_exig - v_interes_vig)<0 then 0 
                                    else int_tra_no_exig - v_interes_vig end,
                    sdo_no_exig=v_interes_vig
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;  

                UPDATE sd_amortiza_credito 
                SET mora_sdo_ordi=mora_sdo_ordi + mora_provi_ordi,
                    mora_provi_ordi=0,
                    mora_sdo_cope=mora_sdo_cope + mora_provi_cope,
                    mora_provi_cope=0,
                    mora_sdo_ordi_pag=mora_sdo_ordi,
                    mora_sdo_cope_pag=mora_sdo_cope,
                    mora_iva_pagado=mora_iva_debe--,
                    --capital_status=5
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito
                AND fecha_cuota < v_fecha_vig ;

                   UPDATE sd_maecredanexo
                   SET fecha_vencto=null
                   WHERE empresa=o_empresa
                   and num_credito=v_numcredito; 

            END IF; --5

		UPDATE sd_maecred
		set tasa_techo=7
		where empresa=o_empresa
		and num_credito=v_numcredito;

        COMMIT WORK;   

    END FOREACH;

 RETURN cCodRet,cMensaje;

END PROCEDURE;