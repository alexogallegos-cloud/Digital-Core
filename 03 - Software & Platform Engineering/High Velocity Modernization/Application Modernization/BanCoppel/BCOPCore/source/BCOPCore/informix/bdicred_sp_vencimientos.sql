CREATE PROCEDURE "informix".sp_vencimientos(p_empresa  CHAR(3))
--EXECUTE PROCEDURE sp_vencimientos_prueba('001');

   RETURNING CHAR(5)      -- Codigo de Retorno

--- RAUL RAMIREZ 25/03/2010
--- GENERACION DE REPORTES VENCIMIENTOS 5 Y 4 DIAS ANTES
--- DE LOS DIAS 2 Y 17 VENCIMIENTOS REESTRUCTURAS


   DEFINE g_Fecha                DATE;
   DEFINE wBegin                 CHAR(1);
   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE v_sql                  CHAR(1000);
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE wdir                   CHAR(500);
   DEFINE vMes                   CHAR(2);
   DEFINE vDia                   CHAR(2);
   DEFINE vAnio                  CHAR(4);
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_status_cred        	 CHAR(2);
   DEFINE v_pagos_sostenidos     INTEGER;
   DEFINE v_numcte               CHAR(20);
   DEFINE v_fecha_apertura       DATE;
   DEFINE v_plazo                INTEGER;
   DEFINE v_monto_otorgado    	 DECIMAL(18,2);
   DEFINE v_fecha_cuota        	 DATE;
   DEFINE v_capital_mto_cuota    DECIMAL(14,2);
   DEFINE v_capital_debe         DECIMAL(14,2);
   DEFINE v_interes_debe         DECIMAL(14,2);
   DEFINE v_sdo_actual        	 decimal (18,2);
   DEFINE v_iva_no_exigible      DECIMAL(18,2);
   DEFINE v_no_exigible          DECIMAL(18,2);
   DEFINE v_num_cta              CHAR(20);
   DEFINE v_iva                  CHAR(5);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);

   DEFINE v_fecha_hoy	           DATE;
   DEFINE v_ult_dia_mes          DATE;

   LET v_sql                  = '';
   LET vMes                   = '';
   LET vDia                   = '';
   LET vAnio                  = '';

   LET v_num_credito          = ' ';
   LET v_status_cred        	= ' ';
   LET v_pagos_sostenidos     = 0;
   LET v_numcte               = ' ';
   LET v_fecha_apertura       = ' ';
   LET v_plazo                = 0;
   LET v_monto_otorgado       = 0;
   LET v_fecha_cuota          = ' ';
   LET v_capital_mto_cuota    = 0;
   LET v_capital_debe         = 0;
   LET v_interes_debe         = 0;
   LET v_sdo_actual           = 0;
   LET v_iva_no_exigible      = 0;
   LET v_no_exigible          = 0;
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

   LET v_fecha_hoy            = ' ';
   LET v_ult_dia_mes          = ' ';

   --SET DEBUG FILE TO "/ids10_uc9/raul/pisa/sp_vencimientos.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrVencimientos.err";
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
   where empresa = p_Empresa;

   SELECT  trim(valor)
   INTO    v_iva
   FROM    sd_param
   WHERE   empresa = p_empresa
   AND     cod_param = '12';              --obtiene iva 16%



   SELECT TRIM(valor)
     INTO v_ruta
     FROM sd_param
    WHERE empresa = p_empresa
      AND cod_param = '47';              -- obtiene ruta

   SELECT {+INDEX (sd_fechas idx_sdfechas)}
          fecha_hoy, ult_dia_mes
     INTO v_fecha_hoy, v_ult_dia_mes
     FROM sd_fechas
    WHERE empresa = p_empresa;


            IF (v_ult_dia_mes - 3 = v_fecha_hoy) OR (v_ult_dia_mes - 2 = v_fecha_hoy) THEN
               IF MONTH (v_ult_dia_mes) < '12' THEN
                  LET v_fecha_cuota =MDY(MONTH(v_ult_dia_mes) +1 ,'02',YEAR(v_ult_dia_mes));
                  ELSE
                  LET v_fecha_cuota =MDY ('01' ,'02',YEAR(v_ult_dia_mes)+1);
               END IF;
            ELIF (DAY (v_fecha_hoy) = '12') OR (DAY (v_fecha_hoy) = '13') THEN
                 LET v_fecha_cuota =MDY(MONTH(v_fecha_hoy),'17',YEAR(v_fecha_hoy));
            END IF;

                    --** Borra Archivo Por Si Fue Ya Creado  **--
    BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET v_codret = "000";
                LET wdir = wdir;
            END EXCEPTION WITH RESUME;

            LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_vencimientos.txt';
            SYSTEM wdir;
   END ;


    LET v_sql =
      'echo '||'num_credito'||v_sepa||'status_cred'||v_sepa||'pagos_sostenidos'||v_sepa||'numcte'||v_sepa||'fecha_apertura'||v_sepa||'fecha_cuota'||v_sepa||'plazo'||v_sepa||'monto_otorgado'||v_sepa||'capital_mto_cuota'||v_sepa||'capital_debe'||v_sepa||'interes_debe'||v_sepa||'iva_debe'||v_sepa||'Pago_Total'||v_sepa||'num_cta'||v_sepa||'sdo_actual'||' >>'||trim(v_ruta)||trim(v_fecha)||'_vencimientos.txt';
     SYSTEM v_sql;

  FOREACH
          SELECT {+INDEX (sd_maecredcrd idx_maecrd)}
                 a.num_credito, a.status_cred, a.pagos_sostenidos, a.numcte, a.fecha_apertura,
                 c.fecha_cuota, a.plazo, b.monto_otorgado, c.capital_mto_cuota, c.capital_debe,
                 c.interes_debe, c.iva_debe,
                 (c.capital_debe + c.interes_debe + c.iva_debe),
                 d.num_cta, e.sdo_actual

            INTO v_num_credito, v_status_cred, v_pagos_sostenidos, v_numcte, v_fecha_apertura,
                 v_fecha_cuota, v_plazo, v_monto_otorgado, v_capital_mto_cuota, v_capital_debe,
                 v_interes_debe, v_iva_no_exigible,
                 v_no_exigible,
                 v_num_cta, v_sdo_actual

            FROM sd_maecredcrd a, sd_maesdoscrd b, sd_amortiza_creditocrd c,
                 sd_ctascarg d, bdicheq:sc_maechq e
           WHERE a.empresa = p_empresa
             AND a.num_credito = b.num_credito
             AND a.num_credito = c.num_credito
             AND c.fecha_cuota = v_fecha_cuota
             AND d.num_credito = a.num_credito
             AND d.num_cta = e.cuenta
             AND a.status_cred <> 'FF'
             AND a.num_producto = '6011'


               --** Crea Archivo Plano Local **--


         LET v_sql =
      'echo '||v_num_credito||v_sepa||v_status_cred||v_sepa||v_pagos_sostenidos||v_sepa||v_numcte||v_sepa||v_fecha_apertura||v_sepa||v_fecha_cuota||v_sepa||v_plazo||v_sepa||v_monto_otorgado||v_sepa||v_capital_mto_cuota||v_sepa||v_capital_debe||v_sepa||v_interes_debe||v_sepa||v_iva_no_exigible||v_sepa||v_no_exigible||v_sepa||v_num_cta||v_sepa||v_sdo_actual||v_sepa||' >>'||trim(v_ruta)||trim(v_fecha)||'_vencimientos.txt';

       SYSTEM v_sql;

   END FOREACH;

END
RETURN v_codret;
END PROCEDURE;