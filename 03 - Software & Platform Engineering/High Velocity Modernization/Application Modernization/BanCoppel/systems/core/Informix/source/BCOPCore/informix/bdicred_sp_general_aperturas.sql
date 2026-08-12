CREATE PROCEDURE "informix".sp_general_aperturas(p_Empresa  CHAR(3))
--EXECUTE PROCEDURE sp_general_aperturas_prueba ('001');

   RETURNING CHAR(5)      -- Codigo de Retorno

   DEFINE wBegin                 CHAR(1);
   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE v_sql                  CHAR(1000);
   DEFINE wdir                   CHAR(500);
   DEFINE v_pipe                 CHAR(1);
   DEFINE vMes                   CHAR(2);
   DEFINE vDia                   CHAR(2);
   DEFINE vAnio                  CHAR(4);
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_credito_externo      CHAR(20);
   DEFINE v_numcte               CHAR(20);
   DEFINE v_sucursal             CHAR(4);
   DEFINE v_gucursal             CHAR(4);
   DEFINE v_fecha_apertura       DATE;
   DEFINE v_plazo                INTEGER;
   DEFINE v_monto_otorgado       DECIMAL(18,2);
   DEFINE v_capital_mto_cuota    DECIMAL(14,2);
   DEFINE v_tasa_interes         DECIMAL(9,6);
   DEFINE v_fecha_vencim         DATE;
   DEFINE v_fecha_cuota          DATE;
   DEFINE v_producto             CHAR(4);
   DEFINE v_num_cta              CHAR(20);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);
   DEFINE vDiaCorte              SMALLINT;

   LET v_sql                  = '';
   LET vMes                   = '';
   LET vDia                   = '';
   LET vAnio                  = '';
   LET v_pipe                 = '|';
   LET v_num_credito          = ' ';
   LET v_credito_externo      = ' ';
   LET v_numcte               = ' ';
   LET v_sucursal             = ' ';
   LET v_fecha_apertura       = ' ';
   LET v_plazo                = 0;
   LET v_monto_otorgado       = ' ';
   LET v_capital_mto_cuota    = ' ';
   LET v_tasa_interes         = ' ';
   LET v_fecha_vencim         = ' ';
   LET v_fecha_cuota          = ' ';
   LET v_producto             = ' ';
   LET v_num_cta              = ' ';
   LET wBegin                 = "N";
   LET v_codret               = "000";
   --LET v_ano_wk               = YEAR(TODAY);
   --LET v_ano_wk               = v_ano_wk[3,4];
   --LET v_fecha                = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
   LET v_fecha				  = '';
   LET v_sepa                 ="\|";
   LET vDiaCorte              = 0;

 --  SET DEBUG FILE TO "/tmp/sp_general_aperturas.out";
 --  TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrAperturas.err";
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

  SELECT TRIM(valor)
  INTO v_ruta
  FROM sd_param
  WHERE cod_param ='47';

                    --** Borra Archivo Por Si Fue Ya Creado  **--

    BEGIN
            ON EXCEPTION IN (-668) SET sql_err
                LET v_codret = "000";
                LET wdir = wdir;
            END EXCEPTION WITH RESUME;

            LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_general_aperturas.txt';
            SYSTEM wdir;
    END ;

    LET v_sql =
    'echo '||'num_credito'||v_sepa||'credito_externo'||v_sepa||'numcte'||v_sepa||'sucursal'||v_sepa||'fecha_apertura'||v_sepa||'plazo'||v_sepa||'monto_otorgado'||v_sepa||'capital_mto_cuota'||v_sepa||'tasa_interes'||v_sepa||'fecha_vencim'||v_sepa||'fecha_cuota'||v_sepa||'producto'||v_sepa||'num_cta'||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_general_aperturas.txt';
     SYSTEM v_sql;

  FOREACH
          SELECT   {+INDEX (sd_ctascarg idx_sd_ctascarg_cred_nat)}
                   a.num_credito, a.credito_externo, a.numcte, a.sucursal, a.fecha_apertura, a.plazo,
                   b.monto_otorgado, c.capital_mto_cuota, a.tasa_interes,
                   a.fecha_vencim, f.dia_corte, e.producto, d.num_cta
          INTO     v_num_credito, v_credito_externo, v_numcte, v_sucursal, v_fecha_apertura, v_plazo,
                   v_monto_otorgado, v_capital_mto_cuota, v_tasa_interes,
                   v_fecha_vencim,vDiaCorte, v_producto, v_num_cta
          FROM     sd_maecredcrd a, sd_maesdoscrd b,
                   sd_amortiza_creditocrd c, sd_ctascarg d,
                   bdicheq:sc_maechq e, sd_maecredanexocrd f
          WHERE    a.empresa = p_Empresa
          AND      a.empresa = b.empresa
          AND      a.empresa = c.empresa
          AND      a.num_credito = b.num_credito
          AND      a.num_credito = c.num_credito
          AND      a.num_credito = f.num_credito
          AND      c.fecha_cuota = a.fecha_vencim
          AND      a.fecha_apertura <= today
          AND      d.num_credito = a.num_credito
          AND      d.num_cta = e.cuenta
          AND      a.num_producto = '6011'
          ORDER BY a.fecha_apertura


   	 SELECT min(fecha_cuota), max(capital_mto_cuota) 
         INTO v_fecha_cuota,v_capital_mto_cuota
         FROM sd_amortiza_creditocrd
         WHERE empresa = p_Empresa and num_credito = v_num_credito;


           -- IF MONTH(v_fecha_apertura) < '12' THEN
           --       LET v_fecha_cuota =MDY(MONTH(v_fecha_apertura) + 1 ,DAY(vDiaCorte),YEAR(v_fecha_apertura));
           --ELSE
           --      LET v_fecha_cuota =MDY('01',DAY(vDiaCorte),YEAR(v_fecha_apertura) + 1);
           --END IF;

                                       --** Crea Archivo Plano Local **--
     LET v_sql =
    'echo '||v_num_credito||v_sepa||v_credito_externo||v_sepa||v_numcte||v_sepa||v_sucursal||v_sepa||v_fecha_apertura||v_sepa||v_plazo||v_sepa||v_monto_otorgado||v_sepa||v_capital_mto_cuota||v_sepa||v_tasa_interes||v_sepa||v_fecha_vencim||v_sepa||v_fecha_cuota||v_sepa||v_producto||v_sepa||v_num_cta||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_general_aperturas.txt';
     SYSTEM v_sql;

   END FOREACH;

END
RETURN v_codret;
END PROCEDURE;