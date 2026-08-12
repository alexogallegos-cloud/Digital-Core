CREATE PROCEDURE "informix".sp_maestro_saldos(p_empresa  CHAR(3))
--EXECUTE PROCEDURE sp_maestro_saldos_prueba('001');

   RETURNING CHAR(5)      -- Codigo de Retorno
   
-- Se agrega al reporte el status del credito 18/05/10 RaÃºl RamÃ­rez   
-- Se agregan los datos de No de Moras y ejecutivo a cargo de la cuenta al reporte generado. MAHR Feb/2013

   DEFINE g_Fecha                DATE;
   DEFINE wBegin                 CHAR(1);
   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE v_sql                  CHAR(1000);
   DEFINE wdir                   CHAR(500);
   DEFINE vMes                   CHAR(2);
   DEFINE vDia                   CHAR(2);
   DEFINE vAnio                  CHAR(4);
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_credito_externo      CHAR(20);
   DEFINE v_numcte               CHAR(20);
   DEFINE v_sucursal             CHAR(4);
   DEFINE v_fecha_apertura       DATE;
   DEFINE v_fecha_ult_mov        DATE;
   DEFINE v_plazo                INTEGER;
   DEFINE v_dias_acum_int        INTEGER;
   DEFINE v_monto_otorgado       DECIMAL(18,2);
   DEFINE v_sdo_intereses        DECIMAL(18,2);
   DEFINE v_provision_normal     DECIMAL(18,2);
   DEFINE v_sdo_cap_insoluto     DECIMAL(18,2);
   DEFINE v_sdo_global_int       DECIMAL(18,2);
   DEFINE v_sdo_acum_intper      DECIMAL(18,2);
   DEFINE v_sdo_capital          DECIMAL(18,2);
   DEFINE v_sdo_no_exig          DECIMAL(18,2);
   DEFINE v_iva_vigente          DECIMAL(18,2);
   DEFINE v_mto_venc_tra_int     DECIMAL(18,2);
   DEFINE v_iva_exigible         DECIMAL(18,2);
   DEFINE v_iva_no_exigible      DECIMAL(18,2);
   DEFINE v_monto_vencido        DECIMAL(18,2);
   DEFINE v_sdo_exig_int         DECIMAL(18,2);
   DEFINE v_iva_transitorio      DECIMAL(18,2);
   DEFINE v_mto_venc_trasp       DECIMAL(18,2);
   DEFINE v_cap_tras_no_venci    DECIMAL(18,2);
   DEFINE v_int_tra_no_exig      DECIMAL(18,2);
   DEFINE v_capital_mto_cuota    DECIMAL(14,2);
   DEFINE v_tasa_interes         DECIMAL(9,6);
   DEFINE v_iva                  CHAR(5);
   DEFINE v_fecha_vencim         DATE;
   DEFINE v_fecha_cuota          DATE;
   DEFINE v_producto             CHAR(4);
   DEFINE v_num_cta              CHAR(20);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);
   DEFINE v_status_cred          CHAR(2);
   DEFINE v_promotor             CHAR(8);
   DEFINE v_pagos_venc           SMALLINT;

   LET v_sql                  = '';
   LET vMes                   = '';
   LET vDia                   = '';
   LET vAnio                  = '';

   LET v_num_credito          = ' ';
   LET v_credito_externo      = ' ';
   LET v_numcte               = ' ';
   LET v_sucursal             = ' ';
   LET v_fecha_apertura       = ' ';
   LET v_fecha_ult_mov        = ' ';
   LET v_plazo                = 0;
   LET v_sdo_intereses        = 0;
   LET v_provision_normal     = 0;
   LET v_dias_acum_int        = 0;
   LET v_sdo_cap_insoluto     = 0;
   LET v_sdo_global_int       = 0;
   LET v_sdo_acum_intper      = 0;
   LET v_sdo_capital          = 0;
   LET v_sdo_no_exig          = 0;
   LET v_iva_vigente          = 0;
   LET v_mto_venc_tra_int     = 0;
   LET v_iva_exigible         = 0;
   LET v_iva_no_exigible      = 0;
   LET v_monto_vencido        = 0;
   LET v_sdo_exig_int         = 0;
   LET v_mto_venc_trasp       = 0;
   LET v_iva_transitorio      = 0;
   LET v_cap_tras_no_venci    = 0;
   LET v_int_tra_no_exig      = 0;
   LET v_monto_otorgado       = ' ';
   LET v_capital_mto_cuota    = ' ';
   LET v_tasa_interes         = ' ';
   LET v_fecha_vencim         = ' ';
   LET v_fecha_cuota          = ' ';
   LET v_producto             = ' ';
   LET v_num_cta              = ' ';
   LET wBegin                 = "N";
   LET v_sepa                 = '\|';
   LET wdir                   = '';
   LET v_iva                  = '';

   LET v_ruta                 =''; 
   LET v_codret               = "000";
   --LET v_ano_wk               = YEAR(TODAY);
   --LET v_ano_wk               = v_ano_wk[3,4];
   --LET v_fecha                = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
   LET v_fecha				  = '';
   LET v_status_cred          = ' ';
   LET v_promotor             = '';
   LET v_pagos_venc           = 0;

  -- SET DEBUG FILE TO "/pisa/cas/sp_maestro_saldos.out";
  -- SET DEBUG FILE TO "/RESPALDOSNEW/Ulises/sp_maestro_saldos.out";
  -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrMtroSaldos.err";
      TRACE v_num_credito||" * "||sql_err||" * "||isam_err||" * "||error_info;
      IF sql_err <> 0  THEN
         LET v_codret = sql_err;
         let v_codret = v_codret;
         ROLLBACK WORK;
         RETURN v_codret;
      END IF
   END EXCEPTION;
   
   -- Recupera la fecha anterior con la que se va a generar el archivo
   SELECT LPAD(DAY(fecha_ant),2,0)||LPAD(MONTH(fecha_ant),2,0)||NVL(SUBSTR(YEAR(fecha_ant), 3, 2),'')
   INTO v_fecha
   FROM sd_fechas
   WHERE empresa = p_Empresa;

   SELECT  trim(valor)
   INTO    v_iva
   FROM    sd_param
   WHERE   empresa = p_empresa
   AND     cod_param = '12';              --obtiene iva 16%

   SELECT TRIM(valor)
   INTO v_ruta
   FROM sd_param
   WHERE cod_param ='47'; -- /resplogifx/reestructuras/ 

                    --** Borra Archivo Por Si Fue Ya Creado  **--
    BEGIN
        ON EXCEPTION IN (-668) SET sql_err
            LET v_codret = "000";
            LET wdir = wdir;
        END EXCEPTION WITH RESUME;

        --LET wdir = 'rm ' || TRIM(v_ruta)::char(26) || TRIM (v_fecha)::char(6) || '_maestro_saldos.txt';
        LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_maestro_saldos.txt';
        SYSTEM wdir;
   END ;

    LET v_sql ='echo '||'num_credito'||v_sepa||'numcte'||v_sepa||'sucursal'||v_sepa||'fecha_apertura'||v_sepa||'fecha_ult_mov'||v_sepa||'sdo_intereses'||
        v_sepa||'provision_normal'||v_sepa||'dias_acum_int'||v_sepa||'sdo_cap_insoluto'||v_sepa||'sdo_global_int'||v_sepa||'sdo_acum_intper'||v_sepa||
        'monto_otorgado'||v_sepa||'capital_vigente'||v_sepa||'interes_vigente'||v_sepa||'iva_vigente'||v_sepa||'capital_exigible'||v_sepa||
        'interes_exigible'||v_sepa||'iva_exigible'||v_sepa||'capital_no_exigible'||v_sepa||'interes_no_exigible'||v_sepa||'iva_no_exigible'||v_sepa||
        'capital_transitorio'||v_sepa||'interes_transitorio'||v_sepa||'iva_transitorio'||v_sepa||'status_cred'||v_sepa||'pagos_vencidos'||v_sepa||'promotor'||
        ' >>'|| trim(v_ruta) || trim(v_fecha) || '_maestro_saldos.txt'; 
        --' >>'||trim(v_ruta)::char(26)||trim(v_fecha)::char(6)||'_maestro_saldos.txt';
    SYSTEM v_sql;

	SELECT empresa,num_credito,num_producto,ejecutivo,numcte,sucursal,status_cred,fecha_apertura
	FROM sd_maecredcrd
	WHERE empresa = p_empresa
	AND num_producto = '6011'  --- FMV 17-MAY-2011: Se omite producto para que genere todos los Producto --Se activa
	AND status_cred in ('AA','BA','BT','VP','E1','E2','E3') --- 26-05-2016 Se solicita que solo se contemple los crÃ©ditos de reestructuras activos
	INTO TEMP maecredcrdtemp with no log;
	CREATE INDEX idx_maecrdtemp ON maecredcrdtemp(num_credito);
	
  FOREACH
  
      SELECT  a.num_credito    , b.numcte           , b.sucursal     ,b.fecha_apertura   , a.fecha_ult_mov,
              a.sdo_intereses  , a.provision_normal , a.dias_acum_int, a.sdo_cap_insoluto, a.sdo_global_int,
              a.sdo_acum_intper, a.monto_otorgado   , a.sdo_capital,
              a.mto_venc_trasp , a.cap_tras_no_venci, a.monto_vencido, b.status_cred, b.ejecutivo

      INTO    v_num_credito    , v_numcte            , v_sucursal       , v_fecha_apertura   , v_fecha_ult_mov,
              v_sdo_intereses  , v_provision_normal  , v_dias_acum_int  , v_sdo_cap_insoluto , v_sdo_global_int,
              v_sdo_acum_intper, v_monto_otorgado    , v_sdo_capital    ,
              v_mto_venc_trasp , v_cap_tras_no_venci ,  v_monto_vencido ,v_status_cred, v_promotor

      FROM    sd_maesdoscrd a, maecredcrdtemp b
      WHERE   a.empresa     = b.empresa
	  AND	  a.empresa     = p_empresa  
      AND     a.num_credito = b.num_credito
	  ORDER BY b.num_producto,b.fecha_apertura  --FMV 09-JUN-2011: Se ordena por Producto


        select sum(case when capital_status in ('1','3') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_vigente,
               sum(case when capital_status in ('1','3') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_vigente,
               sum(case when capital_status in ('2','6') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_vencido,
               sum(case when capital_status in ('2','6') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_vencido,
               sum(case when capital_status in ('1','3') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_no_exigible,
               sum(case when capital_status in ('1','3') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_no_exigible,
               sum(case when capital_status in ('7') then (nvl(interes_debe,0)-nvl(interes_pagado,0)) else 0 end)interes_transitorio,
               sum(case when capital_status in ('7') then (nvl(iva_debe,0)-nvl(iva_pagado,0)) else 0 end)iva_transitorio,              
               sum(case when capital_status in ('2','7','6') then 1 else 0 end) as pagos_vencidos
          into v_sdo_no_exig,
               v_iva_vigente,
               v_mto_venc_tra_int,
               v_iva_exigible,
               v_int_tra_no_exig,
               v_iva_no_exigible,
               v_sdo_exig_int,
               v_iva_transitorio,
               v_pagos_venc
          from bdicred:sd_amortiza_creditocrd
         where empresa=p_empresa
           and num_credito=v_num_credito
           and capital_status in ('2','7','1','3','6');

		if v_sdo_no_exig is null then let v_sdo_no_exig = 0; end if; 
		if v_iva_vigente is null then let v_iva_vigente = 0; end if; 
		if v_mto_venc_tra_int is null then let v_mto_venc_tra_int = 0; end if; 
		if v_iva_exigible is null then let v_iva_exigible = 0; end if; 
		if v_int_tra_no_exig is null then let v_int_tra_no_exig = 0; end if; 
		if v_iva_no_exigible is null then let v_iva_no_exigible = 0; end if; 
		if v_sdo_exig_int is null then let v_sdo_exig_int = 0; end if; 
		if v_iva_transitorio is null then let v_iva_transitorio = 0; end if; 
        if v_pagos_venc is null then let v_pagos_venc = 0; end if; 

           IF v_sdo_capital>0 THEN
              LET v_int_tra_no_exig=0;
              LET v_iva_no_exigible=0;
           ELIF v_cap_tras_no_venci>0 THEN
              LET v_sdo_no_exig=0;
              LET v_iva_vigente=0;
           END IF;

     --** Crea Archivo Plano Local **--

         LET v_sql ='echo '||v_num_credito||v_sepa||v_numcte||v_sepa||v_sucursal||v_sepa||v_fecha_apertura||v_sepa||
            v_fecha_ult_mov||v_sepa||v_sdo_intereses||v_sepa||v_provision_normal||v_sepa||v_dias_acum_int||v_sepa||v_sdo_cap_insoluto||
            v_sepa||v_sdo_global_int||v_sepa||v_sdo_acum_intper||v_sepa||v_monto_otorgado||v_sepa||v_sdo_capital||v_sepa||
            v_sdo_no_exig||v_sepa||v_iva_vigente||v_sepa||v_mto_venc_trasp||v_sepa||v_mto_venc_tra_int||v_sepa||v_iva_exigible||
            v_sepa||v_cap_tras_no_venci||v_sepa||v_int_tra_no_exig||v_sepa||v_iva_no_exigible||v_sepa||v_monto_vencido||v_sepa||
            v_sdo_exig_int||v_sepa||v_iva_transitorio|| v_sepa || v_status_cred || v_sepa ||v_pagos_venc || v_sepa ||v_promotor||
            ' >>'||trim(v_ruta)||trim(v_fecha)||'_maestro_saldos.txt'; 
            --' >>'||trim(v_ruta)::char(26)||trim(v_fecha)::char(6)||'_maestro_saldos.txt';

       SYSTEM v_sql;

   END FOREACH;
DROP TABLE maecredcrdtemp;
END
RETURN v_codret;
END PROCEDURE;