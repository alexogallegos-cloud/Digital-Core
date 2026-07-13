CREATE PROCEDURE "informix".calulavariables_modelo2_pba(o_empresa CHAR(3),o_numsolicitud  CHAR(20), o_montotorgado DECIMAL(18,2))
RETURNING CHAR(5) AS cod_ret, 	-- Codigo de Retorno
          CHAR(100) AS mensaje;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                              CHAR(5);
DEFINE vsqlerr                               INTEGER;
DEFINE sql_err                               SMALLINT;
DEFINE isam_err                              SMALLINT;
DEFINE error_info,cmensaje                   CHAR(100);
DEFINE BC_1,BC_117,ki,kiz,BC_93,BC_119,BC_20 INTEGER;
DEFINE BC_101,pmaxmop,maxmoptot,pmaxmop1     INTEGER;
DEFINE Bandera                               INTEGER;
DEFINE pcadenaaux                            CHAR(30);
DEFINE pmeses,BC_421,CALC_PCT_SALDO_LINEA    DECIMAL(18,2);
DEFINE pfechahoy,pfechaAux                   DATE;
DEFINE CALC_PCT_SALDO_LIMIT                  DECIMAL(18,2);
DEFINE pnumcte                               CHAR(20);
DEFINE ptpsolicitud,pes_coppel,pSIC          CHAR(1);
DEFINE pSituacionPagoCoppel                  DECIMAL(5,2);
DEFINE pmeseshist,ppeso,i,BC_85              INTEGER;
DEFINE pgrupo,pelemento                      SMALLINT;
DEFINE vValorCivil                           INTEGER;
DEFINE vEstadoCivil                          CHAR(2);

--SET DEBUG FILE TO "/pisa/cas/nuevo_parametrico.out";
--TRACE ON;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret             = "000";
LET vsqlerr              = 0;
LET BC_1                 = 0;
LET BC_101               = 0;
LET BC_117               = 0;
LET BC_421               = 0;
LET BC_93                = 0;
LET BC_119               = 0;
LET BC_20                = 0;
LET CALC_PCT_SALDO_LINEA = 0;
LET CALC_PCT_SALDO_LIMIT = 0;
LET pmaxmop              = 0;
LET maxmoptot            = 0;
LET pmaxmop1             = 0;
LET ki                   = 0;
LET kiz                  = 0;
LET pmeses               = 0;
LET pcadenaaux           = "";
LET cmensaje             = "";
LET pSIC                 = "";
LET vEstadoCivil         = "";
LET pgrupo               = 0;
LET pelemento            = 0;
LET vValorCivil          = 0;
LET Bandera              = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;
      RETURN scod_ret, cmensaje;
   END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT fecha_hoy
      INTO pfechahoy
      FROM bdicred:sd_fechas
     WHERE empresa=o_empresa;

    SELECT numcte,tipo_solicitud
      INTO pnumcte,ptpsolicitud
      FROM bdisolic:ss_solicitudes
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud;

    SELECT situacion_pago, meses_historia,fuente,evalua_cc,
           case when linea_tienda = 0 then -1 when ((saldoropa + saldomuebles + saldoprestamos)/linea_tienda)<=0 then 0 else ((saldoropa + saldomuebles + saldoprestamos)/linea_tienda) end,
           case when nvl(o_montotorgado,0) = 0 then -1 when ((saldoropa + saldomuebles + saldoprestamos)/o_montotorgado)<=0 then 0 else ((saldoropa + saldomuebles + saldoprestamos)/o_montotorgado) end
      INTO pSituacionPagoCoppel, pmeseshist, pes_coppel, pSIC,
           CALC_PCT_SALDO_LINEA,CALC_PCT_SALDO_LIMIT
      FROM bdisolic:ss_resum_scor_fin
     WHERE empresa=o_empresa
       AND num_solicitud=o_numsolicitud;

  /*  SELECT count(*)
      INTO vexisteCivil
      FROM bdisolic:ss_detalle_scoring
     WHERE empresa=o_empresa
       AND seccion='2'
       AND num_solicitud=o_numsolicitud
       AND grupo=4
       AND elemento>0
       AND tpo_persona='01';
/*
  /*  SELECT estado_civil
      INTO vEstadoCivil
      FROM bdinteg:si_ctepf
     WHERE numcte=pnumcte;

      IF pSIC='X' AND vexisteCivil <= 0 THEN
           INSERT INTO bdisolic:ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor)
           VALUES (o_empresa,2,4,16,'01',o_numsolicitud,0);
      END IF;
*/
   FOREACH
       select (case when pSIC='X' then peso_no_hit else peso_hit end),a.grupo,a.elemento
         into ppeso,pgrupo,pelemento
         from bdisolic:ss_detalle_scoring a,
              ss_parametricos b
        where a.empresa=o_empresa
          and a.seccion='2'
          and a.num_solicitud=o_numsolicitud
          and a.grupo=b.grupo
          and a.elemento=b.elemento
          and a.tpo_persona='01'
          and b.tp_solicitud=ptpsolicitud

         --  BEGIN WORK;
               update bdisolic:ss_detalle_scoring set valor = ppeso
                where empresa=o_empresa
                  and seccion='2'
                  and grupo=pgrupo
                  and elemento=pelemento
                  and tpo_persona='01'
                  and num_solicitud=o_numsolicitud;
         --  COMMIT WORK;
   END FOREACH;

    SELECT estado_civil
      INTO vEstadoCivil
      FROM bdinteg:si_ctepf
     WHERE numcte=pnumcte;

     IF vEstadoCivil IN ('S','D') AND pSIC='X' THEN

        SELECT peso_no_hit
          INTO vValorCivil
          FROM bdisolic:"informix".ss_parametricos
         WHERE tipo_parametrico='1' AND grupo=4 AND elemento=76
           AND tp_solicitud=ptpsolicitud;

        IF vValorCivil IS NULL OR vValorCivil = '' THEN
           LET vValorCivil=0;
        END IF;

        UPDATE bdisolic:ss_detalle_scoring
           SET valor=vValorCivil
        WHERE empresa=o_empresa
          AND seccion='2'
          AND grupo=4
          AND elemento>0
          AND tpo_persona='01'
          AND num_solicitud=o_numsolicitud;
     END IF;

        -- ************************************************************
        -- Lectura de los datos necesarios para calculo variables HIT *
        -- ************************************************************

---BC_1
    SELECT max(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
      INTO BC_1
      FROM bdiburo:br_tl
     WHERE num_cliente=pnumcte;

     IF bc_1 IS NULL THEN LET bc_1 =-1; END IF;


-------ME QUEDE AQUI TAMBIEN DEBE CONSIDERAR LA CADENA DE HISTORICOS
---BC_101
    SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
           MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
      INTO pmaxmop,pmaxmop1
      FROM bdiburo:br_tl WHERE num_cliente=pnumcte
       AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo from bdiburo:br_tltco where status_cons=1);

       IF pmaxmop IS NULL AND pmaxmop1 IS NULL THEN
            LET BC_101      = -1;
            LET pmaxmop     = 0;
            LET pmaxmop1    = 0;
            LET pcadenaaux  = "";
            LET maxmoptot   = 0;
       ELIF pmaxmop IS NULL THEN
            LET pmaxmop     = 0;
       ELIF pmaxmop1 IS NULL THEN
            LET pmaxmop1    = 0;
       END IF;

       IF pmaxmop > pmaxmop1 THEN
          LET maxmoptot = pmaxmop;
       ELSE
          LET maxmoptot = pmaxmop1;
       END IF;

       LET pmaxmop  =0;
       LET pmaxmop1 =0;

    FOREACH
        SELECT TRIM(tl27),LENGTH(tl27)
          INTO pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 IN ('BANCO','BANCOS') AND tl06='I'
           AND tl07 NOT IN (select codigo from bdiburo:br_tltco where status_cons=1)

          LET i = 1;

        WHILE i <= pmaxmop1
            LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::integer END;
         -- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
            IF  pmaxmop > maxmoptot THEN
                let maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;

    LET BC_101      = (case when BC_101 = 0 then maxmoptot else BC_101 end);
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;

---BC_117
    FOREACH
        SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),LENGTH(tl27)
          INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 IN ('BANCO','BANCOPPEL','BANCOS') AND tl06='R'
         GROUP BY 3,4

           LET Bandera = 1;

           IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)))
           OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3))) THEN
               LET ki = ki + 1;
           ELSE
                LET i = 1;

                WHILE i <= pmaxmop1
                    LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
                    IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)) THEN
                        LET ki = ki + 1;
                        LET i = pmaxmop1;
                    END IF;
                    LET i = i + 1;
                END WHILE;
           END IF;
    END FOREACH;

    LET BC_117      = (case when ki=0 and Bandera=0 then -1 else ki end);
    LET ki          = 0;
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;
    LET Bandera     = 0;

---BC_119
    FOREACH
        SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),LENGTH(tl27),max(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
          INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1,pmeses
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
          GROUP BY 3,4

           LET Bandera     = 1;

           IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,3)))
           OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,3))) THEN
               LET ki = ki + 1;
           ELSE
                LET i = 1;

                WHILE i <= pmaxmop1
                    LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
                 -- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
                    IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlphp where status_cons in (1,3)) THEN
                        LET ki = ki + 1;
                        LET i = pmaxmop1;
                    END IF;
                    LET i = i + 1;
                END WHILE;
           END IF;
           IF pmeses <= 12 THEN
               IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)))
               OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3))) THEN
                   LET kiz = kiz + 1;
               ELSE
                    LET i = 1;

                    WHILE i <= pmaxmop1
                        LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
                        IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlphp where status_cons in (1,2,3)) THEN
                            LET kiz = kiz + 1;
                            LET i = pmaxmop1;
                        END IF;
                        LET i = i + 1;
                    END WHILE;
               END IF;
           END IF;
    END FOREACH;

    LET BC_119      = (case when ki=0 and Bandera=0 then -1 else ki end);
    LET BC_20       = (case when kiz=0 and Bandera=0 then -1 else kiz end);
    LET ki          = 0;
    LET kiz         = 0;
    LET pmeses      = 0;
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;
    LET Bandera     = 0;

---BC_421
    SELECT max(iqiq)
      INTO pfechaAux
      FROM bdiburo:br_iq
     WHERE num_cliente = pnumcte
       AND iq02 NOT IN ('BANCOPPEL');

      LET BC_421 = ((year(pfechahoy) - year(nvl(pfechaAux,pfechahoy)))*12) + (month(pfechahoy) - month(nvl(pfechaAux,pfechahoy)));
      LET BC_421 = (case when BC_421=0 then -1 else BC_421 end);
---BC_85

    LET maxmoptot       = -1;

    FOREACH
        SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),(((year(pfechahoy) - year(nvl(tl17,pfechahoy)))*12) + (month(pfechahoy) - month(nvl(tl17,pfechahoy))))--LENGTH(tl27),
          INTO pmaxmop,pmaxmop1,pcadenaaux,pmeses
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
           AND (((year(pfechahoy) - year(nvl(tl17,pfechahoy)))*12) + (month(pfechahoy) - month(nvl(tl17,pfechahoy)))) <= 12
         GROUP BY 3,4

 --          LET maxmoptot=maxmoptot;

           IF maxmoptot > pmaxmop THEN
              LET pmaxmop=maxmoptot;
           END IF;

           IF pmaxmop > pmaxmop1 THEN
              LET maxmoptot = pmaxmop;
           ELSE
              LET maxmoptot=pmaxmop1;
           END IF;
              LET pmaxmop = 0;

                LET i = 1;

                WHILE i <= 12
                    LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
                   IF pmaxmop > maxmoptot THEN
                      LET maxmoptot = pmaxmop;
                   END IF;
                    LET i = i + 1;
                END WHILE;
    END FOREACH;

        SELECT count(*)
          INTO Bandera
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R';

    LET BC_85       = (case when maxmoptot=-1 and Bandera>0 then 0 else maxmoptot end);
    LET pmeses      = 0;
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;

---BC_93
    SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
           MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
      INTO pmaxmop,pmaxmop1
      FROM bdiburo:br_tl WHERE num_cliente=pnumcte;

       IF pmaxmop > pmaxmop1 THEN
          LET maxmoptot = pmaxmop;
       ELSE
          LET maxmoptot = pmaxmop1;
       END IF;
       LET pmaxmop  =0;
       LET pmaxmop1 =0;

    FOREACH
        SELECT nvl(TRIM(tl27),''),nvl(LENGTH(tl27),0)
          INTO pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte

          LET i = 1;

        WHILE i <= pmaxmop1
            LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
         -- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
            IF  pmaxmop > maxmoptot THEN
                let maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;

    LET BC_93       = (case when maxmoptot = 0 then -1 else maxmoptot end);
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;

    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' 
       and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;

    delete from bdisolic:ss_detalle_modelo where empresa = o_empresa and num_solicitud = o_numsolicitud;

    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_1',BC_1,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_101',BC_101,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_117',BC_117,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_119',BC_119,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_20',BC_20,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_421',BC_421,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_85',BC_85,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_93',BC_93,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'CALC_PCT_SALDO_LINEA',CALC_PCT_SALDO_LINEA,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'PMESESHIST',pmeseshist,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'PSITUACIONPAGOCOPPEL',pSituacionPagoCoppel,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'CALC_PCT_SALDO_LIMIT',CALC_PCT_SALDO_LIMIT,current,user);

    insert into bdisolic:ss_detalle_scoring
    select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,(case when pSIC='X' THEN peso_no_hit ELSE peso_hit END)
    from ss_parametricos b
    where tipo_parametrico='2'
      and tp_solicitud=ptpsolicitud
      and ((grupo=26 and BC_1 BETWEEN rango_min AND rango_max)
       or  (grupo=27 and BC_101 BETWEEN rango_min AND rango_max)
       or  (grupo=28 and BC_117 BETWEEN rango_min AND rango_max)
       or  (grupo=29 and BC_119 BETWEEN rango_min AND rango_max)
       or  (grupo=30 and BC_20 BETWEEN rango_min AND rango_max)
       or  (grupo=31 and BC_421 BETWEEN rango_min AND rango_max)
       or  (grupo=32 and BC_85 BETWEEN rango_min AND rango_max)
       or  (grupo=33 and BC_93 BETWEEN rango_min AND rango_max)
       or  (grupo=34 and CALC_PCT_SALDO_LINEA BETWEEN rango_min AND rango_max)
       or  (grupo=35 and pmeseshist BETWEEN rango_min AND rango_max)
       or  (grupo=36 and pSituacionPagoCoppel BETWEEN rango_min AND rango_max)
       or  (grupo=37 and CALC_PCT_SALDO_LIMIT BETWEEN rango_min AND rango_max));
/*
let BC_1 = BC_1;
let BC_101 = BC_101;
let BC_117 = BC_117;
let BC_119 = BC_119;
let BC_20 = BC_20;
let BC_421 = BC_421;
let BC_85 = BC_85;
let BC_93 = BC_93;
let CALC_PCT_SALDO_LINEA = CALC_PCT_SALDO_LINEA;
let pmeseshist = pmeseshist;
let pSituacionPagoCoppel = pSituacionPagoCoppel;
let CALC_PCT_SALDO_LIMIT = CALC_PCT_SALDO_LIMIT;
*/
END
    RETURN scod_ret, cmensaje;

END PROCEDURE;