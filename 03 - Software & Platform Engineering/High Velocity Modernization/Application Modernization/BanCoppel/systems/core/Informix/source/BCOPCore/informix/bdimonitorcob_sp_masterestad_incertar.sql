CREATE PROCEDURE "informix".sp_masterestad_incertar(p_anio CHAR(4), p_mes CHAR(2))
       RETURNING char(5), char(80);

DEFINE v_num_credito       char(20);
DEFINE v_num_tarjeta       char(20);
DEFINE v_nombre            char(50);
DEFINE v_fecha_apertura    date;
DEFINE V_FECHACESAR DATE;
DEFINE v_fch_ini           CHAR(10);
DEFINE v_fch_fin      CHAR(10);
DEFINE v_concepto     CHAR(3);
DEFINE  vCodRet       CHAR(5);
DEFINE  vMensaje      CHAR(80);
DEFINE  SQL_ERR       INTEGER;
DEFINE  ISAM_ERR      INTEGER;
DEFINE  ERROR_INFO    VARCHAR(80);
DEFINE  v_fch_inic    DATE;
DEFINE  v_fch_finc    DATE;
--DEFINE  v_fch_finc    DATE YEAR TO FRACTION (5);

--Set debug file to "sp_masterestad_incertar.out";
--trace on;

   LET v_num_credito   = " ";
   LET v_num_tarjeta   = " ";
   LET v_nombre        = " ";
   LET v_fecha_apertura = " ";
   LET v_fch_ini        = p_mes||'-'||'01'||'-'||p_anio;
   LET vCodRet          = "00000";
   LET vMensaje         = "EJECUCION EXITOSA";

    IF (p_mes = '01' OR
       p_mes = '03' OR
       p_mes = '05' OR
       p_mes = '07' OR
       p_mes = '08' OR
       p_mes = '10' OR
       p_mes = '12') THEN
       LET v_fch_fin = p_mes||'-'||'31'||'-'||p_anio;
    ELSE
       LET v_fch_fin = p_mes||'-'||'30'||'-'||p_anio;
    END IF

      IF (p_mes= '02') THEN
       IF (MOD (p_anio,4)=0 AND MOD (p_anio,100)<>0) THEN
          LET v_fch_fin = p_mes||'-'||'29'||'-'||p_anio;
       ELSE
          LET v_fch_fin = p_mes||'-'||'28'||'-'||p_anio;
       END IF
    END IF

LET v_fch_inic = v_fch_ini;

EXECUTE PROCEDURE bdicred:monthadd(v_fch_inic, 1) INTO V_FECHACESAR;

---LET v_fch_finc = EXTEND(v_fch_finc, YEAR TO DAY) + 1 UNITS DAY;


BEGIN

         ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            LET vCodRet  = SQL_ERR;
            LET vMensaje  = ERROR_INFO;
            RETURN vCodRet, vMensaje;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        FOREACH
        SELECT DISTINCT a.num_credito, b.num_tarjeta, b.nombre,
                        a.fecha_apertura
            INTO v_num_credito, v_num_tarjeta, v_nombre,
	             v_fecha_apertura
            FROM bdicred:sd_maecred a,
                 bdicred:sd_tarjeta b
            WHERE a.num_credito = b.num_credito
                AND a.empresa = '001'
                AND b.status_tar = 'A'
                AND b.tipo_tarjeta = 'T'
                AND b.empresa = a.empresa
                AND a.fecha_apertura between v_fch_inic AND v_fch_finc
            ORDER BY a.num_credito

	INSERT INTO mc_masterestad
         VALUES (v_num_credito, v_num_tarjeta, '001', v_nombre, v_fecha_apertura);

END FOREACH;

END

RETURN vCodRet, vMensaje;

END PROCEDURE;