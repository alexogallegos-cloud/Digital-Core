CREATE PROCEDURE "informix".ugenera_layoutedocuenta_muestra(pempresa char(3),pperiodo date)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql       CHAR(5000);
DEFINE v_sql1      CHAR(1000);
DEFINE v_sql2      CHAR(1000);
DEFINE v_sql3      CHAR(1000);
DEFINE v_sql4      CHAR(800);
DEFINE v_sql5      CHAR(800);

LET v_ruta  = "";
LET v_sql  = "";
LET v_sql1="";
LET v_sql2="";
LET v_sql3="";
LET v_sql4="";
LET v_sql5="";

--  SET DEBUG FILE TO "ugenera_layoutedocuenta.out";
--  TRACE ON;

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

	-----------------ACLARACIONES---------------------------------------------------
 --    LET v_sql1 = 'echo "UNLOAD TO /pisa/pisabanco/pisa_ftes/axcred/descarga.unl';
 --    LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
 --           ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
 --           ' nvl ( secuencia,0),'||
 --           ' nvl ( nlinea,0),'||
 --           ' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
 --           ' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
 --          ' nvl ( importe,0) FROM sd_aclaraciones_edocta '||
 --           ' WHERE fecha_emision ='''||pperiodo||''' ORDER BY num_credito,secuencia,nlinea"'||
 --           ' > query.sql';
 --    LET v_sql = v_sql1||v_sql2;

--     system v_sql;

 --     LET v_sql = "dbaccess bdicred query.sql";
--	 system v_sql;

 --     LET v_sql = '';
 --     LET v_sql = "sed 's/|$//g' " ||v_ruta||'descarga.unl'||" >"|| v_ruta||'descarga1.unl' ;
 --     SYSTEM v_sql;

 --     LET v_sql = '';
 --     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " || --trim(v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
 --     SYSTEM v_sql;
	-----------------MENSAJES---------------------------------------------------
 --    LET v_sql1 = 'echo "UNLOAD TO /pisa/pisabanco/pisa_ftes/axcred/descarga.unl';
 --    LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
 --           ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
 --           ' nvl ( secuencia,0),'||
 --           ' nvl ( nlinea,0),'||
 --           ' nvl ( replace ( replace( si_paga, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
 --           ' nvl ( replace ( replace( mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta '||
 --           ' WHERE fecha_emision ='''||pperiodo||''' ORDER BY num_credito,secuencia,nlinea"'||
 --           ' > query.sql';
 --   LET v_sql = v_sql1||v_sql2;
 --    system v_sql;

--	 LET v_sql = "dbaccess bdicred query.sql";
--	 system v_sql;


--      LET v_sql = '';
 --     LET v_sql = "sed 's/|$//g' " ||v_ruta||'descarga.unl'||" >"|| v_ruta||'descarga1.unl' ;
--      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " || trim(v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
      SYSTEM v_sql;



	-----------------PIE DE PAGINA---------------------------------------------------
     LET v_sql1 = 'echo "UNLOAD TO /pisa/pisabanco/pisa_ftes/axcred/descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( tasa_anual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( cat, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( tasa_mora,0),'||
            ' nvl ( tasa_mensual_mora,0) FROM sd_pie_edocta '||
            ' WHERE fecha_emision ='''||pperiodo||'''"'||
            ' > query.sql';
     LET v_sql = v_sql1||v_sql2;
     system v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' " ||v_ruta||'descarga.unl'||" >"|| v_ruta||'descarga1.unl' ;
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " || trim(v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
      SYSTEM v_sql;

      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl'||" "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;


  END;
  RETURN cod_ret;

END PROCEDURE ;