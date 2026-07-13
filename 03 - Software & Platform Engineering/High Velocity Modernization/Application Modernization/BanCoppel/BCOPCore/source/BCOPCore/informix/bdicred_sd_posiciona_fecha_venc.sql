CREATE PROCEDURE "informix".sd_posiciona_fecha_venc(o_empresa char(3))

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
    DEFINE vpagos           integer;


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
    let vpagos = 0;

 -- SET DEBUG FILE TO "compone_vencidos.out";
 -- TRACE ON;

    FOREACH WITH HOLD
        select num_credito
        INTO v_numcredito
        from bdicred:sd_maecred
        where status_cred = 'BT'

        let vpagos = 0;

        select nvl(count(*),0) 
           into vpagos
          from sd_amortiza_credito 
         WHERE empresa=o_empresa 
           AND num_credito=v_numcredito
           and capital_status in ('2','7');

           let v_fechacuota = null;

           if (vpagos = 1) then
              let v_fechacuota = mdy('09','20','2008');
           end if;
           if (vpagos = 2) then
              let v_fechacuota = mdy('08','20','2008');
           end if;
           if (vpagos = 3) then
              let v_fechacuota = mdy('07','20','2008');
           end if;
           if (vpagos = 4) then
              let v_fechacuota = mdy('06','20','2008');
           end if;
           if (vpagos = 5) then
              let v_fechacuota = mdy('05','20','2008');
           end if;
           if (vpagos = 6) then
              let v_fechacuota = mdy('04','20','2008');
           end if;
           if (vpagos = 7) then
              let v_fechacuota = mdy('03','20','2008');
           end if;
           if (vpagos = 8) then
              let v_fechacuota = mdy('02','20','2008');
           end if;
           if (vpagos = 9) then
              let v_fechacuota = mdy('01','20','2008');
           end if;
           if (vpagos = 10) then
              let v_fechacuota = mdy('12','20','2007');
           end if;
           if (vpagos = 11) then
              let v_fechacuota = mdy('11','20','2007');
           end if;
           if (vpagos = 12) then
              let v_fechacuota = mdy('10','20','2007');
           end if;
           if (vpagos = 13) then
              let v_fechacuota = mdy('09','20','2007');
           end if;
           if (vpagos = 14) then
              let v_fechacuota = mdy('08','20','2007');
           end if;


        BEGIN WORK;

            UPDATE sd_maecredanexo 
            SET fecha_vencto=v_fechacuota
            WHERE empresa=o_empresa
            AND num_credito=v_numcredito;

      
        COMMIT WORK;


    END FOREACH  

 RETURN cCodRet,cMensaje;

END PROCEDURE;