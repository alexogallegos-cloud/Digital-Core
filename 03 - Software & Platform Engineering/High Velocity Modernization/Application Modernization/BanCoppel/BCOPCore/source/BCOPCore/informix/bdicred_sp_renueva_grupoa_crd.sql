CREATE PROCEDURE "informix".sp_renueva_grupoa_crd(pc_Empresa CHAR(3), p_producto CHAR(4), p_diacort_prod SMALLINT, p_FechaRenov DATE)
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

DEFINE vc_crdcontproc 	    CHAR(1);
DEFINE vc_intcontproc 	    CHAR(1);

DEFINE vc_numproducto       CHAR (4);
DEFINE vc_numcredito        CHAR(20);
DEFINE vc_numcte            CHAR(20);
DEFINE vc_statuscred        CHAR(2);
DEFINE vd_motorgado         DECIMAL(18,2);
DEFINE vd_cap_insoluto      DECIMAL(18,2);
DEFINE vi_porcentaje_uso    DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);
DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
DEFINE vi_Num_Meses_Efic    INTEGER;
--DEFINE vf_ult_fecha_fac   DATE;
DEFINE vc_tipoproceso       CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;

DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vc_meses_sinusolin   SMALLINT;
DEFINE dtFechaCortePrev     DATE;
DEFINE vf_vig_fecha_fac     DATE;

LET vc_numproducto      = '';
LET vc_numcredito       = '';
LET vc_numcte           = '';
LET vc_statuscred       = '';
LET vd_motorgado        = 0;
LET vd_cap_insoluto     = 0;
LET vi_porcentaje_uso   = 0;
LET vi_porcentaje_usoUM = 0;
LET vd_capital_insol    = 0;
LET vd_mto_fin_ven_trasp   = 0;
LET vi_Num_Meses_Efic   = 0;
--LET vf_ult_fecha_fac  = DATE(1);
LET vc_tipoproceso      = '';
LET vf_fechapertu       = DATE(1);
LET vi_meses_antigdad   = 0;
LET vc_meses_sinusolin  = 0;

LET vi_meses_vigts      = 0;
LET vd_usolinea_min     = 0;
LET vd_usolinea_max     = 0;
LET vcontador           = 0;
LET dtFechaCortePrev    = DATE(1);
LET vf_vig_fecha_fac    = DATE(1);

LET v_codigo_retorno    = "00000";
LET v_mensaje           = "Proceso Inicia Correctamente";
LET v_store_pro         = 'sp_renueva_grupoa_crd';
--LET vc_tipoproceso    = 'FiltroGpoA_' || TRIM (p_producto);
LET vc_tipoproceso      = 'RenuevaGpoAPP_' || TRIM (p_producto);

--SET DEBUG FILE TO "/tmp/sp_renueva_grupoa_crd.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET v_codigo_retorno = "00046";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_store_pro = 'sp_renueva_grupoa_crd';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
        END IF;
    END EXCEPTION;

    --**********************************************************************************************--
    -- Creado por: Francisco Martinez Viveros
	-- Fecha Creacion: 25/JULIO/2012  //  Fecha Modifica: 11/OCTUBRE/2012, 25/enero/2013, 31/enero/2013
	-- Objetivo: Valida Clientes que ya no son candidatos al Grupo A, por no tener buen comportamiento de Credito y salen del grupo
    -- Dic 2016. Se agregan otros productos a plazo. Se corrige proceso para evaluar a nivel cliente.         
    --**********************************************************************************************--

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = pc_Empresa;

    --FMV 6ago12: Validacion de los meses vigentes y los porcentajes de uso de linea en grupo A
    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '55';
    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_renueva_grupoa_crd';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc 
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_renueva_grupoa_crd';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    -- Inserta bitacora del proceso
    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF vc_intcontproc IS NULL THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
                VALUES (pc_Empresa,vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF vc_crdcontproc IS NULL THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
                VALUES (pc_Empresa,vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Renueva_Gpoa_crd');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    END IF;

    -- OBtiene fecha de corte previa.
    --LET dtFechaCortePrev = mdy(month(p_FechaRenov -1 UNITS MONTH), day(p_FechaRenov),year(p_FechaRenov));
    --LET dtFechaCortePrev = monthadd(p_FechaRenov,- 1);
    LET dtFechaCortePrev = dtFechaHoy - 1 units day; -- Analiza creditos que cortaron un dia antes, y su respaldo ya se encuentra en maesdoshit. GpoA corre en inicio de dia.
    LET vf_vig_fecha_fac = monthadd(dtFechaCortePrev,- vi_meses_vigts);


    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.status_cred, gpo.num_historia_efic
          INTO vc_numproducto, vc_numcredito, vc_numcte, vc_statuscred, vi_Num_Meses_Efic
          FROM bdicred:sd_maecredcrd a JOIN bdicred:sd_grupo_credito gpo 
            ON (a.empresa = gpo.empresa and a.numcte = gpo.numcte and a.num_credito = gpo.num_credito and a.num_producto = gpo.num_producto)
          JOIN bdicred:sd_maecredanexocrd c ON (a.empresa = c.empresa and a.num_credito = c.num_credito and c.dia_corte = day(dtFechaCortePrev) )
         WHERE a.empresa = pc_Empresa 
           AND a.num_producto = p_producto 
           AND gpo.fecha_status < p_FechaRenov


        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp FROM bdicred:"informix".sd_maesdoshistcrd
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev
           AND empresa = pc_Empresa AND num_credito = vc_numcredito;

        IF vd_mto_fin_ven_trasp > 0 THEN -- Si ha tenido vencidos en meses anteriores
            LET vi_Num_Meses_Efic = 0;
            LET vc_statuscred = 'BT'; --Si en el historico tuvo un vencido, se marca con BT e integracion lo saca del grupo.
        ELSE        -- Si esta vigente
            LET vi_Num_Meses_Efic = vi_Num_Meses_Efic + 1;
        END IF;

        BEGIN;
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   num_historia_efic = vi_Num_Meses_Efic
             WHERE empresa = pc_Empresa
               AND numcte =  vc_numcte
               AND num_credito = vc_numcredito;
        COMMIT;

    END FOREACH;
    LET v_codigo_retorno = "00000";
    LET v_mensaje        = 'Renovacion GrupoA Pres.Plazo, Termino Correctamente';

    UPDATE bdinteg:sx_contproc
       SET status_proc = 'F',
           hora_fin = CURRENT
     WHERE empresa = pc_Empresa
       AND fecha   = dtFechaHoy 
       AND proceso = vc_tipoproceso;

    UPDATE bdicred:sd_contproc
       SET status_proc = 'F',
           hora_fin = CURRENT,
           mensaje = v_mensaje
     WHERE empresa = pc_Empresa
       AND proceso = vc_tipoproceso
       AND fecha = dtFechaHoy;        
              

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin
END PROCEDURE;