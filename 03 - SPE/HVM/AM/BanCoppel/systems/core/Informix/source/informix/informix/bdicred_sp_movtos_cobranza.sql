CREATE PROCEDURE "informix".sp_movtos_cobranza(p_empresa  CHAR(3))
--EXECUTE PROCEDURE sp_movtos_cobranza_prueba('001');

   RETURNING CHAR(5)      -- Codigo de Retorno

   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE v_sql                  CHAR(1000);
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE v_fecha_aplica         DATE;
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_folio                CHAR(16);
   DEFINE v_monto_pago           DECIMAL(14,2);
   DEFINE v_codret_tab           CHAR(6);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE wdir                   CHAR(500);
   DEFINE v_ruta                 CHAR(26);
   DEFINE v_sepa                 CHAR(2);

   LET v_sql                  = '';
   LET v_fecha_aplica         = '';
   LET v_num_credito          = '';
   LET v_folio                = '';
   LET v_monto_pago           = 0;
   LET v_codret_tab           = "";
   LET v_codret               = "000";
   LET wdir                   = '';
   LET v_sepa                 = '\|';
   LET v_ruta                 = '';
   --LET v_ano_wk               = YEAR(TODAY);
   --LET v_ano_wk               = v_ano_wk[3,4];
   --LET v_fecha                = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
   LET v_fecha				  = '';

  --   SET DEBUG FILE TO "/pisa/cas/sp_movtos_cobranza.out";
  --   TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrCobranza.err";
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

           LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_movimientos_cobranza.txt';
           SYSTEM wdir;
    END ;

    LET v_sql =
    'echo '||'fecha_aplica'||v_sepa||'num_credito'||v_sepa||'folio'||v_sepa||'monto_pago'||v_sepa||'codret_tab'||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_movimientos_cobranza.txt';
     SYSTEM v_sql;

  FOREACH
      SELECT  fecha_proceso  , num_credito  , folio  , monto  , codretcred
      INTO    v_fecha_aplica, v_num_credito, v_folio, v_monto_pago, v_codret_tab
      FROM    sd_log_cobroaut
      WHERE   fecha_proceso >= (TODAY - 1 UNITS DAY)
      ORDER BY fecha_proceso

                                         --** Crea Archivo Plano Local **--

    LET v_sql ='echo '||v_fecha_aplica||v_sepa||v_num_credito||v_sepa||v_folio||v_sepa||v_monto_pago||v_sepa||v_codret_tab||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_movimientos_cobranza.txt';

     SYSTEM v_sql;


   END FOREACH;

END
RETURN v_codret;
END PROCEDURE;