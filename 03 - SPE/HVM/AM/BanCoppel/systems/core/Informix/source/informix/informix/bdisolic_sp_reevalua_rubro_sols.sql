CREATE PROCEDURE "informix".sp_reevalua_rubro_sols(o_empresa CHAR(3), o_numsolicitud  CHAR(20), o_motivo_cc CHAR(100))
RETURNING CHAR(6)   AS cod_ret, 	-- Codigo de Retorno
          CHAR(100) AS mensaje,
          CHAR(1)   AS c_NvoRubro;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                     CHAR(6);
DEFINE sql_err, isam_err            SMALLINT;
DEFINE error_info,cmensaje          CHAR(100);
DEFINE BC_1,BC_117,ki,kiz,BC_119    INTEGER;
DEFINE i,BC_85,BC_93,BC_101, BC_20  INTEGER;
DEFINE pmaxmop,maxmoptot,pmaxmop1   INTEGER;
DEFINE Bandera                      INTEGER;
DEFINE pcadenaaux                   CHAR(30);
DEFINE BC_421, pmeses               DECIMAL(18,2);
DEFINE pfechahoy,pfechaAux          DATE;
DEFINE pnumcte                      CHAR(20);
DEFINE vCambioRubro, ptpsolicitud   CHAR(1);
DEFINE v_nvo_evalua_cc              CHAR(1);
DEFINE vCompromisos                 DECIMAL(14,2);


--SET DEBUG FILE TO "/informix/sp_reevalua_rubro_sols.out";
--TRACE ON;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET scod_ret    = '000000';
LET BC_1        = 0;
LET BC_101      = 0;
LET BC_117      = 0;
LET BC_421      = 0;
LET BC_93       = 0;
LET BC_119      = 0;
LET BC_20       = 0;
LET pmaxmop     = 0;
LET maxmoptot   = 0;
LET pmaxmop1    = 0;
LET ki          = 0;
LET kiz         = 0;
LET pmeses      = 0;
LET pcadenaaux  = "";
LET cmensaje    = "";
LET Bandera     = 0;
LET vCambioRubro= '';
LET v_nvo_evalua_cc = '';
LET vCompromisos= 0;


--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 3;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "sp_reevalua_rubro_sols.err";
      LET scod_ret = sql_err;
      LET cmensaje = error_info;
      LET v_nvo_evalua_cc = '0';
      RETURN scod_ret, cmensaje, v_nvo_evalua_cc;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT fecha_hoy
      INTO pfechahoy
      FROM bdicred:sd_fechas
     WHERE empresa=o_empresa;

    SELECT numcte, tipo_solicitud
      INTO pnumcte, ptpsolicitud
      FROM bdisolic:ss_solicitudes
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud;


    -- *******************************************************************************************
    --                             Obtiene Valores de Variables BC_#                             *
    -- *******************************************************************************************

---BC_1
    SELECT max(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
      INTO BC_1
      FROM bdiburo:br_tl
     WHERE num_cliente=pnumcte;

    IF bc_1 IS NULL THEN LET bc_1 =-1; END IF;

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
            IF  pmaxmop > maxmoptot THEN
                LET maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;

    LET BC_101     = (case when BC_101 = 0 then maxmoptot else BC_101 end);
    LET pmaxmop    = 0;
    LET pmaxmop1   = 0;
    LET pcadenaaux = "";
    LET maxmoptot  = 0;

---BC_117
    FOREACH
        SELECT (case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               (case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),LENGTH(tl27)
          INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 IN ('BANCO','BANCOPPEL','BANCOS') AND tl06='R'
         --GROUP BY 3,4

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
        SELECT (case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               (case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),LENGTH(tl27),(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
          INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1,pmeses
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
          --GROUP BY 3,4

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

        --LET maxmoptot=maxmoptot;
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

    IF pmaxmop is null then let pmaxmop = 0; end if;
    IF pmaxmop1 is null then let pmaxmop1 = 0; end if;

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
            --IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
            IF  pmaxmop > maxmoptot THEN
                LET maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;

    LET BC_93       = (case when maxmoptot = 0 then -1 else maxmoptot end);
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;

    -- *******************************************************************************************
    --                             Reasigna rubro si es No Hit                                   *
    -- *******************************************************************************************

    IF ((BC_1 > 24 AND BC_1 <= 999)    or (BC_101 >= 0 AND BC_101 <= 99) or (BC_117 >= 0 AND BC_117 <= 25)
    or (BC_119 >= 0 AND BC_119 <= 25)  or (BC_20 >= 1 AND BC_20 <= 25)   or (BC_421 >= 0 AND BC_421 <= 30)
    or (BC_85 >= 0 AND BC_85 <= 99)  or (BC_93 >= 1 AND BC_93 <= 99 ))  THEN


        LET v_nvo_evalua_cc = '1';
        LET cmensaje = 'BUEN COMPORTAMIENTO En Buro de Credito';

        -- Prende bandera de que se cambio rubro
        UPDATE bdisolic:ss_revision_determinacion SET reasigna_evalua_cc = '1', evalua_cc_original = 'X', motivo_cc_original = o_motivo_cc
         WHERE num_solicitud = o_numsolicitud;

    ELSE

        LET v_nvo_evalua_cc = '0';
        -- Prende bandera en cero, solo para indicar que paso por el proceso de validacion y no sufrio cambios.
        UPDATE bdisolic:ss_revision_determinacion SET reasigna_evalua_cc = '0' WHERE num_solicitud = o_numsolicitud;

    END IF;

/*
let BC_1 = BC_1;
let BC_101 = BC_101;
let BC_117 = BC_117;
let BC_119 = BC_119;
let BC_20 = BC_20;
let BC_421 = BC_421;
let BC_85 = BC_85;
let BC_93 = BC_93;

BC_1 NE ">= -1 y <=24" ( > 24 y <= 999 )
BC_101 NE "-1 (UR)"   ( >= 0 y <= 99 )
BC_117 NE "-1"   ( >= 0 y <= 25)
BC_119 NE "-1"  ( >= 0 y <= 25 )
BC_20 NE "-1"  ( >= 1 y <= 25 )
BC_421 NE "-1"  (>= 0 y <= 30)
BC_85 NE "-1"  "  (>= 0 y <= 99 )
BC_93 NE ''  ( >= 1 y <= 99 )
*/

END
    RETURN scod_ret, cmensaje, v_nvo_evalua_cc;

END PROCEDURE;