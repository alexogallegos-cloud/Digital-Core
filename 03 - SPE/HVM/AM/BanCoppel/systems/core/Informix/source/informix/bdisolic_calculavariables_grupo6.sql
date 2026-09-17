CREATE PROCEDURE "informix".calculavariables_grupo6(o_empresa CHAR(3),o_numsolicitud  CHAR(20))
RETURNING CHAR(5) AS cod_ret, 	-- Codigo de Retorno
          CHAR(100) AS mensaje;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE scod_ret                     CHAR(5);
DEFINE vsqlerr                      INTEGER;
DEFINE sql_err                      SMALLINT;
DEFINE isam_err                     SMALLINT;
DEFINE error_info,cmensaje          CHAR(100);
DEFINE pnumcte                      CHAR(20);
DEFINE ptpsolicitud                 CHAR(1);
DEFINE vMesesTransIQ                integer;
DEFINE vNombreRegion                char(30);
DEFINE vNumeroRegion                smallint;
DEFINE pgrupo,pelemento             SMALLINT;
DEFINE ppeso                        DECIMAL(10,4);
DEFINE vEstadoCivil                 CHAR(2);
DEFINE vExisteGrupo4                CHAR(1);
DEFINE vPesoElemento41              DECIMAL(10,4);
DEFINE iTpIngreso                   INTEGER; 
DEFINE iTipo_Residencia             SMALLINT;
DEFINE iResid_EdoCivil              SMALLINT;
DEFINE iTmpo_Residencia             SMALLINT;
DEFINE TpResid_TmpResid             SMALLINT;
DEFINE iSexo                        SMALLINT;
DEFINE iSexo_EdoCivil               SMALLINT;
DEFINE iSexo_TpoResidenc            SMALLINT; 
DEFINE pmaxmop, maxmoptot, pmaxmop1 INTEGER;
DEFINE pcadenaaux                   CHAR(30);
DEFINE BC_93                        INTEGER;
DEFINE sTmp_EdoCivil                SMALLINT;
DEFINE sTmp_EdoCivil_meses          SMALLINT;
--DEFINE sTmp_EdoCivil_meses          SMALLINT;
DEFINE iVI_EdoCivil_TmpEdoCiv, i    INTEGER;
DEFINE westado_civil                SMALLINT;

--SET DEBUG FILE TO "/pisa/cas/nuevo_parametrico.out";
--TRACE ON;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret             = "000";
LET vsqlerr              = 0;
LET pnumcte              = "";
LET ptpsolicitud         = "";
LET vMesesTransIQ        = 0;
LET vNombreRegion        = "";
LET vNumeroRegion        = 0;
LET pgrupo               = 0;
LET pelemento            = 0;
LET ppeso                = 0;
LET cmensaje             = ""; --FMJ
LET vEstadoCivil         = "";
LET vExisteGrupo4        = "F";
LET vPesoElemento41      = 0;
LET iTpIngreso           = 0;
LET iTipo_Residencia     = 0;
LET iResid_EdoCivil      = 0;
LET iTmpo_Residencia     = 0;
LET TpResid_TmpResid     = 0;
LET iSexo                = 0;
LET iSexo_EdoCivil       = 0;
LET iSexo_TpoResidenc    = 0;
LET pmaxmop              = 0;
LET maxmoptot            = 0;
LET pmaxmop1             = 0;
LET pcadenaaux           = '';
LET BC_93                = 0;
LET sTmp_EdoCivil        = 0;
LET sTmp_EdoCivil_meses  = 0;
LET iVI_EdoCivil_TmpEdoCiv = 0;
LET westado_civil          = 0; 

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "calculavariables_grupo6.err";
      LET scod_ret = sql_err;
      RETURN scod_ret, cmensaje;
   END EXCEPTION;



-- SET DEBUG FILE TO "/INFORMIXDUMP/calculavariables.out";
 --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT numcte,tipo_solicitud
      INTO pnumcte,ptpsolicitud
      FROM bdisolic:ss_solicitudes
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud;


--  BORRA EN CASO DE REPROCESO
    delete from bdisolic:ss_detalle_scoring_rechazo where empresa = o_empresa and num_solicitud = o_numsolicitud;
    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' and grupo in (42,43) and tpo_persona = '01' and  num_solicitud = o_numsolicitud;
    -- borra nuevas variables
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo in (58,59,60,61,62) AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;

-- RESPALDA DATOS REFERENTES A LA EVALUACION DEL PRIMER PARAMETRICO

    insert into bdisolic:ss_detalle_scoring_rechazo
    select empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor, current
      from bdisolic:ss_detalle_scoring
     where empresa = o_empresa
       and num_solicitud = o_numsolicitud;

--- Obtiene la informacion de Estado Civil
    SELECT estado_civil INTO vEstadoCivil
      FROM bdinteg:si_ctepf WHERE numcte = pnumcte;

    SELECT elemento INTO westado_civil
      FROM bdisolic:ss_detalle_scoring 
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud 
       AND seccion = 2
       AND grupo = 3
       AND tpo_persona = '01';

-- ASIGNA NUEVOS PESOS A LAS VARIABLES

   FOREACH
       select peso_grupo6,a.grupo,a.elemento
         into ppeso      ,pgrupo ,pelemento
         from bdisolic:ss_detalle_scoring a,
              bdisolic:ss_parametricos b
        where a.empresa=o_empresa
          and a.seccion='2'
          and a.num_solicitud=o_numsolicitud
          and a.grupo=b.grupo
          and a.elemento=b.elemento
          and a.tpo_persona='01'
          and b.tp_solicitud=ptpsolicitud

      IF (pgrupo =41)  THEN
        let vPesoElemento41 = ppeso;        
        let ppeso = 0;
      END IF;
      IF (pgrupo =4)  THEN        
        let vExisteGrupo4 = 'V';
      END IF;

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
   IF vExisteGrupo4 = 'F' THEN     
     update bdisolic:ss_detalle_scoring set valor = vPesoElemento41
                where empresa=o_empresa
                  and seccion='2'
                  and grupo=41                  
                  and tpo_persona='01'
                  and num_solicitud=o_numsolicitud;
   END IF;

-- VARIABLE REGION COBRANZA (DIRECCION DEL CLIENTE)

    select nombre_region, b.numero_region
      into vNombreRegion ,vNumeroRegion 
      from bdinteg:si_direcciones_actual a,
           bdinteg:si_catciudades b,
           bdinteg:si_regiones c
     where numcte = pnumcte
       and tipo_dir = 1
       and a.numerociudad = b.numerociudad
       and b.numero_region = c.numero_region;
  
  if nvl(vNumeroRegion,0 )=0 then
    let vNombreRegion = 'MISSING'; 
  end if;

    -- INSERTA ELEMENTO 42  - Region Cobranza 

    insert into bdisolic:ss_detalle_scoring
    select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,peso_grupo6
    from bdisolic:ss_parametricos a
    where tipo_parametrico='2'
      and tp_solicitud = ptpsolicitud
      and grupo = 42
      and elemento = (select elemento from bdisolic:ss_scoring_element
                       where seccion = 2
                         and a.grupo = grupo
                         and descripcion = vNombreRegion);


-- VARIABLE MESES ULTIMA CONSULTA (SEGMENTO IQ)

    select (year(today) - year(max(iqiq))) * 12 + (month(today) - month(max(iqiq))) --, max(iqiq) 
      into vMesesTransIQ 
      from bdiburo:br_iq 
     where num_cliente = pnumcte 
       and iq02 <> 'BANCOPPEL';

    if ( vMesesTransIQ is null ) then
        let vMesesTransIQ = -1;
    end if;

    delete from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' and grupo = 43 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;

    delete from bdisolic:ss_detalle_modelo where empresa = o_empresa and num_solicitud = o_numsolicitud and variable = 'MESES_ULTIMA_CONSULTA';
    insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'MESES_ULTIMA_CONSULTA',vMesesTransIQ,current,user);

    -- INSERTA GRUPO 43
    insert into bdisolic:ss_detalle_scoring
    select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,peso_grupo6
    from ss_parametricos b
    where tipo_parametrico='2'
      and tp_solicitud=ptpsolicitud
      and grupo=43 
      and vMesesTransIQ BETWEEN rango_min AND rango_max;


-- VARIABLE: Periodicidad Ingreso - Gpo 58
    -- bdinteg:si_periodo_ingreso: 1.- Diario  /   2.- Semanal /   3.- Quincenal   /   4.- Mensual
    SELECT tp_ingreso INTO iTpIngreso           -- Obtiene el tipo de ingreso
      FROM bdisolic:ss_resum_scor_fin 
     WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 58 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'PERIODICIDAD_INGRESO';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'PERIODICIDAD_INGRESO', iTpIngreso, CURRENT, USER);

    -- Genera registro con puntaje --     
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa, '2', grupo, elemento, '01', o_numsolicitud, peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico = '2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 58
       AND iTpIngreso BETWEEN rango_min AND rango_max;


-- VARIABLE: Tipo de Residencia & Estado Civil - Grupo 59
    --  1 = SOLTERO / 6 = CASADO /   7 = UNION LIBRE / 8 = DIVORCIDO /9 = VIUDO      -- westado_civil
    --  Gpo 5 Elem 5 -  Propia     /    Gpo 5 Elem 7 -  De Familiar

    SELECT nvl(elemento,0) INTO iTipo_Residencia
      FROM bdisolic:ss_detalle_scoring
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud
       AND grupo = 5;

    IF iTipo_Residencia = 7 AND westado_civil = 7 THEN    -- Gpo 5 Elem 7 -  De Familiar    --  Familiar - UniÃ³n Libre	-0.1643
        LET iResid_EdoCivil = 1;
    ELIF iTipo_Residencia = 5  AND westado_civil = 6 THEN -- Gpo 5 Elem 5 -  Propia       --  Propia - Casado	0.0417
        LET iResid_EdoCivil = 2;
    ELSE
        LET iResid_EdoCivil = 3;
    END IF;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 59 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'TIPO_RESIDENCIA_&_EDOCIVIL';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'TIPO_RESIDENCIA_&_EDOCIVIL', iResid_EdoCivil, CURRENT, USER);

    -- Genera registro con puntaje --     
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa, '2', grupo, elemento, '01', o_numsolicitud, peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico = '2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 59
       AND iResid_EdoCivil BETWEEN rango_min AND rango_max;


-- VARIABLE: Tipo de Residencia / Tiempo Residencia - Grupo 60
    --  Gpo 5 Elem 5 -  Propia     /    Gpo 5 Elem 7 -  De Familiar
    --  Elem: 18 = 2 aÃ±os  / Elem: 41 = 25 aÃ±os   

    SELECT nvl(elemento,0) INTO iTmpo_Residencia
      FROM bdisolic:ss_detalle_scoring
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud
       AND grupo = 6;

    IF iTipo_Residencia = 7 AND iTmpo_Residencia <= 18 THEN           -- Familiar / Hasta 2 aÃ±os	-0.2414
        LET TpResid_TmpResid = 1;
    ELIF iTipo_Residencia = 5 AND iTmpo_Residencia > 41 THEN         -- Propia - Mas de 25 aÃ±os	0.0935
        LET TpResid_TmpResid = 2;
    ELSE
        LET TpResid_TmpResid = 3;
    END IF;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 60 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'TIPO_RESIDENCIA_&_TMPO_RESIDENCIA';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'TIPO_RESIDENCIA_&_TMPO_RESIDENCIA', TpResid_TmpResid, CURRENT, USER);

    -- Genera registro con puntaje --     
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa, '2', grupo, elemento, '01', o_numsolicitud, peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico = '2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 60
       AND TpResid_TmpResid BETWEEN rango_min AND rango_max;

-- VARIABLE: Sexo / Estado Civil    => Gpo 61
    --  1 = SOLTERO / 6 = CASADO /   7 = UNION LIBRE / 8 = DIVORCIDO /9 = VIUDO      -- westado_civil
    --  Gpo 2 Elem 3 - Mujer / Elem 4 - Hombre

    SELECT nvl(elemento,0) INTO iSexo
      FROM bdisolic:ss_detalle_scoring
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud
       AND grupo = 2;

    IF iSexo = 4 AND westado_civil = 1 THEN        -- Hombre / Soltero	-0.3935
        LET iSexo_EdoCivil = 1;
    ELIF iSexo = 3 AND westado_civil = 6 THEN      -- Mujer / Casada	0.0824
        LET iSexo_EdoCivil = 2;
    ELSE
        LET iSexo_EdoCivil = 3;
    END IF;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 61 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'SEXO_&_EDO_CIVIL';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'SEXO_&_EDO_CIVIL', iSexo_EdoCivil, CURRENT, USER);

    -- Genera registro con puntaje -- 
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa, '2', grupo, elemento, '01', o_numsolicitud, peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico = '2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 61
       AND iSexo_EdoCivil BETWEEN rango_min AND rango_max;

-- VARIABLE: Sexo / Tipo Residencia     => Gpo 62
    --  Gpo 2 Elem 3 - Mujer    / Elem 4 - Hombre
    --  Gpo 5 Elem 5 -  Propia     /    Gpo 5 Elem 7 -  De Familiar

    IF iSexo = 4 AND iTipo_Residencia = 7 THEN      --  Hombre - Familiar	-0.1418
        LET iSexo_TpoResidenc = 1;
    ELIF iSexo = 3 AND iTipo_Residencia = 5 THEN    --  Mujer - Propia	0.2705
        LET iSexo_TpoResidenc = 2;
    ELSE
        LET iSexo_TpoResidenc = 3;
    END IF;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 62 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'SEXO_&_TIPO_RESIDENCIA';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'SEXO_&_TIPO_RESIDENCIA', iSexo_TpoResidenc, CURRENT, USER);

    -- Genera registro con puntaje --     
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa, '2', grupo, elemento, '01', o_numsolicitud, peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico = '2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 62
       AND iSexo_TpoResidenc BETWEEN rango_min AND rango_max;


--  VARIABLE     BC_93    => Gpo 33

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

    LET BC_93       = (case when maxmoptot = 0 then -1 else maxmoptot end);
    LET pmaxmop     = 0;    LET pmaxmop1    = 0;    LET pcadenaaux  = "";   LET maxmoptot   = 0;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 33 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'BC_93';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'BC_93', BC_93, CURRENT, USER);

    -- INSERTA GRUPO 33
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa,'2',grupo,elemento,'01',o_numsolicitud,peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico='2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 33 
       AND BC_93 BETWEEN rango_min AND rango_max;


--  VARIABLE:   Estado Civil / Tiempo Estado Civil => Gpo 44
    --  1 = SOLTERO / 6 = CASADO /   7 = UNION LIBRE / 8 = DIVORCIDO /9 = VIUDO      -- westado_civil
    -- Gpo: 4, Elem: 28  = 12 aÃ±os / Gpo: 4, Elem: 22 = 6 aÃ±os  ////    Gpo 41 Meses.  Elem 1-12

    SELECT nvl(elemento,0) INTO sTmp_EdoCivil
      FROM bdisolic:ss_detalle_scoring 
     WHERE empresa = o_empresa  AND num_solicitud = o_numsolicitud 
       AND seccion = 2          AND grupo = 4
       AND tpo_persona='01';

    SELECT nvl(elemento,0) INTO sTmp_EdoCivil_meses 
      FROM bdisolic:ss_detalle_scoring 
     WHERE empresa = o_empresa  AND num_solicitud = o_numsolicitud 
       AND seccion = 2          AND grupo = 41
       AND tpo_persona = '01';

    IF westado_civil = 6 AND sTmp_EdoCivil > 28 THEN                                       --  Casado (a) - MÃ¡s de 12 aÃ±os	0.3381
        LET iVI_EdoCivil_TmpEdoCiv = 8;
    ELIF westado_civil = 7 AND ( sTmp_EdoCivil <= 22 or (sTmp_EdoCivil = 16 and sTmp_EdoCivil_meses > 0) ) THEN     --  UniÃ³n Libre - Hasta 6 aÃ±os	-0.3302
        LET iVI_EdoCivil_TmpEdoCiv = 9;
    ELSE
        LET iVI_EdoCivil_TmpEdoCiv = -1;
    END IF;

    --  Borre registros previos por reproceso
    DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND seccion = '2' AND grupo = 44 AND tpo_persona = '01' AND num_solicitud = o_numsolicitud;
    DELETE FROM bdisolic:ss_detalle_modelo WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND variable = 'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL';
    INSERT INTO bdisolic:ss_detalle_modelo VALUES(o_empresa, o_numsolicitud, 'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL', iVI_EdoCivil_TmpEdoCiv, CURRENT, USER);

    -- INSERTA GRUPO 44
    INSERT INTO bdisolic:ss_detalle_scoring
    SELECT o_empresa,'2',grupo,elemento,'01',o_numsolicitud,peso_grupo6
      FROM ss_parametricos b
     WHERE tipo_parametrico='2'
       AND tp_solicitud = ptpsolicitud
       AND grupo = 44
       AND iVI_EdoCivil_TmpEdoCiv BETWEEN rango_min AND rango_max;


END
RETURN scod_ret, cmensaje;

END PROCEDURE;