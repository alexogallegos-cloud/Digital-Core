CREATE PROCEDURE "informix".sp_actualiza_numpago(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet          char(6);
    DEFINE cMensaje         char(80);
    DEFINE cBegin           CHAR(1);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE cnumcredito      char(20);
    DEFINE ccontador        integer;
    DEFINE vfecha_cuota     date;
    DEFINE cDifCap          decimal(14,2);
    DEFINE cStatus          char(1);
    DEFINE cstatuscred      char(2);
    DEFINE Ccodigofun       char(3);
    DEFINE Ccodigoref       integer;
    DEFINE dtFechaHoy       DATE;
    DEFINE cSucursal        CHAR(4);
    DEFINE cDivisa          CHAR(2);
    DEFINE cCapInsoluto     decimal(18,2);
    DEFINE cCapTransito     decimal(18,2);
    DEFINE cCapVigente      decimal(18,2);
    DEFINE cCapVencExig     decimal(18,2);
    DEFINE cCapVencNoExig   decimal(18,2);
    DEFINE cMontoAjuste7    decimal(18,2);
    DEFINE cMontoAjuste2    decimal(18,2);
    DEFINE cContadorVen     integer;
    DEFINE cFechaCuotaAux   date;
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
          IF  cBegin = 'S' THEN
              ROLLBACK WORK;
          END IF;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET ccontador=0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000000';
   LET cDifCap=0;
   LET cStatus="";
   LET Ccodigofun="";
   LET Ccodigoref=0;
   LET cBegin ="";
   LET cSucursal="";
   LET cDivisa ="";
   LET cCapInsoluto=0;
   LET cCapTransito=0;
   LET cCapVigente=0;
   LET cCapVencExig=0;
   LET cCapVencNoExig=0;
   LET cMontoAjuste7=0;
   LET cMontoAjuste2=0;
   LET cContadorVen=0;
   LET cFechaCuotaAux=date(1);

   SELECT fecha_hoy
     INTO dtFechaHoy
     FROM sd_fechas
    WHERE empresa =pEmpresa; 

--SET DEBUG FILE TO "/pisa/cas/sp_actualiza_numpago.out";
--TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;
   FOREACH WITH HOLD 
        select num_credito 
          into cnumcredito
          from bdicred:sd_maecredcrd 
         where empresa=pEmpresa 
           and num_producto='6011'

           LET ccontador=0;

       FOREACH WITH HOLD
            select fecha_cuota
              into vfecha_cuota 
              from bdicred:sd_amortiza_creditocrd 
             where empresa=pEmpresa
               and num_credito=cnumcredito
            order by fecha_cuota

               BEGIN WORK;
                 LET ccontador=ccontador + 1;
                 UPDATE bdicred:sd_amortiza_creditocrd
                    SET num_pago=ccontador
                 WHERE empresa=pEmpresa
                   AND num_credito=cnumcredito
                   AND fecha_cuota=vfecha_cuota;
               COMMIT WORK;

       END FOREACH;
   END FOREACH;


   FOREACH WITH HOLD 
   
   select num_credito,sdo_cap_insoluto,monto_vencido,mto_venc_trasp,cap_tras_no_venci,sdo_capital
     into cnumcredito,cCapInsoluto,cCapTransito,cCapVencExig,cCapVencNoExig,cCapVigente
     from bdicred:sd_maesdoscrd 
    where empresa=pEmpresa
      and num_credito in (select num_credito from bdicred:sd_maecredcrd where num_producto='6011')
      and num_credito not in ('610013078098','610013098104','610013800764','610014004291','610016451391','610017133493',
                                '610017393188','610019463807','610013080706','610013140518','610013405770','610014348086',
                              '610013053786')
       LET cMontoAjuste7=0;
       LET cMontoAjuste2=0;
       LET cContadorVen=0;

      IF (cCapInsoluto=cCapVencExig and cCapVencExig>0) or cnumcredito in ('610013346511','610013602558','610013710484',
         '610013805243','610013826165','610013862681','610013893017','610013912874','610014174227','610014672857',
         '610014971689','610015038215','610015087410') THEN

           select max(fecha_cuota) 
             into cFechaCuotaAux
             from bdicred:sd_amortiza_creditocrd
            where empresa=pEmpresa
              and num_credito=cnumcredito
              and fecha_cuota<mdy('01','01','2100');

           FOREACH WITH HOLD
                select fecha_cuota,num_credito, (capital_mto_cuota - (capital_debe-capital_pagado) - (interes_debe-interes_pagado) - (iva_debe-iva_pagado)),
                       capital_status,num_pago,
                       (select sucursal from bdicred:sd_maecredcrd where empresa=a.empresa and num_credito=a.num_credito)sucursal,
                       (select divisa from bdicred:sd_maecredcrd where empresa=a.empresa and num_credito=a.num_credito)divisa                   
                  into vfecha_cuota, cnumcredito,cDifCap,cStatus,ccontador,cSucursal, cDivisa
                  from bdicred:sd_amortiza_creditocrd  a
                 where a.empresa=pEmpresa
                   and a.num_credito=cnumcredito
                ---   and a.num_credito <> '610013078098'
                   and a.fecha_cuota <> cFechaCuotaAux
                   and a.capital_status in ('2','7')
                   and (capital_mto_cuota - (capital_debe-capital_pagado) - (interes_debe-interes_pagado) - (iva_debe-iva_pagado))<> 0
                   order by 3 desc

                   IF cDifCap <> 0 THEN
                       BEGIN WORK;
                       LET cBegin = 'S';
                            IF cStatus='7' AND cDifCap>0 THEN
                               LET cMontoAjuste7=cMontoAjuste7+cDifCap;
                            ELIF cStatus='7' AND cDifCap<0 THEN
                               LET cMontoAjuste7=cMontoAjuste7+cDifCap;
                            ELIF cStatus='2' AND cDifCap>0 THEN
                               LET cMontoAjuste2=cMontoAjuste2+cDifCap;
                            ELIF cStatus='2' AND cDifCap<0 THEN
                               LET cMontoAjuste2=cMontoAjuste2+cDifCap;
                            ELSE
                                LET cCodRet='000001';
                                LET cMensaje='Capital status incorrecto '||trim(cnumcredito)||' '||vfecha_cuota;
                                ROLLBACK WORK;
                                LET cBegin = 'N';
                                RETURN cCodRet,cMensaje;
                            END IF;

                             UPDATE bdicred:sd_amortiza_creditocrd
                                SET capital_debe=capital_debe+cDifCap
                             WHERE empresa=pEmpresa
                               AND num_credito=cnumcredito
                               AND fecha_cuota=vfecha_cuota;
                            LET cDifCap=0;
                            LET Ccodigofun="";
                            LET Ccodigoref=0;
                            LET cStatus="";
                       COMMIT WORK;
                   END IF;
           END FOREACH;


           IF cMontoAjuste7<> 0 THEN
              IF cMontoAjuste7>0 THEN
                 UPDATE bdicred:sd_amortiza_creditocrd
                   SET capital_debe=capital_debe-cMontoAjuste7,
                       capital_mto_cuota=capital_mto_cuota-cMontoAjuste7
                  WHERE empresa=pEmpresa
                    AND num_credito=cnumcredito
                    AND fecha_cuota=cFechaCuotaAux;
              END IF;
              IF cMontoAjuste7<0 THEN
                 LET cMontoAjuste7=cMontoAjuste7*(-1);
                  -- Traspaso capital vigente a transitorio.
                 UPDATE bdicred:sd_amortiza_creditocrd
                   SET capital_debe=capital_debe+cMontoAjuste7,
                       capital_mto_cuota=capital_mto_cuota+cMontoAjuste7
                  WHERE empresa=pEmpresa
                    AND num_credito=cnumcredito
                    AND fecha_cuota=cFechaCuotaAux;
              END IF;

           ELIF cMontoAjuste2<> 0 THEN
              IF cMontoAjuste2>0 THEN
                 UPDATE bdicred:sd_amortiza_creditocrd
                   SET capital_debe=capital_debe - cMontoAjuste2,
                       capital_mto_cuota=capital_mto_cuota-cMontoAjuste2
                  WHERE empresa=pEmpresa
                    AND num_credito=cnumcredito
                    AND fecha_cuota=cFechaCuotaAux;
              END IF;
              IF cMontoAjuste2<0 THEN
                 LET cMontoAjuste2=cMontoAjuste2*(-1);
                  -- Traspaso capital vigente a transitorio.
                 UPDATE bdicred:sd_amortiza_creditocrd
                   SET capital_debe=capital_debe+cMontoAjuste2,
                       capital_mto_cuota=capital_mto_cuota+cMontoAjuste2
                  WHERE empresa=pEmpresa
                    AND num_credito=cnumcredito
                    AND fecha_cuota=cFechaCuotaAux;  
              END IF;
           END IF;

      ELSE

           FOREACH WITH HOLD
                select fecha_cuota,num_credito, (capital_mto_cuota - (capital_debe-capital_pagado) - (interes_debe-interes_pagado) - (iva_debe-iva_pagado)),
                       capital_status,num_pago,
                       (select sucursal from bdicred:sd_maecredcrd where empresa=a.empresa and num_credito=a.num_credito)sucursal,
                       (select divisa from bdicred:sd_maecredcrd where empresa=a.empresa and num_credito=a.num_credito)divisa                   
                  into vfecha_cuota, cnumcredito,cDifCap,cStatus,ccontador,cSucursal, cDivisa
                  from bdicred:sd_amortiza_creditocrd  a
                 where a.empresa=pEmpresa
                   and a.num_credito=cnumcredito
                ---   and a.num_credito <> '610013078098'
                   and a.capital_status in ('2','7')
                   and (capital_mto_cuota - (capital_debe-capital_pagado) - (interes_debe-interes_pagado) - (iva_debe-iva_pagado))<> 0

                   IF cDifCap <> 0 THEN
                       BEGIN WORK;
                       LET cBegin = 'S';
                            IF cStatus='7' AND cDifCap>0 THEN
                               LET Ccodigofun="602";
                               LET Ccodigoref=3;
                            ELIF cStatus='7' AND cDifCap<0 THEN
                               LET Ccodigofun="601";
                               LET Ccodigoref=6;
                            ELIF cStatus='2' AND cDifCap>0 THEN
                               LET Ccodigofun="601";
                               LET Ccodigoref=4;
                            ELIF cStatus='2' AND cDifCap<0 THEN
                               LET Ccodigofun="601";
                               LET Ccodigoref=7;
                            ELSE
                                LET cCodRet='000001';
                                LET cMensaje='Capital status incorrecto '||trim(cnumcredito)||' '||vfecha_cuota;
                                ROLLBACK WORK;
                                LET cBegin = 'N';
                                RETURN cCodRet,cMensaje;
                            END IF;

                          -- Traspaso capital vigente a transitorio.
                            CALL "informix".genmovcrd(pEmpresa,cnumcredito, '6011' , Ccodigoref, 
                                    Ccodigofun, dtFechaHoy, (CASE WHEN cDifCap<0 THEN cDifCap*(-1) ELSE cDifCap END) , 'trasp'||ccontador||trim(cnumcredito), 
                                    cSucursal, cDivisa, "0000",'M'||ccontador,'')
                            RETURNING cCodRet,cMensaje;

                                IF (cCodRet <> "000000") THEN
                                       LET cCodRet      = "000014";
                                       LET cMensaje = 'Ocurrió un error al registrar traspaso capital'||trim(cnumcredito)||' '||vfecha_cuota;
                                          ROLLBACK WORK;
                                       LET cBegin = 'N';
                                       RETURN cCodRet,cMensaje;    
                                END IF;

                             UPDATE bdicred:sd_amortiza_creditocrd
                                SET capital_debe=capital_debe+cDifCap
                             WHERE empresa=pEmpresa
                               AND num_credito=cnumcredito
                               AND fecha_cuota=vfecha_cuota;

                            IF cStatus='7' THEN
                                UPDATE bdicred:sd_maesdoscrd
                                   SET sdo_capital      = sdo_capital - cDifCap,
                                       monto_vencido    = monto_vencido + cDifCap,
                                       monto_financiado = monto_financiado + cDifCap
                                 WHERE empresa=pEmpresa
                                   AND num_credito=cnumcredito;     
                            ELIF cStatus='2' THEN
                                UPDATE bdicred:sd_maesdoscrd
                                   SET cap_tras_no_venci = cap_tras_no_venci - cDifCap,
                                       mto_venc_trasp    = mto_venc_trasp + cDifCap,
                                       monto_financiado = monto_financiado + cDifCap
                                 WHERE empresa=pEmpresa
                                   AND num_credito=cnumcredito;   
                            END IF;

                            LET cDifCap=0;
                            LET Ccodigofun="";
                            LET Ccodigoref=0;
                            LET cStatus="";
                       COMMIT WORK;
                   END IF;
           END FOREACH;
      END IF;

   END FOREACH;

  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;