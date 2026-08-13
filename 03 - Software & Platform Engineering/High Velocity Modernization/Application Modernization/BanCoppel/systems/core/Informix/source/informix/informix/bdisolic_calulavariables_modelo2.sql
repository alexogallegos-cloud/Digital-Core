CREATE PROCEDURE "informix".calulavariables_modelo2(o_empresa CHAR(3),o_numsolicitud  CHAR(20), o_montotorgado DECIMAL(18,2),o_capacidad_pago DECIMAL(18,2))
RETURNING CHAR(5) AS cod_ret, 	-- Codigo de Retorno
          CHAR(100) AS mensaje;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                             CHAR(5);
DEFINE vsqlerr                              INTEGER;
DEFINE sql_err                              SMALLINT;
DEFINE isam_err                             SMALLINT;
DEFINE error_info,cmensaje                  CHAR(100);
DEFINE BC_1,BC_117,ki,kiz,BC_93,BC_119,BC_20 INTEGER;
DEFINE BC_101,pmaxmop,maxmoptot,pmaxmop1    INTEGER;
DEFINE Bandera, HR0048, UT0034, hr0048_aux  INTEGER;
DEFINE pcadenaaux                           CHAR(30);
DEFINE pmeses,BC_421,CALC_PCT_SALDO_LINEA   DECIMAL(18,2);
DEFINE pfechahoy,pfechaAux                  DATE;
DEFINE CALC_PCT_SALDO_LIMIT                 DECIMAL(18,2);
DEFINE pnumcte                              CHAR(20);
DEFINE ptpsolicitud,pes_coppel,pSIC         CHAR(1);
DEFINE pSituacionPagoCoppel                 DECIMAL(5,2);
DEFINE pmeseshist,ppeso,i,BC_85             INTEGER;
DEFINE pgrupo,pelemento                     SMALLINT;
DEFINE vValorCivil, ut0034_aux, ut0034_aux2 INTEGER;
DEFINE vEstadoCivil                         CHAR(2);
DEFINE westado_civil                        SMALLINT;
DEFINE wtiempo_estado_civil                 SMALLINT;
DEFINE wtiempo_estado_civil_meses           SMALLINT;
DEFINE ESTADO_CIVIL_VAR_INT                 DECIMAL(18,2);
DEFINE MESES_CLIENTE                        DECIMAL(18,2);
DEFINE CALC_PCT_SALDO_LINEA_NUEVO           DECIMAL(18,2);
DEFINE SITUACION_PAGO_NUEVO                 DECIMAL(18,2);
DEFINE vGrupoSol							CHAR(1);
DEFINE vHandiCapCL							DECIMAL (18,2);
DEFINE vVar_Grupo_Sol                       SMALLINT;
DEFINE vOcupacion                           SMALLINT;
DEFINE vElem_TmpOcupacion                   SMALLINT;
DEFINE vTmpOcupacion                        SMALLINT;
DEFINE vVI_Ocup_TmpOcup                     SMALLINT;
DEFINE vSum_bal, vSum_higcred               DECIMAL(18,2);
DEFINE HR0050,hr0050_aux,hr0050_aux2,TR0001,AUX_TR0001	INTEGER;
DEFINE TR0002,IV_TRD_OLDEST_AVERAGE_AGE		INTEGER;
DEFINE RAT_MONTO_OTORGADO_CP				DECIMAL (18,4);
DEFINE v_capacidad_pago						DECIMAL (18,2);
DEFINE IQ0002,IV_OCUP_ESCOL					INTEGER;
DEFINE vEscolaridad							INTEGER;
DEFINE mIngresoMensual						MONEY;
DEFINE VI_INGRESOMENSUAL					SMALLINT;
DEFINE sEdadCte								SMALLINT;
DEFINE sGenero								SMALLINT;
DEFINE VI_Genero_Edad						SMALLINT;
DEFINE VI_Genero_Ocupacion					SMALLINT;
DEFINE VI_EdoCivil_Escolaridad				SMALLINT;
DEFINE VI_Edad_Escolaridad					SMALLINT;
DEFINE iTmpo_Residencia             		SMALLINT;
DEFINE iTipo_Residencia             		SMALLINT;
DEFINE VI_TpResid_TmpResid          		SMALLINT;
DEFINE vClvEdoCob       					VARCHAR(10);
DEFINE vCiudad          					VARCHAR(200);
DEFINE VI_Entidad_Localidad					SMALLINT;
DEFINE cCodret_aux    						CHAR(5);
DEFINE cNomcte  							CHAR(104);



--SET DEBUG FILE TO "/informix/Israel/nuevo_parametrico.out";
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

LET westado_civil        = 0;
LET wtiempo_estado_civil = 0;
LET wtiempo_estado_civil_meses = 0;
LET ESTADO_CIVIL_VAR_INT = 0;
LET MESES_CLIENTE        = 0;
LET CALC_PCT_SALDO_LINEA_NUEVO = 0;
LET SITUACION_PAGO_NUEVO = 0;
LET	vGrupoSol			 = '';
LET vHandiCapCL			 = -1;
LET vVar_Grupo_Sol       = 0;
LET vOcupacion          = 0;
LET vElem_TmpOcupacion  = 0;
LET vTmpOcupacion       = 0;
LET vVI_Ocup_TmpOcup    = 0;
LET HR0048              = 0;
LET UT0034              = 0;
LET hr0048_aux          = 0;
LET ut0034_aux          = 0;
LET ut0034_aux2         = 0;
LET vSum_bal            = 0;
LET vSum_higcred        = 0;

LET BC_85       				= 0;

--------	RecalibraciÃ³n PP
LET HR0050						= 0;
LET hr0050_aux	 				= 0;
LET hr0050_aux2					= 0;
LET TR0001		 				= 0;
LET AUX_TR0001	 				= 0;
LET TR0002		 				= 0;
LET IV_TRD_OLDEST_AVERAGE_AGE	= 0;
LET RAT_MONTO_OTORGADO_CP		= 0;
LET v_capacidad_pago			= 0;
LET IQ0002		 				= 0;
LET IV_OCUP_ESCOL				= 0;
LET vEscolaridad				= 0;
LET mIngresoMensual				= 0;
LET VI_INGRESOMENSUAL			= 0;
LET sEdadCte					= 0;
LET sGenero						= 0;
LET VI_Genero_Edad				= 0;
LET VI_Genero_Ocupacion			= 0;
LET VI_EdoCivil_Escolaridad		= 0;
LET VI_Edad_Escolaridad			= 0;
LET iTmpo_Residencia            = 0;
LET iTipo_Residencia            = 0;
LET VI_TpResid_TmpResid         = 0;
LET vClvEdoCob       			= '';
LET vCiudad          			= '';
LET VI_Entidad_Localidad		= 0;
LET cCodret_aux 				= '';
LET cNomcte  					= '';



--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;


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
           case when nvl(o_montotorgado,0) = 0 then -1 when ((saldoropa + saldomuebles + saldoprestamos)/o_montotorgado)<=0 then 0 else ((saldoropa + saldomuebles + saldoprestamos)/o_montotorgado) end,
		   grupo, ingreso_mensual
      INTO pSituacionPagoCoppel, pmeseshist, pes_coppel, pSIC,
           CALC_PCT_SALDO_LINEA,CALC_PCT_SALDO_LIMIT,
		   vGrupoSol, mIngresoMensual
      FROM bdisolic:ss_resum_scor_fin
     WHERE empresa=o_empresa
       AND num_solicitud=o_numsolicitud;
	   
	SELECT edad INTO sEdadCte FROM bdisolic:ss_revision_determinacion 
	 WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud;
	IF NVL(sEdadCte, 0 ) = 0 THEN
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, pnumcte) INTO cCodret_aux, cNomcte, sEdadCte;
	END IF;

    select nvl(elemento,0)
      into wtiempo_estado_civil
      from bdisolic:ss_detalle_scoring 
     where empresa = o_empresa
       and num_solicitud = o_numsolicitud 
       and seccion = 2
       and grupo = 4
       AND tpo_persona='01';

-- Tiempo, elemento
-- 0 aÃ±os	16
-- 1 aÃ±os	17
-- 2 aÃ±os	18
-- 3 aÃ±os	19
-- 4 aÃ±os	20
-- 5 aÃ±os	21
-- 6 aÃ±os	22
-- 7 aÃ±os	23
-- 8 aÃ±os	24
-- 9 aÃ±os	25
-- 10 aÃ±os	26
-- 11 aÃ±os	27
-- 12 aÃ±os	28
-- 13 aÃ±os	29
-- 14 aÃ±os	30
-- 15 aÃ±os	31
-- 16 aÃ±os	32
-- 17 aÃ±os	33
-- 18 aÃ±os	34
-- 19 aÃ±os	35
-- 20 aÃ±os	36
-- 21 aÃ±os	37
-- 22 aÃ±os	38
-- 23 aÃ±os	39
-- 24 aÃ±os	40
-- 25 aÃ±os	41
-- 26 aÃ±os	42
-- 27 aÃ±os	43
-- 28 aÃ±os	44
-- 29 aÃ±os	45
-- 30 aÃ±os	46
-- 31 aÃ±os	47
-- 32 aÃ±os	48
-- 33 aÃ±os	49
-- 34 aÃ±os	50
-- 35 aÃ±os	51
-- 36 aÃ±os	52
-- 37 aÃ±os	53
-- 38 aÃ±os	54
-- 39 aÃ±os	55
-- 40 aÃ±os	56
-- 41 aÃ±os	57
-- 42 aÃ±os	58
-- 43 aÃ±os	59
-- 44 aÃ±os	60
-- 45 aÃ±os	61
-- 46 aÃ±os	62
-- 47 aÃ±os	63
-- 48 aÃ±os	64
-- 49 aÃ±os	65
-- 50 aÃ±os	66
-- 51 aÃ±os	67
-- 52 aÃ±os	68
-- 53 aÃ±os	69
-- 54 aÃ±os	70
-- 55 aÃ±os	71
-- 56 aÃ±os	72
-- 57 aÃ±os	73
-- 58 aÃ±os	74
-- 59 aÃ±os	75
-- No Aplica 76

    select nvl(elemento,0)
      into wtiempo_estado_civil_meses
      from bdisolic:ss_detalle_scoring 
     where empresa = o_empresa
       and num_solicitud = o_numsolicitud 
       and seccion = 2
       and grupo = 41
       AND tpo_persona='01';

-- Meses, elemento
-- 1	1
-- 2	2
-- 3	3
-- 4	4
-- 5	5
-- 6	6
-- 7	7
-- 8	8
-- 9	9
-- 10	10
-- 11	11
-- -1	12

    -- Asigna tiempo estado civil, en casos cuando meses edo civil = 12 y no tiene grupo asignado para aÃ±os en estado civil 
    -- o esta asignado el elemento 16 que son 0 aÃ±os. (Esta mal asignado tmpo edo civil).
    -- Insertar detalle_scoring del grupo 4, si no existe registro, wtiempo_estado_civil IS NULL y wtiempo_estado_civil_meses = 12 (valor -1)
	IF wtiempo_estado_civil_meses = 12 AND (wtiempo_estado_civil = 0 OR wtiempo_estado_civil IS NULL OR wtiempo_estado_civil = 16) THEN
        IF wtiempo_estado_civil IS NULL THEN -- Si es nulo tiempo estado civil, registrar elemento ya que no tiene asignado ese grupo.
            INSERT INTO bdisolic:ss_detalle_scoring VALUES('001', 2, 4, 17, '01', o_numsolicitud, 0);
        END IF;
        LET wtiempo_estado_civil = 17;
    END IF;

   FOREACH with hold
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

    SELECT estado_civil INTO vEstadoCivil FROM bdinteg:si_ctepf WHERE numcte=pnumcte;

    IF vEstadoCivil IN ('S','D') AND pSIC='X' AND ptpsolicitud <> 'P' THEN

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
IF SUBSTR(o_numsolicitud,1,2) <> '78' THEN
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
        SELECT (case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
               (case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
               TRIM(tl27),LENGTH(tl27)
          INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=pnumcte
           AND tl02 IN ('BANCO','BANCOPPEL','BANCOS') AND tl06='R'
--         GROUP BY 3,4

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
--          GROUP BY 3,4

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
         -- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
            IF  pmaxmop > maxmoptot THEN
                let maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;
end if --validacion anticipo
    LET BC_93       = (case when maxmoptot = 0 then -1 else maxmoptot end);
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;

-- AGREGA VARIABLES INTERACTIVAS

-- (EDO_CIVIL & TIEMPO_ESTADO_CIVIL) - GRUPO 44

    select elemento
      into westado_civil
      from bdisolic:ss_detalle_scoring 
     where empresa = o_empresa
       and num_solicitud = o_numsolicitud 
       and seccion = 2
       and grupo = 3
       AND tpo_persona='01';

-- 1 = SOLTERO
-- 6 = CASADO
-- 7 = UNION LIBRE
-- 8 = DIVORCIDO
-- 9 = VIUDO
	
	IF ptpsolicitud <> 'P' THEN 		-- Tarjeta de Credito

		IF NVL(pSIC,'X') <> 'X' THEN	-- HIT
		
			IF (westado_civil IS NULL) THEN
				LET ESTADO_CIVIL_VAR_INT = -1;
		
			ELIF (westado_civil = 1) THEN 
				LET ESTADO_CIVIL_VAR_INT = 7;
		
			ELIF (westado_civil = 6) THEN 
				IF (wtiempo_estado_civil >= 18 and wtiempo_estado_civil <= 20) then -- Se evaluan primero aÃ±os, para casos que tengan aÃ±os y meses con valores >=1.
					LET ESTADO_CIVIL_VAR_INT = 3;
				ELIF (wtiempo_estado_civil >= 21 and wtiempo_estado_civil <= 25) then
					LET ESTADO_CIVIL_VAR_INT = 4;
				ELIF (wtiempo_estado_civil >= 26 and wtiempo_estado_civil <= 75) then
					LET ESTADO_CIVIL_VAR_INT = 6;
				ELIF ((wtiempo_estado_civil_meses > 0 AND wtiempo_estado_civil_meses < 12) or (wtiempo_estado_civil = 17)) then 
					LET ESTADO_CIVIL_VAR_INT = 2;                                                                                
				ELIF (wtiempo_estado_civil = 16 AND (wtiempo_estado_civil_meses = 0 or wtiempo_estado_civil_meses is null)) then 
					LET ESTADO_CIVIL_VAR_INT = 2;       -- Casos en que aÃ±os = 0 y meses = 0
				ELSE
					LET ESTADO_CIVIL_VAR_INT = -1; 
				END IF;
		
			ELIF (westado_civil = 7) THEN 
				IF (wtiempo_estado_civil >= 21 and wtiempo_estado_civil <= 24) then -- Se evaluan primero aÃ±os, para casos que tengan aÃ±os y meses con valores >=1.
					LET ESTADO_CIVIL_VAR_INT = 2;
				ELIF (wtiempo_estado_civil = 25) then
					LET ESTADO_CIVIL_VAR_INT = 3;
				ELIF (wtiempo_estado_civil >= 26 and wtiempo_estado_civil <= 75) then
					LET ESTADO_CIVIL_VAR_INT = 4;
				ELIF (( wtiempo_estado_civil_meses > 0 AND wtiempo_estado_civil_meses < 12 ) or (wtiempo_estado_civil >= 17 AND wtiempo_estado_civil <= 20)) then
					LET ESTADO_CIVIL_VAR_INT = 1;
				ELIF (wtiempo_estado_civil = 16 AND (wtiempo_estado_civil_meses = 0 or wtiempo_estado_civil_meses is null)) then 
						LET ESTADO_CIVIL_VAR_INT = 1;       -- Casos en que aÃ±os = 0 y meses = 0
				ELSE
					LET ESTADO_CIVIL_VAR_INT = -1; 
				END IF;
		
			ELIF (westado_civil = 8) THEN 
				IF (wtiempo_estado_civil >= 18 and wtiempo_estado_civil <= 20) then -- Se evaluan primero aÃ±os, para casos que tengan aÃ±os y meses con valores >=1.
					LET ESTADO_CIVIL_VAR_INT = 4;
				ELIF (wtiempo_estado_civil >= 21 and wtiempo_estado_civil <= 23) then
					LET ESTADO_CIVIL_VAR_INT = 5;
				ELIF (wtiempo_estado_civil >= 24 and wtiempo_estado_civil <= 75) then
					LET ESTADO_CIVIL_VAR_INT = 6;
				ELIF( (wtiempo_estado_civil_meses > 0 AND wtiempo_estado_civil_meses < 12) or (wtiempo_estado_civil = 17)) then
					LET ESTADO_CIVIL_VAR_INT = 2;
				ELIF (wtiempo_estado_civil = 16 AND (wtiempo_estado_civil_meses = 0 or wtiempo_estado_civil_meses is null)) then 
						LET ESTADO_CIVIL_VAR_INT = 2;       -- Casos en que aÃ±os = 0 y meses = 0
				ELSE
					LET ESTADO_CIVIL_VAR_INT = -1;
				END IF;
		
			ELIF (westado_civil = 9) THEN 
				IF (wtiempo_estado_civil >= 18 and wtiempo_estado_civil <= 75) then -- Se evaluan primero aÃ±os, para casos que tengan aÃ±os y meses con valores >=1.
					LET ESTADO_CIVIL_VAR_INT = 6;
				ELIF ((wtiempo_estado_civil_meses > 0 AND wtiempo_estado_civil_meses < 12) or (wtiempo_estado_civil = 17)) then
					LET ESTADO_CIVIL_VAR_INT = 5;
				ELIF (wtiempo_estado_civil = 16 AND (wtiempo_estado_civil_meses = 0 or wtiempo_estado_civil_meses is null)) then 
						LET ESTADO_CIVIL_VAR_INT = 5;       -- Casos en que aÃ±os = 0 y meses = 0
				ELSE
					LET ESTADO_CIVIL_VAR_INT = -1; 
				END IF;
			ELSE    
				LET ESTADO_CIVIL_Var_Int = -1;
			END IF;

		---- NO HIT		
		ELSE
		
			IF (westado_civil = 6 and wtiempo_estado_civil >= 44) OR (westado_civil = 8 and wtiempo_estado_civil >= 45) OR (westado_civil = 7 and wtiempo_estado_civil >= 52) 
			    OR (westado_civil = 9 and wtiempo_estado_civil >= 54) THEN			-- Casado(a) >= 28 OR Divorciado(a) >= 29 OR UniÃ³n Libre >= 36 OR Viudo(a) >= 38

				LET ESTADO_CIVIL_VAR_INT = 10;
																					-- Casado(a) 11 a 27 OR Divorciado(a) 21 a 28 OR UniÃ³n Libre 29 a 35 OR Viudo(a) 29 a 37
			ELIF (westado_civil = 6 and wtiempo_estado_civil >= 27 and wtiempo_estado_civil <= 43) OR (westado_civil = 8 and wtiempo_estado_civil >= 37 and wtiempo_estado_civil <= 44) 
			    OR (westado_civil = 7 and wtiempo_estado_civil >= 45 and wtiempo_estado_civil <= 51) OR (westado_civil = 9 and wtiempo_estado_civil >= 45 and wtiempo_estado_civil <= 53) THEN
		
				LET ESTADO_CIVIL_VAR_INT = 11;

			ELIF (westado_civil = 6 and wtiempo_estado_civil >= 19 and wtiempo_estado_civil <= 26) OR (westado_civil = 8 and wtiempo_estado_civil >= 27 and wtiempo_estado_civil <= 36) OR 
				 (westado_civil = 7 and wtiempo_estado_civil >= 26 and wtiempo_estado_civil <= 44) OR (westado_civil = 9 and wtiempo_estado_civil >= 38 and wtiempo_estado_civil <= 44) OR 
				 (westado_civil = 1 ) THEN											-- Casado(a) 3 a 10, Divorciado(a) 11  a 20 UniÃ³n Libre 10 a 28 Viudo(a) 22 a 28 Soltero(a)

				LET ESTADO_CIVIL_VAR_INT = 12;

			ELIF (westado_civil = 6 and wtiempo_estado_civil <= 18) OR (westado_civil = 8 and wtiempo_estado_civil <= 26) OR 
				 (westado_civil = 7 and wtiempo_estado_civil <= 25) OR (westado_civil = 9 and wtiempo_estado_civil <= 37) THEN
																					-- Casado(a) <= 2 OR Divorciado(a) <= 10 OR UniÃ³n Libre <= 9 OR Viudo(a) <= 21
				LET ESTADO_CIVIL_VAR_INT = 13;
				
			ELSE
				LET ESTADO_CIVIL_VAR_INT = 14;										-- Missing No Hitt
			END IF;

		END IF

		
	--- Variable (EDO_CIVIL & TIEMPO_ESTADO_CIVIL) - GRUPO 44 - para producto P	(Prestamo Personal)
	ELSE		
	
	    IF (westado_civil IS NULL) THEN
			LET ESTADO_CIVIL_VAR_INT = 8;
		
		ELIF (westado_civil) = 6 THEN			---- CASADO
				
			IF (wtiempo_estado_civil >= 16 and wtiempo_estado_civil <= 28) then		--- DE 0 A 12 Anios
				LET ESTADO_CIVIL_VAR_INT = 1;
			ELIF (wtiempo_estado_civil >= 29 and wtiempo_estado_civil <= 36) then	--- DE 13 A 20 Anios
				LET ESTADO_CIVIL_VAR_INT = 2;
			ELIF (wtiempo_estado_civil >= 37) then 		--- DE 21 +
				LET ESTADO_CIVIL_VAR_INT = 3;
			ELIF (wtiempo_estado_civil = 16 AND (wtiempo_estado_civil_meses = 0 or wtiempo_estado_civil_meses is null)) then 
				LET ESTADO_CIVIL_VAR_INT = 1;       -- Casos en que aÃ±os = 0 y meses = 0	
			END IF;
		ELIF (westado_civil) = 8 THEN			--- Divorciado
				LET ESTADO_CIVIL_VAR_INT = 4;
		ELIF (westado_civil) = 1 THEN			--- Soltero
				LET ESTADO_CIVIL_VAR_INT = 5;
		ELIF (westado_civil) = 7 THEN			--- Union Libre
				LET ESTADO_CIVIL_VAR_INT = 6;
		ELIF (westado_civil) = 9 THEN			--- Viudo
				LET ESTADO_CIVIL_VAR_INT = 7;				
		ELSE
				LET ESTADO_CIVIL_VAR_INT = 8;	
		END IF;
		
	END IF;


-- (MESES_HISTORIA & CLIENTE_NUEVO) - GRUPO 45
    IF (pmeseshist <= 0 and pSituacionPagoCoppel <= 0) THEN
        LET MESES_CLIENTE = -1;
    ELSE
        LET MESES_CLIENTE = pmeseshist;
    END IF;

-- (CALC_PCT_SALDO_LINEA & CLIENTE_NUEVO) - GRUPO 46

    IF (pmeseshist <= 0 and pSituacionPagoCoppel <= 0) THEN
        LET CALC_PCT_SALDO_LINEA_NUEVO = -2;
    ELSE
        LET CALC_PCT_SALDO_LINEA_NUEVO = CALC_PCT_SALDO_LINEA;
    END IF;

-- (SITUACION_PAGO & CLIENTE_NUEVO) - GRUPO 47

    IF (pmeseshist <= 0 and pSituacionPagoCoppel <= 0) THEN
        LET SITUACION_PAGO_NUEVO = -1;
    ELSE
        LET SITUACION_PAGO_NUEVO = pSituacionPagoCoppel;
    END IF;


-- VARIABLE GRUPO ORIGINACION  - GRUPO 49
    -- Obtiene el elemento correspondiente al Grupo asignado a la Solicitud
	IF vGrupoSol = 'A' THEN
		SELECT elemento INTO vVar_Grupo_Sol FROM bdisolic:ss_scoring_element WHERE empresa = '001' AND grupo = 49 
           AND seccion = '2' AND descripcion = vGrupoSol;
	ELSE		
		SELECT elemento INTO vVar_Grupo_Sol FROM bdisolic:ss_parametricos WHERE tipo_parametrico = '2' AND tp_solicitud = ptpsolicitud
           AND grupo = 49 AND vGrupoSol BETWEEN rango_min AND rango_max;
	END IF;

    IF vVar_Grupo_Sol IS NULL THEN	-- Es Missing
		SELECT elemento INTO vVar_Grupo_Sol FROM bdisolic:ss_parametricos WHERE tipo_parametrico = '2' AND tp_solicitud = ptpsolicitud
           AND grupo = 49 AND vGrupoSol BETWEEN 9 AND 99;
    END IF;


-- VARIABLE HR0048 Numero de cuentas abiertas con 12 meses o mas de antigÃ¼edad. Grupo 50
    LET HR0048 = -1;
    LET hr0048_aux = 0;
            /* trim(replace(replace(replace(replace(tl27,'U',''),'X',''),'1',''),'0','')), length(trim(tl27)), tl27, tl26, 
                                       (case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end),tl13,TL30,*  */
IF SUBSTR(o_numsolicitud,1,2) <> '78' THEN   
   SELECT NVL(Count(0),0) INTO HR0048 From (
        SELECT count(*) 
          FROM bdiburo:br_tl a
         WHERE num_cliente = pnumcte
--           AND length(trim(replace(replace(replace(replace(tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
--           AND (case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end) <= 1 -- mop
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 
           AND (((year(pfechahoy) - year(nvl(tl13,pfechahoy)))*12) + (month(pfechahoy) - month(nvl(tl13,pfechahoy)))) >= 12 -- fecha apertura
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
           --AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente) = 'N'-- no fallecido
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );  -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.

    -- Obtiene en caso de que tenga cuenta, pero que no cumplan con la condicion del tiempo.
    SELECT NVL(Count(0),0) INTO hr0048_aux From (
        SELECT count(*)
          FROM bdiburo:br_tl a WHERE num_cliente = pnumcte
           --AND length(trim(replace(replace(replace(replace(tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
           --AND (case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end) <= 1 -- mop
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 		   
           AND (((year(pfechahoy) - year(nvl(tl13,pfechahoy)))*12) + (month(pfechahoy) - month(nvl(tl13,pfechahoy)))) < 12 -- fecha apertura
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
           --AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente) = 'N'-- no fallecido
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );
        -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.
 end if 
	IF HR0048 = 0  AND NVL(pSIC,'X') != 'X' THEN
        LET HR0048 = -999;
    END IF;

    IF HR0048 = 0 AND hr0048_aux >= 1 THEN -- Si tiene cuentas pero no cumplen condicion del tiempo.
        LET HR0048 = -997;
    END IF;

-- VARIABLE: UT0034 Porcentaje de utilizaciÃ³n en cuentas revolventes bancarias. Grupo 51
    LET UT0034 = -999;
    LET ut0034_aux = 0;
    LET vSum_bal  = 0;
    LET vSum_higcred = 0;
IF SUBSTR(o_numsolicitud,1,2) <> '78' THEN
    --SELECT round(((Sum( nvl(tl22,0) )) / (sum((case when tl23 > tl21 then tl23 else tl21 end )))) * 100,0)
    Select Sum(rev_bal), sum(max_cred) INTO vSum_bal, vSum_higcred From (
        SELECT Sum( nvl(tl22,0)) rev_bal, Sum((case when tl23 > tl21 then tl23 else tl21 end )) max_cred
          FROM bdiburo:br_tl a
         WHERE num_cliente = pnumcte
           AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
           --AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente) = 'N' -- no fallecido
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           AND tl06 = 'R'  -- revolvente
           AND ( (SUBSTR(tl01,1,2) IN ('BA','BB','BC','BM','BY')) OR (tl02 IN ('BANCO','BANCOPPEL','BANCOS')) )    -- bandera banco
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );    -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.
    
    IF (vSum_higcred IS NOT NULL) THEN
        IF (vSum_higcred <= 0) THEN
            LET UT0034 = -993;
        ELSE
            LET UT0034 = round((vSum_bal / vSum_higcred) * 100,0);
        END IF;
    END IF;


    SELECT NVL(Count(0),0) INTO ut0034_aux From (           -- Si tiene registros pero no tiene bandera de Cred Revolvente y Banco.
        SELECT Count(*) 
          FROM bdiburo:br_tl a WHERE num_cliente = pnumcte
           AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
           --AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente) = 'N' -- no fallecido
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           AND tl06 != 'R'  -- revolvente
           AND ( (SUBSTR(tl01,1,2) NOT IN ('BA','BB','BC','BM','BY')) OR (tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS')) )          -- bandera banco
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );  

    SELECT NVL(Count(0),0) INTO ut0034_aux2 From (      -- Si tiene registros pero limite de credito = 0
        SELECT Count(*) 
          FROM bdiburo:br_tl a WHERE num_cliente = pnumcte
           AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
           --AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente) = 'N' -- no fallecido
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           AND tl06 = 'R'  -- revolvente
           AND ( (SUBSTR(tl01,1,2) IN ('BA','BB','BC','BM','BY')) OR (tl02 IN ('BANCO','BANCOPPEL','BANCOS')))          -- bandera banco
           AND TL23 = 0
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );
end if 
    IF NVL(UT0034,0) = 0 THEN
        LET UT0034 = -999;
    END IF;

    IF NVL(UT0034,0) = -999 AND ut0034_aux > 0 THEN           -- Si tiene registros pero no tiene bandera de Cred Revolvente y Banco.
        LET UT0034 = -998;
    END IF;

    IF NVL(UT0034,0) = -999 AND ut0034_aux2 > 0 THEN          -- Si tiene registros pero limite de credito = 0
        LET UT0034 = -993;
    END IF

    IF UT0034 IS NULL THEN
        LET UT0034 = 999999; -- Valor "De lo contrario"
    END IF;

-- VI OCUPACION & TIEMPO OCUPACION ACTUAL - GRUPO 52
    LET vVI_Ocup_TmpOcup = -50;

    -- Obtiene los datos del cliente: Ocupacion y Tiempo Ocupacion Actual
    SELECT elemento INTO vOcupacion FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' AND num_solicitud = o_numsolicitud AND grupo = 7;
    SELECT elemento INTO vElem_TmpOcupacion FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and num_solicitud = o_numsolicitud AND grupo = 8;
    -- Obtiene el numero de aÃ±os
    SELECT elem.rango_minimo INTO vTmpOcupacion FROM bdisolic:ss_detalle_scoring det, bdisolic:ss_scoring_element elem
     WHERE det.empresa = elem.empresa and det.num_solicitud = o_numsolicitud AND det.grupo = elem.grupo and det.elemento = elem.elemento AND det.grupo = 8;

    -- Asigna elemento para Estudiante, Ama de Casa, y Pensionado/Jubilado.
    IF vOcupacion = 15 AND vElem_TmpOcupacion = 88 THEN -- Si es estudiante (15) y tiempo = No aplica
        LET vVI_Ocup_TmpOcup = -3;
    ELIF vOcupacion = 12 AND vElem_TmpOcupacion = 88 THEN -- Si es ama de casa (12) y tiempo = No aplica
        LET vVI_Ocup_TmpOcup = -4;
    ELIF vOcupacion = 17 AND vElem_TmpOcupacion = 88 THEN -- Si es Pensionado o Jubilado (17) y tiempo = No aplica
        LET vVI_Ocup_TmpOcup = -5;
    ELIF vElem_TmpOcupacion = 88 THEN -- Si es OTRO y tiempo = No aplica, se asigna No aplica
        LET vVI_Ocup_TmpOcup = -1;
    ELIF vOcupacion IS NULL OR vElem_TmpOcupacion IS NULL THEN -- Si alguno de los datos es nulo, asigna valor: missing
        LET vVI_Ocup_TmpOcup = -2;
    ELSE
        LET vVI_Ocup_TmpOcup = vTmpOcupacion; -- Si no, que se quede con el numero de aÃ±os.
    END IF;

    IF vVI_Ocup_TmpOcup = -50 THEN -- No se asigno valor, se asignarÃ¡ valor missing
        LET vVI_Ocup_TmpOcup = -2;
    END IF;

	
	
-- VARIABLE HR0050 # de cuentas abiertas en los ultimos 6 meses o mas. Grupo 53
    LET HR0050 = -1;
    LET hr0050_aux = 0;

IF SUBSTR(o_numsolicitud,1,2) <> '78' THEN   
   SELECT NVL(Count(0),0) INTO HR0050 From (
        SELECT count(*) 
          FROM bdiburo:br_tl a
         WHERE num_cliente = pnumcte
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0    -- historico de pagos
		   AND months_between (pfechahoy,tl13) >= 6 -- fecha apertura
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );  -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.

	-- Obtiene en caso de que cumpla con variables, pero historial de pagos sea mayor a cero.
     SELECT NVL(Count(0),0) INTO hr0050_aux2 From (
        SELECT count(*)
          FROM bdiburo:br_tl a WHERE num_cliente = pnumcte
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) > 0   -- historico de pagos
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0    -- historico de pagos
		   AND months_between (pfechahoy,tl13) >= 6 -- fecha apertura
                      AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );

    -- Obtiene en caso de que tenga cuenta, pero que no cumplan con la condicion del tiempo.
    SELECT NVL(Count(0),0) INTO hr0050_aux From (
        SELECT count(*)
          FROM bdiburo:br_tl a WHERE num_cliente = pnumcte
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
           AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 
		   AND months_between (pfechahoy,tl13) < 6 -- fecha apertura
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
    );

	
  end if;
  
	IF HR0050 = 0 AND hr0050_aux2 > 0 THEN	-- Hay transaciones pero ninguna es MOP = 1	
		LET HR0050 = 0;
	ELIF HR0050 = 0 AND hr0050_aux = 0 THEN	--	No hay cuentas
        LET HR0050 = -999;
    ELIF HR0050 = 0 AND hr0050_aux > 0 THEN -- Si tiene cuentas pero no cumplen condicion del tiempo > 6.
        LET HR0050 = -997;
    END IF;	

	
	----------------  TR0001 
    LET TR0001 = -999;
    LET AUX_TR0001 = '';

	--- OBTIENE EL MES MAXIMO DE LA CUENTA ABIERTA MAS VIEJA
   SELECT ceil (NVL (MAX (months_between (pfechahoy,tl13)),''))
   INTO TR0001
    From (
        SELECT tl13
          FROM bdiburo:br_tl a
         WHERE num_cliente = pnumcte
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
           AND (tl30 != 'CC' OR tl06 not in ('I','M') and tl22 != 0)		-- ME TRD CLOSED FLAG
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
        );
	--- CONSULTA MESES DE LA CUENTA CERRADA Y SALDADA EXISTENTE
	IF NVL (TR0001,'') = '' THEN
		SELECT NVL (MAX (months_between (pfechahoy,tl13)),'')   
		INTO AUX_TR0001
			From (
				SELECT tl13
				FROM bdiburo:br_tl a
				WHERE num_cliente = pnumcte
				AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
				AND (tl30 = 'CC' OR tl06 in ('I','M') and tl22 = 0)		-- ME TRD CLOSED FLAG
				AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
				GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
				);
	END IF;

	IF NVL (TR0001,'') = '' AND NVL (AUX_TR0001,'') = '' THEN
		LET TR0001 = -999999;
	ELIF NVL (AUX_TR0001,'') != '' THEN
		LET TR0001 = -999996;
	END IF;
	
	---------------- TR0002
	
    LET TR0002 = -999;

	--- OBTIENE EL NUMERO PROMEDIO DE MESES
   SELECT NVL (ROUND (AVG (months_between (pfechahoy,tl13)),0),'')
   INTO TR0002
    From (
        SELECT tl13
          FROM bdiburo:br_tl a
         WHERE num_cliente = pnumcte
           AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
		   AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
           GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
        );
		
	IF NVL (TR0002,'') = '' THEN 
		LET TR0002 = -999999;
	END IF;	
	
	----IV_TRD_OLDEST_AVERAGE_AGE
	
	IF TR0001 = -999999 AND TR0002 = -999999 THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = -999999;
	ELIF TR0001 = -999996 THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = -999996;
	ELIF (TR0001 BETWEEN 0 AND 11) AND (TR0002 BETWEEN 0 AND 7) THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = 1;
	ELIF (TR0001 BETWEEN 0 AND 11) AND (TR0002 BETWEEN 8 AND 13) THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = 2;
	ELIF (TR0001 BETWEEN 0 AND 11) AND (TR0002 >= 14) THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = 3;
	ELIF (TR0001 BETWEEN 0 AND 11) AND TR0002 = -999999 THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = -999;
	ELSE
		IF TR0001 >= 12 THEN
		LET IV_TRD_OLDEST_AVERAGE_AGE = TR0001;
		ELSE
		LET IV_TRD_OLDEST_AVERAGE_AGE = -9999;
		END IF;
	END IF;

	
	---------------- RAT_MONTO_OTORGADO_CP
	---------------- Se pide dividir monto otorgado / capacidad de pago
	IF (o_montotorgado = 0) OR (o_capacidad_pago = 0) THEN
		LET RAT_MONTO_OTORGADO_CP = 0;
	ELSE
		LET RAT_MONTO_OTORGADO_CP = round ((o_montotorgado / o_capacidad_pago),4);
	END IF;

	---------------- IQ0002	

	select NVL (count(0),0) INTO IQ0002 from (
	SELECT SKIP 1 iqiq,iq02						--- INQ SEG TYPE CNT
	FROM bdiburo:br_iq 
	WHERE num_cliente = pnumcte
	and institucion = 'BC'
	and months_between (pfechahoy,iqiq) <= 3	--- ME INQ AGE IN MONTHS
	group by 1,2								--- ME INQ VALID FLAG
	order by 1 desc
	);

	
	---------------- IV_OCUP_ESCOL 
	
	SELECT elemento INTO vEscolaridad FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' AND num_solicitud = o_numsolicitud AND grupo = 21;
	
	IF vOcupacion = 12 AND vEscolaridad = 5 THEN
			LET IV_OCUP_ESCOL = 2;
	ELIF vOcupacion = 12 OR vOcupacion = 15 OR vOcupacion = 17 THEN
			LET IV_OCUP_ESCOL = 1;
	ELIF vOcupacion = 11 THEN
			LET IV_OCUP_ESCOL = 3;
	ELIF vOcupacion IN (16,10,9) THEN
			LET IV_OCUP_ESCOL = 4;
	ELIF vOcupacion = 7 THEN
			LET IV_OCUP_ESCOL = 5;			
	END IF;
	
	----------------  Ingreso Mensual (monto)  Gpo 63

	IF mIngresoMensual IS NULL OR mIngresoMensual < 0 THEN
		LET mIngresoMensual = -1;
	END IF

	---------------- VI Genero & Edad  => Gpo 64			(Edad Cte: En aÃ±os, Genero: Elemento: 3 Mujer, 4 Hombre)
	
	SELECT elemento INTO sGenero FROM bdisolic:ss_detalle_scoring WHERE num_solicitud = o_numsolicitud AND seccion = 2 AND grupo = 2;
	 --WHERE empresa = '001' AND grupo= 2 AND seccion = 2;
	 
	
	IF sGenero = 4 AND sEdadCte <= 23 THEN
		LET VI_Genero_Edad = 1;
	ELIF sGenero = 3 AND sEdadCte <= 23 THEN
		LET VI_Genero_Edad = 2;
	ELIF sGenero = 4 AND sEdadCte >= 24 AND sEdadCte <= 50 THEN
		LET VI_Genero_Edad = 3;
	ELIF (sGenero = 3 AND sEdadCte >= 24 AND sEdadCte <= 35 ) OR (sGenero = 4 AND sEdadCte > 50 ) THEN
		LET VI_Genero_Edad = 4;
	ELIF sGenero = 3 AND sEdadCte >= 36 AND sEdadCte <= 50 THEN
		LET VI_Genero_Edad = 5;
	ELIF sGenero = 3 AND sEdadCte > 50 THEN
		LET VI_Genero_Edad = 6;
	ELSE	
		LET VI_Genero_Edad = 7;
	END IF;	
		
	---------------- VI Genero & Ocupacion  => Gpo 65 		(Genero: Elemento: 3 Mujer, 4 Hombre)
	
	-- Hombre & Ama de casa,Pensionado o Jubilado OR Mujer & Desempleados,Abogado o PolicÃ­a Judicial o Ministerial, Pensionado o Jubilado, Estudiante, Ama de casa
	IF (sGenero = 4 AND vOcupacion IN (12, 17)) OR (sGenero = 3 AND vOcupacion IN(6, 7, 17, 15, 12))  THEN
		LET VI_Genero_Ocupacion = 1;
	-- Mujer & Profesionista independiente, Oficio independiente OR Hombre & Estudiante
	ELIF ((sGenero = 3) AND vOcupacion IN (9, 10)) OR (sGenero = 4 AND vOcupacion IN(15)) THEN
		LET VI_Genero_Ocupacion = 2;
	-- Mujer & Negocio Propio, Empleado OR Hombre & Profesionista independiente
	ELIF (sGenero = 3 AND vOcupacion IN (16, 11)) OR (sGenero = 4 AND vOcupacion IN(9)) THEN
		LET VI_Genero_Ocupacion = 3;
	-- Hombre & Empleado, Oficio Independiente, Negocio Propio, Abogado o PolicÃ­a Judicial o Ministerial
	ELIF (sGenero = 4 AND vOcupacion IN (11, 10, 16, 7)) THEN
		LET VI_Genero_Ocupacion = 4;
	ELSE
		LET VI_Genero_Ocupacion = 5;		-- Missing
	END IF;

	
	---------------- VI Estado Civil & Escolaridad  => Gpo 66
	
	
	--	Casado(a) & Primaria,No EstudiÃ³ OR Viudo(a) & Primaria,No EstudiÃ³, Licenciatura o Superior OR Soltero(a) Licenciatura o Superior
	IF (westado_civil = 6 and vEscolaridad in (2,1)) OR (westado_civil = 9 and vEscolaridad in (2,1,6)) OR (westado_civil = 1 and vEscolaridad in (6)) THEN
		LET VI_EdoCivil_Escolaridad = 1;
	-- Divorciado(a) & No EstudiÃ³ OR Viudo(a) & Preparatoria,Carrera TÃ©cnica,Secundaria OR Casado(a) & Licenciatura o Superior,Carrera TÃ©cnica,Secundaria
	ELIF (westado_civil = 8 and vEscolaridad = 1)  OR (westado_civil = 9 and vEscolaridad in (5,4,3)) OR (westado_civil = 6 and vEscolaridad in (6,4,3)) THEN
		LET VI_EdoCivil_Escolaridad = 2;
	-- Divorciado(a) & Primaria,Carrera TÃ©cnica,Secundaria OR Soltero(a) & Preparatoria,Primaria,No Estudio,Carrera TÃ©cnica OR UniÃ³n Libre & Licenciatura o Superior,No Estudio,Primaria OR Casado(a) & Preparatoria
	ELIF (westado_civil = 8 and vEscolaridad in (2,4,3)) OR (westado_civil = 1 and vEscolaridad in (5,2,1,4)) OR (westado_civil = 7 and vEscolaridad in (6,1,2)) 
	      OR (westado_civil = 6 and vEscolaridad = 5) THEN
		LET VI_EdoCivil_Escolaridad = 3;
	-- UniÃ³n Libre & Preparatoria,Carrera Tecnica,Secundaria OR Divorciado(a) & Preparatoria,Licenciatura o Superior OR Soltero(a) & Secundaria
	ELIF(westado_civil = 7 and vEscolaridad in (5,4,3)) OR (westado_civil = 8 and vEscolaridad in (5,6)) OR (westado_civil = 1 and vEscolaridad = 3) THEN
		LET VI_EdoCivil_Escolaridad = 4;
	ELSE -- Missing
		LET VI_EdoCivil_Escolaridad = 5;
	END IF;	

	---------------- VI Edad & Escolaridad => Gpo 67
	
	IF sEdadCte < 21 AND vEscolaridad IN (1,2,3,4,5) THEN							-- < 21 & No Estudio Primaria,Secundaria, Preparatoria, Carrera Tecnica
		LET VI_Edad_Escolaridad = 1;
	ELIF sEdadCte >= 21 AND sEdadCte <= 28 AND vEscolaridad IN(1,2,3,4,5) THEN		-- 21 a 28 & No Estudio,Primaria,Secund,Preparatoria, Carrera Tecnica
		LET VI_Edad_Escolaridad = 2;
	ELIF (sEdadCte >= 29 and sEdadCte <= 36 and vEscolaridad IN (1,2,3,4)) OR (sEdadCte >= 29 AND sEdadCte <= 51 and vEscolaridad = 5) OR (sEdadCte < 21 and vEscolaridad = 6 ) THEN
		LET VI_Edad_Escolaridad = 3;												-- 29 a 36 & NoEstudio,Primaria,Secund,CarreraTec OR 29 a 51 & Prepa OR < 21 & Lic
	ELIF (sEdadCte >= 37 and sEdadCte <= 51 and vEscolaridad in (1,2,3,4)) OR (sEdadCte >= 52 and vEscolaridad = 5) OR (sEdadCte >= 21 and vEscolaridad = 6) THEN
		LET VI_Edad_Escolaridad = 4;												-- 37 a 51 & NoEstudio,Primaria,Secund,CarreraTec OR >= 52 & Prepa OR >= 21 & Lic
	ELIF (sEdadCte >= 52 and vEscolaridad in (1,2,3,4)) OR (sEdadCte < 21 and NVL(vEscolaridad, '') = '') THEN
		LET VI_Edad_Escolaridad = 5;												-- 52 & No Estudio, Primaria, Secundaria, Carrera Tecnica OR < 21 & ""	
	ELSE
		LET VI_Edad_Escolaridad = 6;												-- Missing
	END IF;
 
 
 	---------------- VI Residencia & Tiempo Residencia => Gpo 60

    SELECT nvl(elemento,0) INTO iTmpo_Residencia FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND grupo = 6;
	SELECT nvl(elemento,0) INTO iTipo_Residencia FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND grupo = 5;

	IF (iTipo_Residencia = 6 and iTmpo_Residencia >= 47) OR (iTipo_Residencia = 7 and iTmpo_Residencia >= 59) OR (iTipo_Residencia = 10 and iTmpo_Residencia >= 52) OR 
	  (iTipo_Residencia = 5 and iTmpo_Residencia >= 35) OR (iTipo_Residencia = 8 and iTmpo_Residencia >= 57) THEN 
	  
		LET VI_TpResid_TmpResid = 2;													-- Hipoteca & >= 31 OR Familiar >= 43 OR Prestada >= 36 OR Propia >= 19 OR Rentada = 41
		
	ELIF (iTipo_Residencia = 6 and iTmpo_Residencia >= 28 and iTmpo_Residencia <= 46) OR (iTipo_Residencia = 7 and iTmpo_Residencia >= 37 and iTmpo_Residencia <= 58) OR 
	(iTipo_Residencia = 10 and iTmpo_Residencia <= 36) OR (iTipo_Residencia = 5 and iTmpo_Residencia <= 34) THEN  

		LET VI_TpResid_TmpResid = 3;													-- Hipoteca & 12 a 30 OR Familiar & 21 a 42 OR Prestada & <= 20 OR Propia <= 18
		
	ELIF (iTipo_Residencia = 6 and iTmpo_Residencia <= 27) OR (iTipo_Residencia = 7 and iTmpo_Residencia <= 36) OR (iTipo_Residencia = 10 and iTmpo_Residencia >= 37 and iTmpo_Residencia <= 51)	OR 
	(iTipo_Residencia = 8 and iTmpo_Residencia <= 56) THEN 			
	
		LET VI_TpResid_TmpResid = 4;													-- Hipoteca & <= 11 OR Familiar <= 20 OR Prestada 21 a 35 OR Rentada <= 40

	ELSE
		
		LET VI_TpResid_TmpResid = 5;													-- Missing
	
	END IF;

	
 	---------------- VI Entidad & Localidad (Clave Edo Cobranza & Municipio) => Gpo 68
	
	SELECT catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, nvl(trim(ciu.nombre),'')
	  INTO vClvEdoCob, vCiudad
	  FROM bdinteg:si_direcciones_actual dir
      LEFT OUTER JOIN bdinteg:si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
	  LEFT OUTER JOIN bdinteg:si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
	 WHERE dir.numcte = pnumcte AND dir.tipo_dir='1';	
	   
	SELECT grupo INTO VI_Entidad_Localidad 
	  FROM bdisolic:ss_cat_edo_localidad_param
	 WHERE clave_estado = vClvEdoCob AND localidad = vCiudad;
	 
	IF NVL(VI_Entidad_Localidad, 0) = 0 THEN
		LET VI_Entidad_Localidad = 6;
	END IF;

	
	---------------- 


    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' 
       and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;

    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' 
       and grupo >= 44 and grupo <= 47 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;
	   
    delete from bdisolic:ss_detalle_modelo where empresa = o_empresa and num_solicitud = o_numsolicitud;

    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' 
       and grupo in (49,50,51,52,53,54,55,56,57,63,64,65,66,67,60,68) and tpo_persona = '01' and  num_solicitud = o_numsolicitud;
	   

    if vGrupoSol = '8' and ptpsolicitud = 'T' then
	  delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' 
         and grupo = 48 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;
	   
	  insert into bdisolic:ss_detalle_scoring
      select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,(case when pSIC='X' THEN peso_no_hit ELSE peso_hit END)
        from ss_parametricos b
       where tipo_parametrico='2'
         and tp_solicitud=ptpsolicitud
         and grupo=48 ;
		 
	  insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'HANDICAP_CLIENTE_LARGO',vHandiCapCL,current,user);	 	  
	end if;   

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
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL',ESTADO_CIVIL_VAR_INT,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'MESES_HISTORIA_&_CLIENTE_NUEVO',MESES_CLIENTE,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'CALC_PCT_SALDO_LINEA_&_CLIENTE_NUEVO',CALC_PCT_SALDO_LINEA_NUEVO,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'SITUACION_PAGO_&_CLIENTE_NUEVO',SITUACION_PAGO_NUEVO,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Grupo Solicitud',vVar_Grupo_Sol,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'OCUPACION_&_TIEMPO_OCUPACION',vVI_Ocup_TmpOcup,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'HR0048',HR0048,current,user);
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'UT0034',UT0034,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'HR0050',HR0050,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'IV_TRD_OLDEST_AVERAGE_AGE',IV_TRD_OLDEST_AVERAGE_AGE,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'RAT_MONTO_OTORGADO_CP',RAT_MONTO_OTORGADO_CP,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Monto_otorgado',o_montotorgado,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Capacidad_de_pago',o_capacidad_pago,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'IQ0002',IQ0002,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'IV_OCUP_ESCOL',IV_OCUP_ESCOL,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Ingreso_Mensual',mIngresoMensual,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Genero_&_Edad',VI_Genero_Edad,current,user);
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Genero_&_Ocupacion',VI_Genero_Ocupacion,current,user);	
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'EdoCivil_&_Escolaridad',VI_EdoCivil_Escolaridad,current,user);		
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Edad&_Escolaridad',VI_Edad_Escolaridad,current,user);			
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Residencia_&_Tpo_Residencia',VI_TpResid_TmpResid,current,user);			
	insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Entidad_&_Localidad',VI_Entidad_Localidad,current,user);				
	   
	   
	   

    insert into bdisolic:ss_detalle_scoring
    select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,(case when pSIC='X' THEN peso_no_hit ELSE peso_hit END)
    from ss_parametricos b
    where tipo_parametrico='2'
      and tp_solicitud=ptpsolicitud
      and ((grupo=26 and BC_1   BETWEEN rango_min AND rango_max)
       or  (grupo=27 and BC_101 BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 6 and 11)
       or  (grupo=28 and BC_117 BETWEEN rango_min AND rango_max)
       or  (grupo=29 and BC_119 BETWEEN rango_min AND rango_max)
       or  (grupo=30 and BC_20  BETWEEN rango_min AND rango_max)
       or  (grupo=31 and BC_421 BETWEEN rango_min AND rango_max)
       or  (grupo=32 and BC_85  BETWEEN rango_min AND rango_max)
       or  (grupo=33 and BC_93  BETWEEN rango_min AND rango_max)
       or  (grupo=34 and CALC_PCT_SALDO_LINEA BETWEEN rango_min AND rango_max)
       or  (grupo=35 and pmeseshist BETWEEN rango_min AND rango_max)
       or  (grupo=36 and pSituacionPagoCoppel BETWEEN rango_min AND rango_max)
       or  (grupo=37 and CALC_PCT_SALDO_LIMIT BETWEEN rango_min AND rango_max)
       or  (grupo=44 and ESTADO_CIVIL_VAR_INT BETWEEN rango_min AND rango_max)
       or  (grupo=45 and MESES_CLIENTE BETWEEN rango_min AND rango_max)
       or  (grupo=46 and CALC_PCT_SALDO_LINEA_NUEVO BETWEEN rango_min AND rango_max)
       or  (grupo=47 and SITUACION_PAGO_NUEVO BETWEEN rango_min AND rango_max)
       or  (grupo=49 and vVar_Grupo_Sol BETWEEN rango_min AND rango_max)
       or  (grupo=50 and HR0048 BETWEEN rango_min AND rango_max)
       or  (grupo=51 and UT0034 BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 15 and 37)
       or  (grupo=52 and vVI_Ocup_TmpOcup BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 16 and 28)
	   or  (grupo=53 and HR0050 BETWEEN rango_min AND rango_max)
	   or  (grupo=54 and IV_TRD_OLDEST_AVERAGE_AGE BETWEEN rango_min AND rango_max) 
	   or  (grupo=55 and RAT_MONTO_OTORGADO_CP BETWEEN rango_min AND rango_max) 
	   or  (grupo=56 and IQ0002 BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 6 and 10) 
	   or  (grupo=57 and IV_OCUP_ESCOL BETWEEN rango_min AND rango_max) 
	   or  (grupo=63 and mIngresoMensual BETWEEN rango_min AND rango_max) 	   
	   or  (grupo=64 and VI_Genero_Edad BETWEEN rango_min AND rango_max) 	   
	   or  (grupo=65 and VI_Genero_Ocupacion BETWEEN rango_min AND rango_max) 	   
	   or  (grupo=66 and VI_EdoCivil_Escolaridad BETWEEN rango_min AND rango_max) 	   	   
	   or  (grupo=67 and VI_Edad_Escolaridad BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 7 and 106) 	   	   
	   or  (grupo=60 and VI_TpResid_TmpResid BETWEEN rango_min AND rango_max AND elemento NOT BETWEEN 6 and 21) 	   	   	   
	   or  (grupo=68 and VI_Entidad_Localidad BETWEEN rango_min AND rango_max) 	   	   	   	   
	   );
	   
	   		   
			

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