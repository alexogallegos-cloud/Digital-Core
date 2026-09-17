CREATE PROCEDURE "informix".ugenera_layoutedocuenta(pempresa char(3),pperiodo date)
RETURNING CHAR(3);

DEFINE v_ruta      VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;
DEFINE v_sql        VARCHAR(200);

LET v_ruta  = "";
LET v_sql  = "";



 
BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

	-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

	SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';

	-----------------ENCABEZADO UNO---------------------------------------------------
	 LET v_sql = 'echo "UNLOAD TO '||v_ruta||'sd_encabezado_edocta'||YEAR(pperiodo)||MONTH(pperiodo)||DAY(pperiodo)||'.ban'||
	        ' SELECT * FROM sd_encabezado_edocta '||
	        ' WHERE fecha_emision ='''||pperiodo||'''"'||
	        ' > query.sql';
	 system v_sql;
	 LET v_sql = "dbaccess bdicred query.sql";
	 system v_sql;

	-----------------ENCABEZADO DOS---------------------------------------------------
     LET v_sql = 'echo "UNLOAD TO '||v_ruta||'sd_encabezado2_edocta'||YEAR(pperiodo)||MONTH(pperiodo)||DAY(pperiodo)||'.ban'||
            ' SELECT * FROM sd_encabezado2_edocta '||
            ' WHERE fecha_emision ='''||pperiodo||'''"'||
            ' > query.sql';
     system v_sql;
     LET v_sql = "dbaccess bdicred query.sql";
     system v_sql;
     
	-----------------DETALLE---------------------------------------------------
     LET v_sql = 'echo "UNLOAD TO '||v_ruta||'sd_detalle_edocta'||YEAR(pperiodo)||MONTH(pperiodo)||DAY(pperiodo)||'.ban'||
            ' SELECT * FROM sd_detalle_edocta '||
            ' WHERE fecha_emision ='''||pperiodo||'''"'||
            ' > query.sql';
     system v_sql;
     LET v_sql = "dbaccess bdicred query.sql";
     system v_sql;

	-----------------PIE DE PAGINA---------------------------------------------------
     LET v_sql = 'echo "UNLOAD TO '||v_ruta||'sd_pie_edocta'||YEAR(pperiodo)||MONTH(pperiodo)||DAY(pperiodo)||'.ban'||
            ' SELECT * FROM sd_pie_edocta '||
            ' WHERE fecha_emision ='''||pperiodo||'''"'||
            ' > query.sql';
     system v_sql;
     LET v_sql = "dbaccess bdicred query.sql";
     system v_sql;
     

  END;
  RETURN cod_ret;

END PROCEDURE ;