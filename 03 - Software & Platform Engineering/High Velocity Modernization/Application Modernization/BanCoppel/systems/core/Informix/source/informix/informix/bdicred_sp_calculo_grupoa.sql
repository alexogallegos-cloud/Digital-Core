CREATE PROCEDURE "informix".sp_calculo_grupoa (cEmpresa CHAR(3), p_numproducto CHAR(4))
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
DEFINE dtFechaCortePrev DATE;
DEFINE dtFechaCorte1mes DATE;
DEFINE dtFechaHoy_aux   DATE;

DEFINE vc_crdcontproc   CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);

DEFINE vc_numproducto   CHAR (4);
DEFINE vc_numcredito    CHAR(20);
DEFINE vc_numcte        CHAR(20); 
DEFINE vc_statuscred    CHAR(2);
DEFINE vd_motorgado     DECIMAL(18,2);
DEFINE vd_cap_insoluto  DECIMAL(18,2);
DEFINE vi_porcentaje_uso    DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);

DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
DEFINE vf_vig_fecha_fac     DATE;
DEFINE vc_tipoproceso       CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;
DEFINE  vlNumCredito        CHAR(20);
--DEFINE ren_empresa  CHAR(3);
--DEFINE ren_producto CHAR(4);
--DEFINE ren_credito  CHAR(20);
DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vs_dia_cort_prod     SMALLINT;
DEFINE vPorcUtil80          SMALLINT;

LET vc_numproducto      ='';
LET vc_numcredito       ='';
LET vc_numcte           =''; 
LET vc_statuscred       ='';
LET vd_motorgado        = 0; 
LET vd_cap_insoluto     = 0;
LET vi_porcentaje_uso   = 0;
LET vi_porcentaje_usoUM =0;
LET vd_capital_insol    = 0;
LET vd_mto_fin_ven_trasp   = 0;
LET vf_vig_fecha_fac    = DATE(1);
LET vc_tipoproceso      = '';
LET vf_fechapertu       = DATE(1);
LET dtFechaHoy_aux      = DATE(1);
LET vi_meses_antigdad   = 0;
--LET ren_empresa = '';
--LET ren_producto ='';
--LET ren_credito ='';
LET vi_meses_vigts      = 0;
LET vd_usolinea_min     = 0;
LET vd_usolinea_max     = 0;
LET vcontador           = 0;
LET vlNumCredito        = '';
LET vs_dia_cort_prod    = 0;
LET vPorcUtil80         = 0;

LET v_codigo_retorno    = "00000";
LET v_mensaje           = "Proceso Inicia Correctamente";
LET v_store_pro         = 'sp_calculo_grupoa';
--LET vc_tipoproceso    = 'FiltroGpo6_' || TRIM (p_numproducto);
LET vc_tipoproceso      = 'CalculoGpoA_' || TRIM (p_numproducto); 

--SET DEBUG FILE TO "/informix/mahr/sp_calculo_grupoa" ||p_numproducto|| ".out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr ,iIsamErr,cErrorInfo         
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = vsqlerr;
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_calculo_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
    END IF;
   END EXCEPTION;


    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha Creacion: 05/JUNIO/2012 || Fecha Modifica: 16/OCTUBRE/2012
	--Objetivo: Valida Clientes que son candidatos al Grupo "A" 6, por tener buen comportamiento de Credito SP exclusivo para Tarjeta de Credito 
    --                
    -- Fecha Modificacion: Dic 2016. Se agregan productos de Tarjeta Platino y Tarjeta Oro. Se corrige proceso para evaluar a nivel cliente.          
	--*********************************************************--

    IF (p_numproducto <> '6001' ) AND (p_numproducto <> '7000' ) AND (p_numproducto <> '8100') THEN
        LET v_codigo_retorno = "00035";
        LET v_mensaje="NO. DE PRODUCTO, INVALIDO PARA EJECUTAR EN EL SP, VERIFIQUE!";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
     END IF;

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = cEmpresa;

         --FMV 6ago12: Validacion de los meses vigentes y los porcentajes de uso de linea en grupo A
    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '55';

    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_min
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '56';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00041";
        LET v_mensaje="Falta parametro del porcentaje minimo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_max
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '57';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00042";
        LET v_mensaje="Falta parametro del porcentaje maximo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    -- FMV 4-OCT-12 Omite validacion para 1a. corrida
    --      IF (DAY(dtFechaHoy) <> 20)
    --       THEN
    --              LET v_codigo_retorno = "00032";
    --              LET v_mensaje="DIA DE EJECUCION NO ES MESIVERSARIO EN DIA 20 DE MES ";
    --              LET v_store_pro = 'sp_calculo_grupoa';
    --          RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    --      END IF; 

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc IS NULL) THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;  
    IF (vc_crdcontproc IS NULL) THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos grupoA');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    END IF;
    /*LET dtFechaHoy = mdy(month(dtFechaHoy),'20',year(dtFechaHoy));
    SELECT first 1 num_credito into vlNumCredito FROM sd_maesdoshist  WHERE empresa = '001' AND FECHA= dtFechaHoy;
    IF '' = NVL(vlNumCredito,'') THEN     
        LET dtFechaHoy = dtFechaHoy -1 UNITS MONTH;
    END IF;*/

    -- Obtiene el dia de corte para cada producto, y armar asi la fecha de corte previo correspondiente.
    SELECT dia_cuota INTO vs_dia_cort_prod FROM bdicred:sd_definicion WHERE empresa = cEmpresa AND num_producto = p_numproducto;
    LET dtFechaHoy_aux = monthadd(dtFechaHoy,- 1);

    IF DAY(dtFechaHoy) <= vs_dia_cort_prod THEN
        --LET dtFechaCortePrev = mdy(month(dtFechaHoy -1 UNITS MONTH),vs_dia_cort_prod,year(dtFechaHoy));
        LET dtFechaCortePrev = mdy(month(dtFechaHoy_aux),vs_dia_cort_prod,year(dtFechaHoy_aux)); -- Fecha corte de mes anterior
    ELSE
        LET dtFechaCortePrev = mdy(month(dtFechaHoy),vs_dia_cort_prod,year(dtFechaHoy));
    END IF;
    
	LET vf_vig_fecha_fac = monthadd(dtFechaCortePrev,- vi_meses_vigts);

    FOREACH WITH HOLD                                   
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto                        
          FROM bdicred:"informix".sd_maecred a,				        
               bdicred:"informix".sd_maesdoshist b, ---max
               bdicred:"informix".sd_maesdos d
         WHERE a.empresa = cEmpresa   
           AND a.empresa = b.empresa
           AND a.empresa = d.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = d.num_credito
           AND b.fecha = dtFechaCortePrev
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (d.monto_vencido + d.mto_venc_trasp) = 0
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)>=vd_usolinea_min
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)<=vd_usolinea_max
           AND b.monto_otorgado > 0
           AND d.monto_otorgado > 0
           AND A.fecha_apertura <= vf_vig_fecha_fac
           AND a.num_credito not in (select num_credito from bdicred:sd_grupo_credito where empresa = '001' and fecha_status = dtFechaHoy)

        LET vPorcUtil80 = 0;
        --LET vd_mto_venc_trasp = 0;  mto_fin_ven_trasp
        LET vd_mto_fin_ven_trasp = 0;

        SELECT count(*) INTO vPorcUtil80 FROM bdicred:sd_maesdoshist    -- Al menos uno de los meses previos tuvo 80% de utilizacion
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito
           AND ((sdo_cap_insoluto * 100) / monto_otorgado ) >= vd_usolinea_min
		   AND monto_otorgado > 0;

        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp  FROM bdicred:"informix".sd_maesdoshist -- Los meses previos no haya tenido vencidos
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito;

        IF ( vPorcUtil80 = 0 OR vd_mto_fin_ven_trasp >= 1 ) THEN -- Si el cliente tuvo un vencido o no tuvo al menos un mes con 80%, no continua.
            CONTINUE FOREACH;
        END IF;

        LET vcontador = 0;
        IF vd_cap_insoluto <=0 THEN
            LET vi_porcentaje_uso = 0;
        ELSE
            LET vi_porcentaje_uso = ((vd_cap_insoluto * 100) / vd_motorgado);
        END IF;
                      
        --LET vcontador  = 0; 
        -- IF vi_porcentaje_usoUM > vd_usolinea_max THEN
        IF vi_porcentaje_uso > vd_usolinea_max THEN -- Rebasa el 100%, es decir, esta sobregirado en el ultimo corte
            LET vcontador  = 1; 
        END IF;   

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa
                          AND num_credito = vc_numcredito AND numcte = vc_numcte) AND (vcontador = 0)  THEN
                        
            --IF (vd_mto_fin_ven_trasp <= 0) THEN
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
            --END IF; --IF vd_mto_fin_ven_trasp <= 0 AND                                                                
        ELSE 
            IF (vcontador = 0)  THEN
                BEGIN WORK;
                    UPDATE bdicred:sd_grupo_credito
                       SET fecha_status = dtFechaHoy,
                           status_cred  = vc_statuscred,
                           porcentaje_uso= vi_porcentaje_uso,
                           monto_autorizado=vd_motorgado,
                           num_historia_efic = num_historia_efic + 1
                     WHERE empresa = cEmpresa
                       AND num_credito = vc_numcredito
                       AND numcte  = vc_numcte;
                COMMIT WORK;
            END IF;
        END IF;  --IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito       
    END FOREACH;


    -- Incluye los nuevos creditos cuyo Cliente ya existe como grupo A. Ya que como son nuevos creditos el proceso anterior no los contempla por no cumplir 
    -- los 6 meses de antiguedad o en estatus vigente.
    LET dtFechaCorte1mes = monthadd(dtFechaHoy, - 1);
    LET dtFechaCorte1mes = dtFechaCorte1mes + 1 units day;
 
    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto
          FROM bdicred:"informix".sd_maecred a,
               bdicred:"informix".sd_maesdos b,
               bdisolic:ss_resum_scor_fin scor
         WHERE a.empresa = cEmpresa
           AND a.empresa = b.empresa
           AND a.empresa = scor.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = scor.num_solicitud
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
           AND b.monto_otorgado > 0
           AND a.fecha_apertura >= dtFechaCorte1mes AND a.fecha_apertura <= dtFechaHoy -- Fecha apertura desde la ultima  corrida a la fecha
           AND scor.grupo = 'A'
           AND a.numcte in (Select numcte From bdicred:sd_grupo_cliente)

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa AND num_credito = vc_numcredito AND numcte = vc_numcte) THEN
                        
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
        END IF;
    END FOREACH;


    -- /* FMV 9-AGO-12: Esta seccion de codigo se habilitarÃ¡ para la 2a. corrida
    --LET ren_empresa = cEmpresa;
    --LET ren_producto= p_numproducto;  
    --LET ren_credito = vc_numcredito;

    --FMV 5Jul12: Existe el registro en la sd_grupo_credito, entonces busco q no tenga vencido reciente          
    CALL "informix".sp_renueva_grupoa(cEmpresa, p_numproducto, vs_dia_cort_prod, dtFechaHoy) RETURNING v_codigo_retorno, v_mensaje, v_store_pro;
                  

    IF v_codigo_retorno = "00000" THEN           
        LET v_mensaje        = "Proceso filtro grupoa Tarjeta, Termino Correctamente";
        LET v_store_pro      = 'sp_calculo_grupoa';
        --LET vc_intcontproc   = 'F';
        --LET vc_crdcontproc   = 'F';

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT                      
         WHERE empresa = cEmpresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipoproceso;
 
        UPDATE bdicred:sd_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT,
		       mensaje = 'Filtro Grupo A Tarjeta, Termino Correctamente!'
         WHERE empresa = cEmpresa
           AND fecha = dtFechaHoy
           AND proceso = vc_tipoproceso;
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin    
END PROCEDURE;