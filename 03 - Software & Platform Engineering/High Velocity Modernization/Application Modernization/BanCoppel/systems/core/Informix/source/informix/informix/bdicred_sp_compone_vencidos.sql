CREATE PROCEDURE "informix".sp_compone_vencidos(o_empresa char(3))

RETURNING char(6),char(80);


    DEFINE cCodRet char(6);
    DEFINE cMensaje char(80);
    DEFINE sql_err integer;
    DEFINE isam_err integer;
    DEFINE cSql char(1024);

    DEFINE v_numcredito     char(20);
    DEFINE v_fechavencido   DATE;
    DEFINE v_capitaldebe1   DECIMAL(14,2);
    DEFINE v_pagosamortiza  DECIMAL(14,2);
    DEFINE v_fechacuota     DATE;
    DEFINE v_debe_amortiza  DECIMAL(14,2);
    DEFINE v_debe_maesdos   DECIMAL(14,2);
    DEFINE v_debe_pagar     DECIMAL(14,2);


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
    LET v_fechavencido=DATE(1);
    LET v_capitaldebe1=0;
    LET v_debe_amortiza=0;
    LET v_debe_maesdos=0;
    LET v_debe_pagar=0;

 -- SET DEBUG FILE TO "compone_vencidos.out";
 -- TRACE ON;

    FOREACH WITH HOLD
        select num_credito, max(fecha)
        INTO v_numcredito,v_fechavencido
        from bdicred:sd_maesdoshist a
        where a.empresa = o_empresa
        and a.monto_vencido > 0
        and
        (
        select count(*) 
        from bdicred:sd_amortiza_credito 
        where empresa=o_empresa
        and a.empresa = empresa 
        and a.num_credito = num_credito 
        and capital_status in ('2','7')
        ) = 6
        group by 1 

        IF v_fechavencido=mdy('06','20','2008') THEN
            BEGIN WORK;
--ACTUALIZA FECHAVENCIMIENTO

            UPDATE sd_maecredanexo 
            SET fecha_vencto=v_fechavencido
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito;

--PAGA EL PRIMER MES

            UPDATE sd_amortiza_credito 
            SET capital_pagado=capital_debe,
            capital_status='5'
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito
            AND fecha_cuota=mdy('04','20','2008');


---RECONSTRUYE SALDOS DE AMORTIZA DESDE MAESDOSHIST
          FOREACH

            SELECT fecha,monto_financiado-mto_venc_trasp-monto_vencido
            INTO   v_fechacuota,v_pagosamortiza
            FROM sd_maesdoshist 
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito
            AND fecha > MDY('04','20','2008')

            UPDATE sd_amortiza_credito 
            SET capital_mto_cuota=v_pagosamortiza,
            capital_debe=v_pagosamortiza,
            capital_pagado=0
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito
            AND fecha_cuota =v_fechacuota;
           
          END FOREACH;   

--- HACE MACH CON MAESDOS Y RECONOCE LOS PAGOS

          SELECT mto_venc_trasp ,(SELECT SUM(capital_debe) 
                                    FROM SD_AMORTIZA_CREDITO 
                                    WHERE EMPRESA=o_empresa 
                                    AND NUM_CREDITO=v_numcredito
                                    AND capital_status=2)
          INTO v_debe_maesdos,v_debe_amortiza
          FROM  SD_MAESDOS 
          WHERE EMPRESA=o_empresa
          AND NUM_CREDITO=v_numcredito;

          LET v_debe_pagar=v_debe_amortiza-v_debe_maesdos;


        IF v_debe_pagar>0 THEN
          
          FOREACH 

            SELECT fecha_cuota,capital_debe
            INTO v_fechacuota,v_pagosamortiza
            FROM sd_amortiza_credito 
            WHERE empresa=o_empresa 
            AND num_credito=v_numcredito
            AND fecha_cuota > MDY('04','20','2008')
            order by fecha_cuota

            LET v_fechacuota=v_fechacuota;
            LET v_pagosamortiza=v_pagosamortiza;

            IF v_debe_pagar>v_pagosamortiza THEN

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
                SET fecha_vencto=DATE(v_fechacuota + 1 UNITS MONTH)
                WHERE empresa=o_empresa
                AND num_credito=v_numcredito;

                EXIT FOREACH;

             END IF;

          END FOREACH;

        END IF;
      
        COMMIT WORK;

        END IF;     

    END FOREACH  

 RETURN cCodRet,cMensaje;

END PROCEDURE;