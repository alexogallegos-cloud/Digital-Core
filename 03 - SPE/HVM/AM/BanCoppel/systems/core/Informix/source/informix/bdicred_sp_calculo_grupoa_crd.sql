CREATE PROCEDURE "informix".sp_calculo_grupoa_crd (pcEmpresa CHAR(3), p_numproducto CHAR(4))
    RETURNING CHAR(5)  AS Codigo_retorno,
              CHAR(80) AS Mensaje,
              CHAR(25) AS StorePro;

DEFINE vsqlerr              INTEGER;
DEFINE v_codigo_retorno     CHAR(5);
DEFINE v_mensaje            CHAR(80);
DEFINE v_store_pro          CHAR(25);

DEFINE dtFechaHoy           DATE;
DEFINE dtFechaProx          DATE;
DEFINE dtFechaFinMes        DATE;
DEFINE dtFechaCortePrev     DATE;
DEFINE dtFecha1MesAnt       DATE;

DEFINE vc_crdcontproc       CHAR(1);
DEFINE vc_intcontproc       CHAR(1);

DEFINE vc_numproducto       CHAR (4);
DEFINE vc_numcredito        CHAR(20);
DEFINE vc_numcte            CHAR(20);
DEFINE vc_statuscred        CHAR(2);
DEFINE vd_motorgado         DECIMAL(18,2);
DEFINE vd_cap_insoluto      DECIMAL(18,2);
DEFINE vi_porcentaje_uso    INTEGER;
DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
DEFINE vf_ult_fecha_fac     DATE;
DEFINE vc_tipoproceso       CHAR(20);
DEFINE vf_fechapertu        DATE;
--DEFINE vi_meses_antigdad    INTEGER;
--DEFINE ren_empresa  CHAR(3);
--DEFINE ren_producto CHAR(4);
--DEFINE ren_credito  CHAR(20);
DEFINE vf_vig_fecha_fac     DATE;
DEFINE vi_meses_vigts       INTEGER;

LET vc_numproducto    ='';
LET vc_numcredito     ='';
LET vc_numcte         ='';
LET vc_statuscred     ='';
LET vd_motorgado      = 0;
LET vd_cap_insoluto   = 0;
LET vi_porcentaje_uso = 0;
LET vd_capital_insol  = 0;
LET vd_mto_fin_ven_trasp = 0;
LET vf_ult_fecha_fac  = DATE(1);
LET vc_tipoproceso    = '';
LET vf_fechapertu     = DATE(1);
--LET vi_meses_antigdad = 0;
LET vf_vig_fecha_fac  = DATE(1);
LET dtFechaCortePrev  = DATE(1);
LET dtFecha1MesAnt    = DATE(1);
--LET ren_empresa = '';
--LET ren_producto ='';
--LET ren_credito ='';
LET vi_meses_vigts    = 0;
LET v_codigo_retorno  = "00000";
LET v_mensaje         = "Proceso Inicia Correctamente";
LET v_store_pro       = 'sp_calculo_grupoa_crd';
LET vc_tipoproceso    = 'CalculoGpoAPP_' || TRIM (p_numproducto); 
--LET vc_tipoproceso   = 'FiltroGpo6_' || TRIM (p_numproducto);

--SET DEBUG FILE TO "/informix/mahr/sp_calculo_grupoa_crd_" ||p_numproducto|| ".out";
--TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_store_pro = 'sp_calculo_grupoa_crd';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
        END IF;
    END EXCEPTION;


    --******************************************************************************--
	-- Creado por: Francisco Martinez Viveros
	--Fecha Creacion: 05/JUNIO/2012 Fecha Modifica: 02/OCTUBRE/2012 / 31/ENERO/2013
	--Objetivo: Valida Clientes que son candidatos al Grupo 6 "A", por tener buen comportamiento de Creditos a Plazo
    --******************************************************************************--

    IF (p_numproducto <> '6300' AND p_numproducto  <> '7600' AND p_numproducto  <> '7700' AND p_numproducto  <> '6400') THEN
        LET v_codigo_retorno = "00035";
        LET v_mensaje="NO. DE PRODUCTO INVALIDO PARA EJECUTAR EN EL SP, VERIFIQUE!";
        LET v_store_pro = 'sp_calculo_grupoa_crd';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
     END IF;

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = pcEmpresa;

    SELECT valor::integer INTO vi_meses_vigts
      FROM "informix".sd_param WHERE empresa = pcEmpresa AND cod_param = '55';
    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_calculo_grupoa_crd';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc
     WHERE empresa = pcEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPO A, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_calculo_grupoa_crd';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = pcEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc IS NULL) THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
               VALUES (pcEmpresa,vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF (vc_crdcontproc IS NULL) THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
               VALUES (pcEmpresa,vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos Grupo6');
    END IF;
    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = pcEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = pcEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    END IF;

    -- OBtiene fecha de corte previa.
    --LET dtFechaCortePrev = mdy(month(dtFechaHoy -1 UNITS MONTH), day(dtFechaHoy),year(dtFechaHoy));
    LET dtFechaCortePrev = dtFechaHoy - 1 units day; -- Analiza creditos que cortaron un dia antes, y su respaldo ya se encuentra en maesdoshit. GpoA corre en inicio de dia.
    LET vf_vig_fecha_fac = monthadd(dtFechaCortePrev,- vi_meses_vigts);

    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0), c.fecha_proceso
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu,  vc_statuscred, vd_motorgado, vd_cap_insoluto, vf_ult_fecha_fac
          FROM bdicred:"informix".sd_maecredcrd a,
               bdicred:"informix".sd_maesdoshistcrd b, ---max
               bdicred:"informix".sd_maecredanexocrd c,
			   bdicred:"informix".sd_maesdoscrd d 
         WHERE a.empresa = pcEmpresa
           AND a.empresa = b.empresa
           AND a.empresa = c.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = c.num_credito
		   AND a.num_credito = d.num_credito
           AND c.dia_corte = day(dtFechaCortePrev)
           AND b.fecha = dtFechaCortePrev
           AND a.status_cred in ('AA','E1')
		   AND (d.monto_vencido + d.mto_venc_trasp) = 0
           AND a.num_producto = p_numproducto
           AND a.fecha_apertura <= vf_vig_fecha_fac

        LET vi_porcentaje_uso = round(((vd_cap_insoluto * 100) / vd_motorgado),2);

        SELECT NVL(SUM(mto_fin_ven_trasp),0)
          INTO vd_mto_fin_ven_trasp
          FROM bdicred:"informix".sd_maesdoshistcrd
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev
           AND empresa = pcEmpresa AND num_credito = vc_numcredito;
                     
        IF NOT EXISTS (SELECT num_credito FROM bdicred:sd_grupo_credito WHERE empresa = pcEmpresa AND numcte = vc_numcte AND num_credito = vc_numcredito) 
           AND vd_mto_fin_ven_trasp <= 0 THEN
            --IF vd_mto_fin_ven_trasp <= 0  THEN                  -- No haya tenido vencidos en el mes anterior.
            BEGIN WORK;
                INSERT INTO bdicred:"informix".sd_grupo_credito(empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                        status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(pcEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,
                                        vi_meses_vigts, 'Informix', dtFechaHoy);
            COMMIT WORK;
            --END IF; --IF vd_mto_fin_ven_trasp <= 0 AND

        ELIF EXISTS (SELECT num_credito FROM bdicred:sd_grupo_credito WHERE empresa = pcEmpresa AND numcte = vc_numcte AND num_credito = vc_numcredito) 
                AND vd_mto_fin_ven_trasp <= 0 THEN              -- Si existe y no tiene vencidos: actualiza informacion.
            BEGIN WORK;
                UPDATE bdicred:sd_grupo_credito
                   SET fecha_status = dtFechaHoy,
                       status_cred  = vc_statuscred,
                       porcentaje_uso= vi_porcentaje_uso,
                       monto_autorizado=vd_motorgado,
                       num_historia_efic = num_historia_efic + 1
                 WHERE empresa = pcEmpresa
                   AND num_credito = vc_numcredito
                   AND numcte  = vc_numcte;
            COMMIT WORK;

        END IF;  --IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito

    END FOREACH;

    -- Incluye los nuevos creditos cuyo Cliente ya existe como grupo A. Ya que como son nuevos creditos el proceso anterior no los contempla por no cumplir 
    -- los 6 meses de antiguedad o en estatus vigente.
    LET dtFecha1MesAnt = monthadd(dtFechaHoy,- 1);
    LET dtFecha1MesAnt = dtFecha1MesAnt - 1 units day;

    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu,  vc_statuscred, vd_motorgado, vd_cap_insoluto
          FROM bdicred:"informix".sd_maecredcrd a,
               bdicred:"informix".sd_maesdoscrd b,
               bdisolic:"informix".ss_resum_scor_fin scor
         WHERE a.empresa = pcEmpresa
           AND a.empresa = b.empresa
           AND a.empresa = scor.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = scor.num_solicitud
           AND a.num_producto = p_numproducto
           AND a.status_cred in ('AA', 'E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
           AND a.fecha_apertura >= dtFecha1MesAnt AND a.fecha_apertura <= dtFechaHoy -- Fecha apertura desde la ultima  corrida a la fecha
           AND scor.grupo = 'A'
           AND a.numcte in (Select numcte From bdicred:sd_grupo_cliente)
                     
        IF NOT EXISTS (SELECT num_credito FROM bdicred:sd_grupo_credito WHERE empresa = pcEmpresa AND numcte = vc_numcte AND num_credito = vc_numcredito) THEN
            BEGIN WORK;
                INSERT INTO bdicred:"informix".sd_grupo_credito(empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                        status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(pcEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,
                                        vi_meses_vigts, 'Informix', dtFechaHoy);
            COMMIT WORK;
        END IF;

    END FOREACH;


    -- FMV 9-AGO-12: Esta seccion de codigo se habilitará para la 2a. corrida
        -- LET ren_empresa = pcEmpresa;
        -- LET ren_producto= p_numproducto;
        -- LET ren_credito = vc_numcredito;
    --FMV 5Jul12: Existe el registro en la sd_grupo_credito, entonces busco q no tenga vencido reciente
    CALL "informix".sp_renueva_grupoa_crd(pcEmpresa, p_numproducto, day(dtFechaCortePrev), dtFechaHoy) RETURNING v_codigo_retorno, v_mensaje, v_store_pro;


    IF v_codigo_retorno = "00000" THEN
        LET v_mensaje        = 'Proceso filtro GrupoA Pres.Plazo, Termino Correctamente';
        LET v_store_pro      = 'sp_calculo_grupoa_crd';
        LET vc_intcontproc   = 'F';
        LET vc_crdcontproc   = 'F';

        UPDATE bdinteg:sx_contproc
           SET status_proc = vc_intcontproc, hora_fin = CURRENT
         WHERE empresa = pcEmpresa
           AND fecha   = dtFechaHoy
           AND proceso = vc_tipoproceso;

        UPDATE bdicred:sd_contproc
           SET status_proc = vc_crdcontproc, hora_fin = CURRENT, mensaje = 'Filtro Grupo A Pres.Plazo, Termino Correctamente!'
         WHERE empresa = pcEmpresa
           AND fecha = dtFechaHoy
           AND proceso = vc_tipoproceso;
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin
END PROCEDURE;