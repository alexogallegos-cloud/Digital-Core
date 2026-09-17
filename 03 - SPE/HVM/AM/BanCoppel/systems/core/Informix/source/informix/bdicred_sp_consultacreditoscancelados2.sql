CREATE PROCEDURE "informix".sp_consultacreditoscancelados2()
RETURNING CHAR(5);
    /* DEFINICION DE VARIABLES */
    DEFINE sql_err             INTEGER;
    DEFINE iMes                INTEGER;
    DEFINE cod_ret             CHAR(5);
    DEFINE dFecha              DATE;
    DEFINE dF_inicioMes        DATE;
    DEFINE dF_finMes           DATE;
    DEFINE cRutaEnvio          CHAR(100);
    DEFINE cNombreArchivo      CHAR(100);
    DEFINE cSQL                CHAR(1000);
    /* Variables de FOR */
    DEFINE sucursal_1          CHAR(4);
    DEFINE numcte1             CHAR(9);
    DEFINE num_credito1        CHAR(12);
    DEFINE fecha_for           DATE;
    DEFINE motivo_cancelacion1 CHAR(4);
    DEFINE motivo1             CHAR(50);
    DEFINE recompensa1         CHAR(20);
    DEFINE acepta_recompensa1  CHAR(1);
    DEFINE estatus1            CHAR(1);
    DEFINE semaforo1           CHAR(1);
    DEFINE hora_fin1           CHAR(19);

    LET cod_ret = "00000";

    /* CALCULO DE FECHAS */
    LET dFecha       = TODAY;
    LET dF_finMes    = TO_DATE(MONTH(dFecha)||'-01-'||YEAR(dFecha),'%m-%d-%Y');
    LET dF_finMes    = dF_finMes-1;

    LET iMes = MONTH(dFecha);

    IF(iMes == 1) THEN
        LET dF_inicioMes = TO_DATE('12'||'-01-'||(YEAR(dFecha)-1),'%m-%d-%Y');
    ELSE
        LET dF_inicioMes = TO_DATE((iMes-1)||'-01-'||YEAR(dFecha),'%m-%d-%Y');
    END IF;

    /* INICIO DE PROCESO DE REPORTERIA */
    BEGIN
        ON EXCEPTION SET sql_err
            IF SQL_ERR <> 0 THEN
                LET cod_ret = SQL_ERR;
                RETURN cod_ret;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        DROP TABLE IF EXISTS sd_tmp;
        DROP TABLE IF EXISTS tmp_sd_bitacora_retencion;
        --SET DEBUG FILE TO "/informix/CRISDAN.dir/sp_consultacreditoscancelados.out";
        --TRACE ON;

        /* OBTIENE RUTA DE ENVIO */
        LET cNombreArchivo = "celula_retencion_f2_"||LPAD(MONTH(dFecha)-1,2,'0')||LPAD(YEAR(dFecha),4,'0')||".csv";

        SELECT valor INTO cRutaEnvio
          FROM bdicred:sd_param
         WHERE cod_param = '130'
           AND empresa   = '001';

        /* OBTIENE REGISTROS */
        SELECT *
          FROM bdicred:sd_bitacora_retencion
         WHERE fecha BETWEEN dF_inicioMes AND dF_finMes
           AND acepta_recompensa  IS NOT NULL
           AND tipo_recompensa    IS NOT NULL
           AND motivo_cancelacion IS NOT NULL
           AND estatus = 2
           AND num_credito <> ''
          INTO TEMP tmp_sd_bitacora_retencion;

        INSERT INTO tmp_sd_bitacora_retencion
        SELECT *
          FROM bdicred:sd_bitacora_retencion
         WHERE fecha BETWEEN dF_inicioMes AND dF_finMes
           AND estatus = 1
           AND num_credito <> '';

        SELECT tmp_sd.sucursal AS sucursal
              ,tmp_sd.numcte AS no_cliente
              ,tmp_sd.num_credito AS no_credito
              ,tmp_sd.fecha AS fecha
              ,tmp_sd.motivo_cancelacion AS clave_motivo
              ,UPPER(tmp_sd.motivo) AS descripcion
              ,strr.descripcion AS recompensa
              ,DECODE(tmp_sd.acepta_recompensa,'f','NO','t','SI','') AS acepta_recompensa
              ,DECODE(tmp_sd.estatus,'1','CANCELADA','2','NO CANCELADA','') AS estatus
              ,scrt.semaforo AS semaforo
              ,tmp_sd.hora_fin AS hora
          FROM tmp_sd_bitacora_retencion AS tmp_sd
          LEFT JOIN bdicred:sd_ctes_retencion scrt ON scrt.numcte = tmp_sd.numcte
		   AND scrt.num_credito = tmp_sd.num_credito
		  LEFT JOIN bdicred:sd_tipos_recompensas_retencion strr ON tmp_sd.tipo_recompensa = strr.tipo_recompensa
		 GROUP BY 1,2,3,4,5,6,7,8,9,10,11
          INTO TEMP sd_tmp;

        /* INICIA PROCESO DE CREACION DE ARCHIVO */

        LET cSQL = 'echo "sucursal|no_cliente|no_credito|fecha|clave_motivo|descripcion|recompensa|acepta_recompensa|estatus|semaforo|hora|" > ' ||TRIM(cRutaEnvio)||TRIM(cNombreArchivo);
        SYSTEM cSQL;

        FOREACH
        SELECT sucursal,no_cliente,no_credito,fecha,clave_motivo,descripcion,recompensa,acepta_recompensa
              ,estatus,semaforo,hora
          INTO sucursal_1,numcte1,num_credito1,fecha_for,motivo_cancelacion1,motivo1,recompensa1,acepta_recompensa1
              ,estatus1,semaforo1,hora_fin1
          FROM sd_tmp
         ORDER BY fecha,no_cliente,hora

            LET cSQL = 'echo "'||TRIM(NVL(sucursal_1,''))||'|'||TRIM(NVL(numcte1,''))||'|'||TRIM(NVL(num_credito1,''))
                        ||'|'||NVL(fecha_for,'')||'|'||TRIM(NVL(motivo_cancelacion1,''))||'|'||TRIM(NVL(motivo1,''))
                        ||'|'||TRIM(NVL(recompensa1,''))||'|'||TRIM(NVL(acepta_recompensa1,''))||'|'||TRIM(NVL(estatus1,''))
                        ||'|'||TRIM(NVL(semaforo1,''))||'|'||TRIM(NVL(hora_fin1,''))||'|'|| '" >> ' ||TRIM(cRutaEnvio)||TRIM(cNombreArchivo);
            SYSTEM cSQL;

        END FOREACH;

        DROP TABLE IF EXISTS sd_tmp;
        DROP TABLE IF EXISTS tmp_sd_bitacora_retencion;

        RETURN cod_ret;
    END;
END PROCEDURE
DOCUMENT
'Folio: ',
'AUTOR : 90233320 - Christian Daniel Hernandez Garcia',
'FECHA : 18/07/2022',
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultacreditoscancelados2"',
'SOLICITA: ',
'BD: bdicred',
'MODIFICADO: Se crea /resplogifx/archivoscartera/altaunica/celula_retencion_f2_mmyyyy.csv';

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