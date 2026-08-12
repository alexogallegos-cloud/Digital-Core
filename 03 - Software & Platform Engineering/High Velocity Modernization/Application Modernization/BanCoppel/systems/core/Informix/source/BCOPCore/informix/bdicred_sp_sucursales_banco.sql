CREATE PROCEDURE "informix".sp_sucursales_banco(p_empresa  CHAR(3))
--EXECUTE PROCEDURE sp_sucursales_banco_prueba('001');

   RETURNING CHAR(5)      -- Codigo de Retorno

   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE v_sql                  CHAR(1000);
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE wdir                   CHAR(500);
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_numcte               CHAR(20);
   DEFINE v_sucursal             CHAR(04);
   DEFINE v_nombre               CHAR(40);
   DEFINE v_fecha_apertura       DATE;
   DEFINE v_plazo                INTEGER;
   DEFINE v_credito_externo      CHAR(20);
   DEFINE v_monto_otorgado       DECIMAL(18,2);
   DEFINE v_tasa_interes         DECIMAL(9,6);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_fecha_vencim         DATE;
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);

   LET v_sql                  = '';
   LET v_fecha_apertura       = '';
   LET v_codret               = "000";
   LET v_num_credito          = '';
   LET v_numcte               = '';
   LET v_sucursal             = '';
   LET v_nombre               = '';
   LET v_fecha_apertura       = '';
   LET v_plazo                = 0;
   LET v_credito_externo      = '';
   LET v_monto_otorgado       = 0;
   LET v_tasa_interes         = 0;
   LET v_fecha_vencim         = '';
   LET v_sepa                 = '\|';
   LET v_ruta                 = '';
   --LET v_ano_wk               = YEAR(TODAY);
   --LET v_ano_wk               = v_ano_wk[3,4];
   --LET v_fecha                = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
   LET v_fecha				  = '';

   --SET DEBUG FILE TO "/tmp/sp_sucursales_banco.out";
  -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrSucursales.err";
      TRACE v_num_credito||" * "||sql_err||" * "||isam_err||" * "||error_info;
      IF sql_err <> 0  THEN
         LET v_codret = sql_err;
         let v_codret = v_codret;
         ROLLBACK WORK;
         --BEGIN WORK;
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

            LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_x_sucursales.txt';
            SYSTEM wdir;
    END ;


   LET v_sql =
      'echo '||'num_credito'||v_sepa||'numcte'||v_sepa||'sucursal'||v_sepa||'nombre'||v_sepa||'fecha_apertura'||v_sepa||'plazo'||v_sepa||'credito_externo'||v_sepa||'monto_otorgado'||v_sepa||'tasa_interes'||v_sepa||'fecha_vencim'||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_x_sucursales.txt';
     SYSTEM v_sql;


  FOREACH
      SELECT {+INDEX sd_maecredcrd idx_maecrd}
             a.num_credito, a.numcte, a.sucursal,
             c.nombre, a.fecha_apertura, a.plazo,
             a.credito_externo, b.monto_otorgado,
             a.tasa_interes, a.fecha_vencim
      INTO   v_num_credito, v_numcte, v_sucursal,
             v_nombre, v_fecha_apertura, v_plazo,
             v_credito_externo, v_monto_otorgado,
             v_tasa_interes, v_fecha_vencim
      FROM   sd_maecredcrd a, sd_maesdoscrd b,  bdinteg:si_sucursales c
      WHERE  a.empresa = p_empresa
      AND    a.empresa = b.empresa
      AND    a.num_credito = b.num_credito
      AND    a.sucursal = c.sucursal
      AND    a.fecha_apertura >= (TODAY - 1 UNITS DAY)
      AND    a.num_producto = '6011'
      ORDER BY a.fecha_apertura

                   --** Crea Archivo Plano Local **--

         LET v_sql =
      'echo '||v_num_credito||v_sepa||v_numcte||v_sepa||v_sucursal||v_sepa||v_nombre||v_sepa||v_fecha_apertura||v_sepa||v_plazo||v_sepa||v_credito_externo||v_sepa||v_monto_otorgado||v_sepa||v_tasa_interes||v_sepa||v_fecha_vencim||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_x_sucursales.txt';

         SYSTEM v_sql;

   END FOREACH;

END
RETURN v_codret;
END PROCEDURE;