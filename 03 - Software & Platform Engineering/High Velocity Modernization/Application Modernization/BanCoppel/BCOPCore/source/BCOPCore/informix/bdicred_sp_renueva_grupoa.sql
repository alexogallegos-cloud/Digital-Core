CREATE PROCEDURE "informix".sp_renueva_grupoa (pc_Empresa CHAR(3), p_producto CHAR(4), p_diacort_prod SMALLINT, p_FechaRenov DATE)
    RETURNING CHAR(5)  AS Codigo_retorno,
              CHAR(80) AS Mensaje,
              CHAR(25) AS StorePro;

DEFINE vsqlerr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE v_codigo_retorno	CHAR(5);
DEFINE v_mensaje	  	CHAR(80);
DEFINE v_store_pro      CHAR(25);

DEFINE dtFechaHoy       DATE;
DEFINE dtFechaProx      DATE;
DEFINE dtFechaFinMes    DATE;

DEFINE vc_crdcontproc 	CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);

DEFINE vc_numproducto   CHAR (4);
DEFINE vc_numcredito    CHAR(20);
DEFINE vc_numcte        CHAR(20);
DEFINE vc_statuscred        CHAR(2);
DEFINE vd_motorgado         DECIMAL(18,2);
DEFINE vd_cap_insoluto      DECIMAL(18,2);
DEFINE vi_porcent_usoHist   DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);
DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
--DEFINE vf_ult_fecha_fac     DATE;
DEFINE vc_tipproceso        CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;

DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vc_meses_sinusolin   SMALLINT;
DEFINE vi_Bandera           SMALLINT;
DEFINE dtFechaCortePrev     DATE;
DEFINE dtFechaHoy_aux       DATE; 
DEFINE vf_vig_fecha_fac     DATE;

LET vc_numproducto    ='';
LET vc_numcredito     ='';
LET vc_numcte         ='';
LET vc_statuscred     ='';
LET vd_motorgado      = 0;
LET vd_cap_insoluto   = 0;
LET vi_porcent_usoHist = 0;
LET vi_porcentaje_usoUM  =0;
LET vd_capital_insol  = 0;
LET vd_mto_fin_ven_trasp = 0;
--LET vf_ult_fecha_fac  = DATE(1);
LET vc_tipproceso     = '';
LET vf_fechapertu     = DATE(1);
LET dtFechaCortePrev  = DATE(1);
LET dtFechaHoy_aux    = DATE(1);
LET vf_vig_fecha_fac  = DATE(1);
LET vi_meses_antigdad = 0;
LET vc_meses_sinusolin =0;

LET vi_meses_vigts  = 0;
LET vd_usolinea_min = 0;
LET vd_usolinea_max = 0;
LET vcontador       = 0;
LET vc_crdcontproc 	= '';
LET vc_intcontproc 	= '';

LET v_codigo_retorno = "00000";
LET v_mensaje        = "Proceso Inicia Correctamente";
LET v_store_pro      = 'sp_renueva_grupoa';
LET vc_tipproceso    = 'RenuevaGpoA_' || p_producto;
LET vi_Bandera       = 0;

--SET DEBUG FILE TO "/tmp/sp_renueva_grupoa.out";
--TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr,iIsamErr,cErrorInfo 
        IF vsqlerr <> 0 THEN
            LET v_codigo_retorno = vsqlerr;			
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_renueva_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
        END IF;
    END EXCEPTION;

    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros --Fecha Creacion: 25/JULIO/2012 / Fecha Modifica: 16/OCTUBRE/2012
	--Objetivo: Valida Clientes que son candidatos al Grupo A, por tener buen comportamiento de Credito
	--*********************************************************--

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = pc_Empresa;

    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '55';
    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_min
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '56';
    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00041";
        LET v_mensaje="Falta parametro del porcentaje minimo uso de linea";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_max
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '57';
    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00042";
        LET v_mensaje="Falta parametro del porcentaje maximo uso de linea";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc 
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    IF vc_intcontproc IS NULL THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
             VALUES (pc_Empresa,vc_tipproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF vc_crdcontproc IS NULL THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
             VALUES (pc_Empresa,vc_tipproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Renueva GrupoA');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA'
         WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    END IF;

    -- Establece la fecha de corte la el producto correspondiente.
    LET dtFechaHoy_aux = monthadd(dtFechaHoy,- 1);

    IF DAY(p_FechaRenov) <= p_diacort_prod THEN
        LET dtFechaCortePrev = mdy(month(dtFechaHoy_aux),p_diacort_prod, year(dtFechaHoy_aux));  -- Fecha corte de mes anterior
    ELSE
        LET dtFechaCortePrev = mdy(month(p_FechaRenov), p_diacort_prod, year(p_FechaRenov));
    END IF;

    LET vf_vig_fecha_fac = monthadd(p_FechaRenov,- vi_meses_vigts);   --Mses vigentes y los porcentajes de uso de linea en grupo A

    -- Actualiza información de creditos activos.
    FOREACH WITH HOLD
        SELECT c.num_producto, c.num_credito, c.numcte, nvl(c.meses_sinusolin,0), crd.status_cred
          INTO vc_numproducto, vc_numcredito, vc_numcte, vc_meses_sinusolin, vc_statuscred
          FROM bdicred:"informix".sd_grupo_credito c JOIN bdicred:sd_maecred crd
            ON (c.empresa = crd.empresa and c.numcte = crd.numcte and c.num_credito = crd.num_credito and c.num_producto = crd.num_producto)
         WHERE c.empresa = pc_Empresa
           AND c.num_producto = p_producto
           AND c.fecha_status < p_FechaRenov
           AND crd.status_cred IN ('AA','BA','BT','E1','E2','E3')
           --AND c.num_credito = p_credito

        LET vi_Bandera = 0;

        SELECT count(*) INTO vi_porcent_usoHist -- Al menos uno de los meses previos tuvo 80% de utilizacion
          FROM bdicred:sd_maesdoshist    
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = pc_Empresa AND num_credito = vc_numcredito
           AND ((sdo_cap_insoluto * 100) / monto_otorgado ) >= vd_usolinea_min
           AND monto_otorgado > 0;

        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp  -- Consulta historico de meses de atraso, debe ser = 0
          FROM bdicred:"informix".sd_maesdoshist 
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = pc_Empresa AND num_credito = vc_numcredito;
        IF vd_mto_fin_ven_trasp > 0 THEN
            lET vc_statuscred = 'BT';  -- Si un credito tuvo meses vencidos previos, pero no el actual, se marca como BT, para que salga del gpo A
        END IF;

        --IF (vi_porcentaje_usoUM > vd_usolinea_max) AND ( vd_mto_fin_ven_trasp <=0) THEN
        /*IF (vi_porcentaje_usoUM > vd_usolinea_max) THEN
            LET vc_statuscred     = 'SG'; -- Sobregiro de la linea Autorizada
            LET vi_meses_antigdad = 0;
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;    --vi_porcentaje_usoUM > vd_usolinea_max

        ELIF (vi_porcentaje_usoUM < vd_usolinea_min) AND (vc_meses_sinusolin < vi_meses_vigts ) AND ( vd_mto_fin_ven_trasp <=0)  THEN  -- ????  vc_meses_sinusolin??
            IF vc_meses_sinusolin + 1 = vi_meses_vigts  THEN
                --LET vc_statuscred     = 'ML'; -- Un mes de Facturacion sin 80% Uso Linea
                LET vi_meses_antigdad = 0;
            END IF;
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   meses_sinusolin =nvl(meses_sinusolin,0) + 1
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;    --vi_porcentaje_usoUM < vd_usolinea_min */

        IF (vi_porcent_usoHist <= 0 OR vd_mto_fin_ven_trasp >= 1)  THEN     -- Si en los ultimos 6 meses tuvo vencidos o no uso minimo un mes el 80%
        --IF (vd_mto_fin_ven_trasp > 0 ) THEN

            IF vi_porcent_usoHist <= 0 THEN
                LET vc_statuscred     = 'ML'; -- Un mes de Facturacion sin 80% Uso Linea
                LET vi_meses_antigdad = 0;
            END IF;
            IF vd_mto_fin_ven_trasp >= 1 THEN     
                LET vc_statuscred     = 'BT';   -- Si un credito esta en AA, pero tuvo meses vencidos previos, se marca como BT, para que salga del gpo A          
                LET vi_meses_antigdad = 0;
            END IF;

            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   num_historia_efic = vi_meses_antigdad
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;  --  IF vd_mto_fin_ven_trasp > 0

        --ELIF vi_Bandera = 0 THEN  
        ELSE                        -- Si no cumplio condiciones, actualiza datos y que el proceso de integra lo analice y lo elimine del gpo si es necesario. 
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   num_historia_efic = num_historia_efic + 1,
                   meses_sinusolin = vi_porcent_usoHist
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
        END IF;

    END FOREACH;

    -- Actualiza informacion de creditos que no se encuentran activos
    FOREACH WITH HOLD
        SELECT c.num_producto, c.num_credito, c.numcte, nvl(c.meses_sinusolin,0), crd.status_cred
          INTO vc_numproducto, vc_numcredito, vc_numcte, vc_meses_sinusolin, vc_statuscred
          FROM bdicred:"informix".sd_grupo_credito c JOIN bdicred:sd_maecred crd
            ON (c.empresa = crd.empresa and c.numcte = crd.numcte and c.num_credito = crd.num_credito and c.num_producto = crd.num_producto)
         WHERE c.empresa = pc_Empresa
           AND c.num_producto = p_producto
           AND c.fecha_status < p_FechaRenov
           AND crd.status_cred NOT IN ('AA','BA','BT','E1','E2','E3')


        LET vi_meses_antigdad = 0;

        UPDATE bdicred:sd_grupo_credito
           SET fecha_status = p_FechaRenov,
               status_cred  = vc_statuscred,
               num_historia_efic = vi_meses_antigdad
         WHERE empresa = pc_Empresa
           AND numcte  = vc_numcte
           AND num_credito = vc_numcredito;

    END FOREACH;


    IF v_codigo_retorno = "00000" THEN
        -- LET v_codigo_retorno = "00000";
        LET v_mensaje        = 'Renovacion grupoA Tarjeta, Termino Correctamente';

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT
         WHERE empresa = pc_Empresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipproceso;

        UPDATE bdicred:sd_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT,
               mensaje = v_mensaje			       
         WHERE empresa = pc_Empresa
           AND proceso = vc_tipproceso
           AND fecha = dtFechaHoy;        
              
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin
END PROCEDURE;