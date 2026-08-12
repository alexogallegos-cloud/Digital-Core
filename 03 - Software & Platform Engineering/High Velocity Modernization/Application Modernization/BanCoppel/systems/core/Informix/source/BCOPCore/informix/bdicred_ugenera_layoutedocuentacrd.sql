CREATE PROCEDURE "informix".ugenera_layoutedocuentacrd(pempresa CHAR(3),pperiodo DATE)
--EXECUTE PROCEDURE ugenera_layoutedocuentacrd('001',MDY('07','18','2025'));
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255); 
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql       CHAR(5500);
DEFINE v_sql1      CHAR(1000);
DEFINE v_sql2      CHAR(1500);
DEFINE v_sql3      CHAR(1000);
DEFINE v_sql4      CHAR(1500);
DEFINE v_sql5      CHAR(1000);
DEFINE pperiodo1   DATE;
DEFINE pperiodo2   DATE;
DEFINE pperiodo3   DATE;

LET v_ruta		= "";
LET v_ruta_cfd	= ""; 
LET v_sql   	= "";
LET v_sql1  	= "";
LET v_sql2  	= "";
LET v_sql3  	= "";
LET v_sql4  	= "";
LET v_sql5  	= "";

 --SET DEBUG FILE TO "/RESPALDOSNEW/ulises/RQM/10_1478/archivoscartera/ugenera_layoutedocuentacrd.out";
 --TRACE ON;


-- Autor: Paul Ivan Quintero Varela
-- Fecha: 2009/07/24
-- Modificacion: Se realiza modificacion para obtener
--               la ruta donde se almacenaran los archivos
--               generados para creditos reestructurados
--               referenciando a tabla bdicred:sd_paramcrd asi
--               como el orden de los querys para la descarga
--               de los mismos.

BEGIN

  ON EXCEPTION SET sql_err
    IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        RETURN cod_ret;
    END IF
  END EXCEPTION;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

   LET cod_ret = "000";

	-----------------OBTENGO LA RUTA DONDE SE ALMACENARAN LOS ARCHIVOS---------------------------------------------------
	SELECT TRIM(valor) 
      INTO v_ruta 
      FROM "informix".sd_param
     WHERE empresa = pempresa 
       AND cod_param = '400';

	SELECT TRIM(valor) 
	  INTO v_ruta_cfd 
	  FROM sd_param 
	 WHERE empresa = pempresa 
	   AND cod_param = '037';

    ----------------SE GENERAN LOS ARCHIVOS DE LOS EDOS DE CUENTA DEL MES CORRIENTE------------------

    LET pperiodo1 = MDY(MONTH(pperiodo),02,YEAR(pperiodo));
    LET pperiodo2 = MDY(MONTH(pperiodo),17,YEAR(pperiodo));

	
	-----------------SE INSERTAN LOS CREDITOS DEL ENCABEZADO UNO---------------------------------------------------
	LET v_sql1 = 	' echo "UNLOAD TO '||v_ruta||'descargaRTB.unl '||
					' SELECT a.fecha_emision, a.num_credito, '' '', a.num_producto, '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '||
					' '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''0'' '||
					' FROM bdicred:sd_encabezado_edoctacrd a '||
					' WHERE fecha_emision = '''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''' AND num_credito = '''||61100||''' '||
					' and num_producto = '''||6011||''' '||
					' UNION ALL ';
	LET v_sql2 = 	' SELECT nvl ( fecha_emision,date(1)),'||
					' nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_cta_efec, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), ''  '' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace ( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
					' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
    LET v_sql3 =  	' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
					' nvl ( replace ( replace( replace ( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' nvl ( replace ( replace( sucursal_numero, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
    LET v_sql4 =  	' replace ( replace ( replace( replace ( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ''´'', '' ''),'||
					' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace ( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'|| 
					' nvl ( replace ( replace( confirmacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl((SELECT TRIM(NVL(b.cuenta_clabe,'' '')) FROM bdicred:sd_maecredcrd b where b.num_credito = a.num_credito), '' ''),'||
					' nvl ( replace ( replace( num_ciudad_coppel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_region, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( ec_edocta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''135''), '' ''),'||
					' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''136''), '' ''),'||
					' nvl ( replace ( replace( obj_imp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( base_cfdi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) ';
    LET v_sql5 =  	' FROM sd_encabezado_edoctacrd a '||
					' WHERE fecha_emision in ('''||TO_CHAR(pperiodo1,'%m/%d/%Y')||''','''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''') AND num_credito <> '''||61100||''' '||
					' AND num_producto = '''||6011||''' order by fecha_emision,num_credito" > '||trim(v_ruta)||'query.sql';
				  
	LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRTB.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'descargaRTB.unl';
    SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales_rt.sh ' ;
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "chmod 777 "||'eliminaespeciales_rt.sh ';
	SYSTEM v_sql;
	 
	LET v_sql = '';
    LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||             
					'\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
						'\"'||'])''//g'' '||v_ruta||'descargaRT1.unl'||" > "||v_ruta||'descargaRT2B.unl'||
							'" >>'||'eliminaespeciales_rt.sh ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "./"||'eliminaespeciales_rt.sh ';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT2B.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT2B.unl';
	SYSTEM v_sql;
	 
	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" >> " || trim(v_ruta||'Archivo61100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
	SYSTEM v_sql;
		 
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	 
	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||'eliminaespeciales_rt.sh ';
	SYSTEM v_sql;
 
	-----------------SE INSERTAN LOS CREDITOS DEL ENCABEZADO DOS CFDI 3.3 -------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||trim(v_ruta)||'descargaRT.unl '||
					' SELECT a.fecha_emision, a.num_credito, 0, 0, 0, '' '', 0, 0, 0, 0, 0, '||
					' 0, 0, a.fecha_limite_tc,  a.periodo_tc_ini, a.periodo_tc_fin, a.fecha_corte_tc, '' '', 0, a.fecha_otorgamiento_tc, 0, 0, 0, 0, 0, 0 '||
					' FROM sd_encabezado2_edoctacrd a WHERE fecha_emision = '''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''' '|| 
					' and num_credito = '''||61200||''' '||
					' UNION ALL ';
    LET v_sql2 =	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.capital_tc,0),'||
					' nvl ( a.interes_tc,0),'||
					' nvl ( a.iva_interes_tc,0),'||
					' nvl ( replace ( replace( a.numero_pago_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( a.monto_pago,0),'||
					' nvl ( a.capital_ven_tc,0),'||
					' nvl ( a.interes_ven_tc,0),'||
					' nvl ( a.iva_interes_ven_tc,0),'||
					' nvl ( a.moratorios_tc,0),'||
					' nvl ( a.iva_moratorios_tc,0),'||
					' nvl ( a.pago_total_tc,0),'||
					' nvl ( a.fecha_limite_tc,date(1)),'||
					' nvl ( a.periodo_tc_ini,date(1)),'||
					' nvl ( a.periodo_tc_fin,date(1)),'||
					' nvl ( a.fecha_corte_tc,date(1)),'||
					' nvl ( replace ( replace( a.dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( a.monto_credito_tc,0),'||
					' nvl ( a.fecha_otorgamiento_tc,date(1)),';
    LET v_sql3 =	' nvl ( a.comisiones_efec_cargadas,0),'||
					' nvl ( a.intereses_efec_pag,0), '||
					' nvl ( a.descuento,0), '||
					' nvl ( a.subtotal,0), '||
					' nvl ( a.total,0), '||
					' nvl ( val_base_cfdi,0) '||
					' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b WHERE a.fecha_emision in ('''||TO_CHAR(pperiodo1,'%m/%d/%Y')||''','''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''') '||
					' and a.fecha_emision = b.fecha_emision and a.num_credito <> '''||61200||''' and a.num_credito = b.num_credito '||
					' and b.num_producto = '''||6011||''' ORDER BY a.fecha_emision,a.num_credito" '||
					' > '||trim(v_ruta)||'query2.sql';
					
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query2.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRT.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT1.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" >> " ||trim(v_ruta)||'Archivo61200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
 
	-----------------SE INSERTAN LOS CREDITOS DEL DEL DETALLE ---------------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||trim(v_ruta)||'descargaRT.unl '||
					' SELECT a.fecha_emision, a.num_credito, a.secuencia , a.nlinea, '' '',  '' '', '' '', '' '' '||
					' FROM sd_detalle_edoctacrd a '||
					' WHERE fecha_emision = '''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''' and num_credito = '''||61300||''' '||
					' UNION ALL '; 
	LET v_sql2 =	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.secuencia,0),'||
					' nvl ( a.nlinea,0),'||
					' nvl ( a.fecha_mov,date(1)),'||
					' nvl ( a.concepto,0),'||
					' nvl ( a.cargos,0),'||
					' nvl ( a.abonos,0)'||
					' FROM sd_detalle_edoctacrd a, sd_encabezado_edoctacrd b '||
					' WHERE a.fecha_emision in ('''||TO_CHAR(pperiodo1,'%m/%d/%Y')||''','''||TO_CHAR(pperiodo2,'%m/%d/%Y')||''') '|| 
					' and a.fecha_emision = b.fecha_emision  and a.num_credito <> '''||61300||''' and a.num_credito = b.num_credito '||
					' and b.num_producto = '''||6011||''' ORDER BY a.fecha_emision,a.num_credito,a.secuencia,nlinea" '||
					' > '||trim(v_ruta)||'query3.sql';
			
	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query3.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRT.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT1.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" >> " ||trim(v_ruta)||'Archivo61300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	-----------------ACLARACIONES---------------------------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||trim(v_ruta)||'descargaRT.unl '||
					' SELECT fecha_emision, num_credito, secuencia, nlinea, fecha_aclara, '' '', fecha_mov, '' '', 0 '||
					' FROM sd_aclaraciones_edoctacrd WHERE fecha_emision = '''||pperiodo2||''' '||
					' and num_credito = '''||61400||''' '||
					' UNION ALL ';
	LET v_sql2 = 	' SELECT nvl ( fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( secuencia,0),'||
					' nvl ( nlinea,0),'||
					' nvl ( fecha_aclara,date(1)),'||
					' nvl ( replace ( replace( folio_suc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( fecha_mov,date(1)),'||
					' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( importe,0) FROM sd_aclaraciones_edoctacrd '||
					' WHERE fecha_emision in ('''||pperiodo1||''','''||pperiodo2||''') and num_credito = "61400" ORDER BY fecha_emision,num_credito,secuencia,nlinea"'||
					' > '||trim(v_ruta)||'query4.sql';
					
	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query4.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRT.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT1.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" > "||trim(v_ruta)||'Archivo61400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

	-----------------SE INSERTAN LOS MENSAJES DE LOS CREDITOS---------------------------------------------
    LET v_sql1 =	' echo "UNLOAD TO '||trim(v_ruta)||'descargaRT.unl '||
					' SELECT a.fecha_emision, a.num_credito, a.secuencia, a.nlinea, '' '', '' '' '||
					' FROM sd_mensajes_edoctacrd a '||
					' WHERE fecha_emision = '''||pperiodo2||''' AND num_credito =  "61500" '||
					' UNION ALL ';
    LET v_sql2 =	' SELECT nvl (a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( b.secuencia,0),'||
					' nvl ( b.nlinea,0),'||
					' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( b.mensaje, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd a '||
					' LEFT OUTER JOIN bdicred:sd_mensajes_mensual_edoctacrd b on a.fecha_emision = b.fecha_emision'||
					' WHERE a.fecha_emision in ('''||pperiodo1||''','''||pperiodo2||''') AND a.secuencia = 1 AND a.nlinea = 1 AND num_credito <> "61500 and a.num_producto = '''||6011||'''" '||
					' AND a.num_producto = b.num_producto'||
					' UNION ALL '||
					' SELECT fecha_emision, num_credito, secuencia, nlinea, NVL(si_paga,'' ''), mensajes FROM bdicred:sd_mensajes_edoctacrd a'||
					' WHERE a.fecha_emision in ('''||pperiodo1||''','''||pperiodo2||''') AND num_credito <> "61500" and a.num_producto = '''||6011||''' ORDER BY 2,3,4" '||
					' > '||trim(v_ruta)||'query5.sql';

	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query5.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRT.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT1.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" >> "||trim(v_ruta)||'Archivo61500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	-----------------DATOS DEL PIE DE PAGINA---------------------------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||trim(v_ruta)||'descargaRT.unl '||
					' SELECT a.fecha_emision, a.num_credito, 0, 0, 0, '' '', 0, 0 '|| 
					' FROM sd_pie_edoctacrd a'||
					' WHERE a.fecha_emision = '''||pperiodo2||''' and a.num_credito = '''||61600||''' '||
					' UNION ALL '; 
	LET v_sql2 =	' SELECT nvl (a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.tasa_anual,0),'||
					' nvl ( a.tasa_mensual,0),'||
					' nvl ( a.tasa_mora_anual,0),'||
					' case when nvl ( a.tasa_mora_mensual,0) - (trim(nvl ( a.tasa_mora_mensual,0)::CHAR(2))::int ) = 0 THEN '||
					' (trim(nvl ( a.tasa_mora_mensual,0)::CHAR(2)))||''.00'' '||
					' else '||
					' (trim(nvl ( a.tasa_mora_mensual,0)::CHAR(2)))||substr(rpad(nvl ( a.tasa_mora_mensual,0) - (trim(nvl ( a.tasa_mora_mensual,0)::CHAR(2))::int ),4,0),2,3) '||
					' end,'||
					' nvl ( round(a.cat,1),0),'||
					' nvl ( a.saldo_insoluto,0 ) FROM sd_pie_edoctacrd a, sd_encabezado_edoctacrd b'||
					' WHERE a.fecha_emision in ('''||pperiodo1||''','''||pperiodo2||''') and a.fecha_emision = b.fecha_emision '||
					' and a.num_credito = b.num_credito and b.num_producto = '''||6011||''' ORDER BY a.fecha_emision" '||
					' > '||trim(v_ruta)||'query6.sql';
			
	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred "||trim(v_ruta)||"query6.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||trim(v_ruta)||'descargaRT.unl'||" >"||trim(v_ruta)||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaRT1.unl'||" >"||v_ruta||'descargaRT2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaRT1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||trim(v_ruta)||'descargaRT2.unl'||" >> " ||trim(v_ruta)||'Archivo61600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'descargaRT2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo61600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

----------------------------------------------------------------------------------------------------------------------------------------------	 
  -- Mover archivos a la ruta del CFDI

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
			   
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql; 
	 
 	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql; 
	 	 
	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql; 
	
	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo61600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
			   trim(v_ruta_cfd) ||'Archivo61600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;  

-----------------------------------------------------------------------
	-- ELIMINAR QUERYS
	
	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'query.sql';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'query2.sql';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'query3.sql';
	SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||trim(v_ruta)||'query4.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'query5.sql';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||trim(v_ruta)||'query6.sql';
	SYSTEM v_sql;

	
  END;
  RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Se realiza procedimiento para generar los archivos',
'de cada una de las tablas que componen el estado de',
'cuenta para creditos reestructurados',
'AUTOR : Bernardo Baez',
'FECHA : 23/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".ugenera_layoutedocuentacrdpp(pempresa CHAR(3),pperiodo DATE)
--EXECUTE PROCEDURE ugenera_layoutedocuentacrdpp('001',MDY('07','18','2025'));
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql       CHAR(6000);
DEFINE v_sql1      CHAR(1000);
DEFINE v_sql2      CHAR(1500);
DEFINE v_sql3      CHAR(1000);
DEFINE v_sql4      CHAR(1500);
DEFINE v_sql5      CHAR(1500);
DEFINE pperiodo1   DATE;
DEFINE pperiodo2   DATE;
DEFINE pperiodo3   DATE;

LET v_ruta  = "";
LET v_ruta_cfd = "";
LET v_sql   = "";
LET v_sql1  = "";
LET v_sql2  = "";
LET v_sql3  = "";
LET v_sql4  = "";
LET v_sql5  = "";

--SET DEBUG FILE TO "/informix/David/RQI_21_394/trace_ugenera_layoutedocuentacrd.txt";
--TRACE ON;

-- Autor: Leonardo Hernandez Moreno
-- Fecha: 2009/07/24
-- Modificacion: Se realiza modificacion para obtener
--               la ruta donde se almacenaran los archivos
--               generados para creditos reestructurados
--               referenciando a tabla bdicred:sd_paramcrd asi
--               como el orden de los querys para la descarga
--               de los mismos.

BEGIN

  ON EXCEPTION SET sql_err
    IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        RETURN cod_ret;
    END IF
  END EXCEPTION;

  SET ISOLATION TO DIRTY READ ;
  SET LOCK MODE TO WAIT 3 ;


   LET cod_ret = "000";

	-----------------OBTENGO LA RUTA DONDE SE ALMACENARAN LOS ARCHIVOS---------------------------------------------------
	SELECT TRIM(valor) 
      INTO v_ruta 
      FROM "informix".sd_param
     WHERE empresa = pempresa 
       AND cod_param = '400';
	   
	SELECT TRIM(valor) 
	  INTO v_ruta_cfd 
	  FROM sd_param 
	 WHERE empresa = pempresa 
	   AND cod_param = '037';


    ----------------SE GENERAN LOS ARCHIVOS DE LOS EDOS DE CUENTA DEL MES CORRIENTE------------------

--      LET pperiodo1 = MDY(MONTH(mdy('01','01','2012') - 1 UNITS MONTH),17,YEAR(mdy('01','01','2011')));
      --LET pperiodo1 = mdy(month(date(monthadd(today, -1))),17,year(today));
     LET pperiodo1 = mdy(month(date(monthadd(pperiodo, -1))),17,year((monthadd(pperiodo, -1)))); 
     LET pperiodo2 = MDY(MONTH(pperiodo),17,YEAR(pperiodo)); 

------------------------------------------------------------------------------------------------------------------------------------------------	 
	 --- ARCHIVO 100 DE CFDI con la atencion del RQI 12 379 Inclusion de Correo Electronico en Archivos de TDC PIQV
	LET v_sql1 =	' echo "UNLOAD TO '||v_ruta||'descargaPPB.unl '||
					' SELECT a.fecha_emision, a.num_credito, '' '', a.num_producto, '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '||
					' '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', '' '', ''0'' '||
					' FROM bdicred:sd_encabezado_edoctacrd a WHERE fecha_emision = '''||TO_CHAR(pperiodo2,'%m/%d/%Y') ||''' AND num_credito IN (''6300100'',''7600100'',''7700100'',''6800100'',''9100100'',''9300100'') '||
					' UNION ALL ';
	LET v_sql2 = 	' SELECT nvl ( fecha_emision,date(1)),'||
					' nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_cta_efec, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), ''  '' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace ( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
					' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  	' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
					' nvl ( replace ( replace( replace ( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' nvl ( replace ( replace( sucursal_numero, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  	' replace ( replace ( replace( replace ( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ), ''´'', '' ''),'||
					' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( replace ( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), ''´'', '' ''), '' '' ),'||
					' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
					' nvl ((SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
					' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
					' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' '||
					' AND b.numcte not in (select c.numcte from bdinteg:"informix".si_altaserv_edoctamov c where c.empresa = ''001'' and c.numcte = b.numcte)),'' '') ,'||
					' nvl ( replace ( replace( confirmacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( ind_tabla_amortizacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl((SELECT TRIM(NVL(b.cuenta_clabe,'' '')) FROM bdicred:sd_maecredcrd b where b.num_credito = a.num_credito), '' ''),'||
					' nvl ( replace ( replace( num_ciudad_coppel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( num_region, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( ec_edocta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql5=  	' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''135''), '' ''),'||
					' nvl ((SELECT TRIM(valor) FROM sd_param WHERE empresa = ''' || pempresa || ''' AND cod_param = ''136''), '' ''),'||
					' nvl ( replace ( replace( obj_imp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( base_cfdi, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) '||
					' FROM sd_encabezado_edoctacrd a '|| 
					' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y') || ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y') ||''' '||
					' AND num_producto in(''6300'',''7600'',''7700'',''6800'',''9100'',''9300'') AND num_credito NOT IN (''6300100'',''7600100'',''7700100'',''6800100'',''9100100'',''9300100'') order by fecha_emision,num_credito" > query_100B.sql';
					
	LET v_sql = TRIM(v_sql1)||' '||TRIM(v_sql2)||v_sql3||v_sql4||v_sql5;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_100B.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPPB.unl'||" >"||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPPB.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales_pp.sh ' ;
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "chmod 777 "||'eliminaespeciales_pp.sh ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||             
					'\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
						'\"'||'])''//g'' '||v_ruta||'descargaPP1.unl'||" > "||v_ruta||'descargaPP2B.unl'||
							'" >>'||'eliminaespeciales_pp.sh ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "./"||'eliminaespeciales_pp.sh ';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP2B.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2B.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" >> " || trim(v_ruta||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||'eliminaespeciales_pp.sh ';
	SYSTEM v_sql;
	 

-----------------SE INSERTAN CREDITOS DEL ENCABEZADO DOS CFDI 3.3 -------------------------------	
	LET v_sql1 =	' echo "UNLOAD TO ' || v_ruta || 'descargaPP.unl '||
					' SELECT a.fecha_emision, a.num_credito, 0, 0, 0, '' '', 0, 0, 0, 0, 0, 0, 0, a.fecha_limite_tc, a.periodo_tc_ini, a.periodo_tc_fin, a.fecha_corte_tc, '' '', '||
					' 0, a.fecha_otorgamiento_tc, 0, 0, 0, '' '','' '', 0, fecha_otorgamiento_tc, 0, fecha_ult_disposicion, '' '', '' '', '' '', '' '' '||
					' FROM sd_encabezado2_edoctacrd a '||
					' WHERE a.fecha_emision = ''' || pperiodo2 || ''' and a.num_credito IN (''6300200'',''7600200'',''7700200'',''6800200'',''9100200'',''9300200'') '||
					' UNION ALL ';
	LET v_sql2 =	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl(a.capital_tc,0), '||
					' nvl(a.interes_tc,0), '||
					' nvl(a.iva_interes_tc,0), '||
					' nvl(replace(replace(a.numero_pago_tc, ''|'', '' ''), ''\'', '' ''), ''0''), '||
					' nvl(a.monto_pago,0), '||
					' nvl(a.capital_ven_tc,0), '||
					' nvl(a.interes_ven_tc,0), '||
					' nvl(a.iva_interes_ven_tc,0), '||
					' nvl(a.moratorios_tc,0), '||
					' nvl(a.iva_moratorios_tc,0), '||
					' nvl(a.pago_total_tc,0), '||
					' nvl(a.fecha_limite_tc, date(1)), '||
					' nvl(a.periodo_tc_ini, date(1)), '||
					' nvl(a.periodo_tc_fin, date(1)), '||
					' nvl(a.fecha_corte_tc, date(1)), '||
					' nvl(replace(replace(a.dias_periodo_tc, ''|'', '' ''), ''\'', '' ''), ''0''), '||
					' nvl(a.monto_credito_tc,0), '||
					' nvl(a.fecha_otorgamiento_tc, date(1)), '||
					' nvl(a.comisiones_efec_cargadas,0), '||
					' nvl(a.intereses_efec_pag,0), '||
					' nvl(a.descuento,0), '||
					' CAST(nvl ( subtotal,0) AS CHAR(18)), '||
					' CAST(nvl ( total,0) AS CHAR(18)), '||
					' nvl ( linea_autorizada,0), '||
					' nvl ( fecha_otorgamiento_tc,date(1)), '||
					' nvl ( monto_credito_tc,0),'||
					' nvl ( fecha_ult_disposicion,date(1)), '||
					' CAST(nvl(a.val_base_cfdi,0) AS CHAR(18)), '||
					' CAST(nvl(a.iva_intereses_reales_cfdi,0) AS CHAR(18)), '||
					' CAST(nvl(a.intereses_reales_cfdi,0) AS CHAR(18)), '||
					' CAST(nvl(a.iva_cfdi,0) AS CHAR(18)) ';
	LET v_sql3 =	' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b '||
					' WHERE a.fecha_emision > ''' || pperiodo1 || ''' AND a.fecha_emision <= ''' || pperiodo2 || ''' '||
					' and a.num_credito <> ''6300200'' and a.fecha_emision = b.fecha_emision and a.num_credito = b.num_credito '||
					' and b.num_producto in (''6300'', ''6800'', ''7600'', ''7700'', ''9100'', ''9300'') '||
					' ORDER BY a.fecha_emision, a.num_credito" '||
					' > query_200B.sql';
			  
	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_200B.sql";
	SYSTEM v_sql;
	 
	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPP.unl'||" >"||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP1.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" >> " ||v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	----------------------------------------------------------------------------------------------------------------------------------------

	-----------------SE INSERTAN LOS CREDITOS DEL DEL DETALLE ---------------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||v_ruta||'descargaPP.unl '||
					' SELECT a.fecha_emision, a.num_credito, secuencia, nlinea, '' '', '' '', '' '', '' '' '||
					' FROM sd_detalle_edoctacrd a '||
					' WHERE a.fecha_emision = '''||pperiodo2 ||''' and a.num_credito IN (''6300300'',''7600300'',''7700300'',''6800300'',''9100300'',''9300300'') '||
					' UNION ALL '; 
	LET v_sql2 =	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.secuencia,0), '||
					' nvl ( a.nlinea,0), '||
					' nvl ( a.fecha_mov,date(1)), '||
					' nvl ( a.concepto,0), '||
					' nvl ( a.cargos,0), '||
					' nvl ( a.abonos,0) '||
					' FROM sd_detalle_edoctacrd a, sd_encabezado_edoctacrd b '||
					' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2 ||''' '||
					' and a.fecha_emision = b.fecha_emision and a.num_credito <> ''6300300'' and a.num_credito = b.num_credito '||
					' and b.num_producto in(''6300'',''7600'',''7700'',''6800'',''9100'',''9300'') ORDER BY a.fecha_emision,a.num_credito,a.secuencia,nlinea " '||
					' > querys_300.sql';

	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred querys_300.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPP.unl'||" >"||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP1.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" >> " ||v_ruta||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;
	

	-----------------ACLARACIONES---------------------------------------------------
	LET v_sql1 =	' echo "UNLOAD TO '||v_ruta||'descargaPP.unl '||
					' SELECT fecha_emision, num_credito, secuencia, nlinea, fecha_aclara, '' '', fecha_mov, '' '', 0 '||
					' FROM sd_aclaraciones_edoctacrd '||
					' WHERE fecha_emision = '''||pperiodo2|| ''' and num_credito IN (''6300400'',''7600400'',''7700400'',''6800400'',''9100400'',''9300400'') '||
					' UNION ALL ';
	LET v_sql2 =	' SELECT nvl ( fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( secuencia,0),'||
					' nvl ( nlinea,0),'||
					' nvl ( fecha_aclara,date(1)),'||
					' nvl ( replace ( replace( folio_suc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( fecha_mov,date(1)),'||
					' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( importe,0) FROM sd_aclaraciones_edoctacrd '||
					' WHERE fecha_emision >'''||pperiodo1||''' AND fecha_emision <= '''||pperiodo2|| ''' and num_credito <> ''6300400'' '||
					' ORDER BY fecha_emision, num_credito, secuencia, nlinea" '||
					' > query_400.sql'; 
				  
	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_400.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPP.unl'||" >"||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP1.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" > "||v_ruta||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	 -----------------SE INSERTAN LOS MENSAJES DE LOS CREDITOS 500B CFDI---------------------------------------------
	LET v_sql1 = 	' echo "UNLOAD TO '||v_ruta||'descargaPP.unl '||
					' SELECT a.fecha_emision, a.num_credito, 0 as clave, '' '', '' '', '' '' '||
					' FROM sd_mensajes_edoctacrd a '||
					' WHERE a.fecha_emision = '''||pperiodo2|| ''' AND a.num_credito IN (''6300500'',''7600500'',''7700500'',''6800500'',''9100500'',''9300500'') '||
					' UNION ALL ';
	LET v_sql2 = 	' SELECT nvl (a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' (clave + 1 -200)::integer,'||
					' ''1'','||
					' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					' nvl ( replace ( replace( b.mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd a '||
					' left join   bdicred:sd_config_mensaje_edocta b on b.num_producto = a.num_producto '||
					' where a.num_credito =a.num_credito and a.secuencia= ''1'' '||
					' and a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| ''' '||
					' and a.num_credito not in(''6300500'',''7600500'',''7700500'',''6800500'',''9100500'',''9300500'') '||
					' and a.num_producto in(''6300'',''7600'',''7700'',''6800'',''9100'',''9300'')'||
					' order by a.num_credito,clave "'||
					' > query_500B.sql';
					
	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_500B.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPP.unl'||" >"||v_ruta||'descargaPP1z.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP1z.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1z.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" >> "||v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	-----------------DATOS DEL PIE DE PAGINA---------------------------------------------------
	LET v_sql1 = 	' echo "UNLOAD TO '||v_ruta||'descargaPP.unl '||
					' SELECT a.fecha_emision, a.num_credito, 0, 0, 0, 0, 0, 0 '|| 
					' FROM sd_pie_edoctacrd a'||
					' WHERE a.fecha_emision = '''||pperiodo2|| ''' and a.num_credito IN (''6300600'',''7600600'',''7700600'',''6800600'',''9100600'',''9300600'') '||
					' UNION ALL '; 
	LET v_sql2 = 	' SELECT nvl(a.fecha_emision,date(1)),'||
					' trim(nvl(replace(replace(a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl(a.tasa_anual,0),'||
					' nvl(a.tasa_mensual,0),'||
					' nvl(a.tasa_mora_anual,0),'||
					' nvl(a.tasa_mora_mensual,0),'||
					' nvl(round(a.cat,1),0),'||
					' nvl(a.saldo_insoluto,0) FROM sd_pie_edoctacrd a, sd_encabezado_edoctacrd b'||
					' WHERE a.fecha_emision > '''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2||''' '||
					' and a.fecha_emision = b.fecha_emision and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'',''6800'',''9100'',''9300'') ORDER BY a.fecha_emision"'||
					' > query_600.sql';

	LET v_sql = v_sql1||v_sql2;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_600.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPP.unl'||" >"||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descargaPP1.unl'||" >"||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP1.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPP2.unl'||" >> " ||v_ruta||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descargaPP2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	-----------------SE INSERTAN DETALLE DEL FORMATO TAABLA DE AMORTIZACION---------------------------------------
	LET v_sql1 = 	' echo "UNLOAD TO '||v_ruta||'descarga800.unl '||
					' SELECT today -1 as fecha_emision, ''6300800'' as num_credito, 0, '' '' as num_periodo, today -1 as fecha_pago, 0, 0, 0, 0, 0, 0, 0, 0, 0 '||
					' UNION ALL ';
	LET v_sql2 = 	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.monto_ahorro,0),'||
					' nvl ( a.num_periodo,0),'||
					' nvl ( a.fecha_pago,date(1)),'||
					' nvl ( a.pago_capital,0),'||
					' nvl ( a.intereses,0),'||
					' nvl ( a.iva_intereses,0),'||
					' nvl ( a.monto_pago,0),'||
					' nvl ( a.saldo_insoluto,0),'||
					' nvl ( a.sum_capital,0),'||
					' nvl ( a.sum_intereses,0),'||
					' nvl ( a.sum_iva_intereses,0),'||
					' nvl ( a.sum_pagomin,0)'||
					' FROM sd_amortizacion_creditoedoctacrd a, sd_encabezado_edoctacrd b '||
					' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2 ||''' '|| 
					' and a.fecha_emision = b.fecha_emision  and a.num_credito = b.num_credito and a.num_periodo = ''0'' '|| 
					' UNION ALL ';
	LET v_sql3 = 	' SELECT nvl ( a.fecha_emision,date(1)),'||
					' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					' nvl ( a.monto_ahorro,0),'||
					' nvl ( a.num_periodo,0),'||
					' nvl ( a.fecha_pago,date(1)),'||
					' nvl ( a.pago_capital,0),'||
					' nvl ( a.intereses,0),'||
					' nvl ( a.iva_intereses,0),'||
					' nvl ( a.monto_pago,0),'||
					' nvl ( a.saldo_insoluto,0),'||
					' nvl ( a.sum_capital,0),'||
					' nvl ( a.sum_intereses,0),'||
					' nvl ( a.sum_iva_intereses,0),'||
					' nvl ( a.sum_pagomin,0)'||
					' FROM sd_amortizacion_creditoedoctacrd a, sd_encabezado_edoctacrd b '||
					' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2||''' '||
					' and a.fecha_emision = b.fecha_emision  and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'',''6800'',''9100'',''9300'') '||
					' and a.num_periodo <> ''0'' ORDER BY fecha_emision,num_credito,num_periodo "'||
					' > query_800.sql';

	LET v_sql = v_sql1||v_sql2||v_sql3;
	SYSTEM v_sql;

	LET v_sql = "dbaccess bdicred query_800.sql";
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga800.unl'||" >"||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga800.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "sed 's/\\//g' "||v_ruta||'descarga1800.unl'||" >"||v_ruta||'descarga2.unl';
	SYSTEM v_sql;
	
	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga1800.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" >> " ||v_ruta||'Archivo63800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "rm "||v_ruta||'descarga2.unl';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	SYSTEM v_sql;

	---------  COPIA ARCHIVOS CREADOS A LA DE CFD -------------------

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
					   trim(v_ruta_cfd) ||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = "mv " || v_ruta|| 'Archivo63800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
				   trim(v_ruta_cfd) ||'Archivo63800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
	SYSTEM v_sql;
	  
	--FIN DE COPIAR A LA RUTA DE CFD.

	-- ELIMINAR QUERYS

	LET v_sql = '';
	LET v_sql = 'rm query_100B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query_200B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm querys_300.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query_400.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query_500B.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query_600.sql ';
	SYSTEM v_sql;

	LET v_sql = '';
	LET v_sql = 'rm query_800.sql ';
	SYSTEM v_sql;
		

  END;
  RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Se realiza procedimiento para generar los archivos',
'de cada una de las tablas que componen el estado de',
'cuenta para creditos reestructurados',
'AUTOR : Bernardo Baez',
'FECHA : 23/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultadatos_motor(pEmpresa CHAR(4), pNumSol CHAR(20))
RETURNING
	CHAR(6) 	   as cCodRet,
	CHAR(20)	   as cSolBanco,
	CHAR(20)	   as cNumCteBco,
	CHAR(20) 	   as cNumCte,
	CHAR(4)		   as pEmpresa,
	CHAR(2)		   as cStatusSolicitud,
	CHAR(3)		   as cCausa_Sol,
	CHAR(4)		   as cNum_Producto,
	CHAR(2)		   as cTipoGrupo,
	CHAR(1)		   as cTp_solicitud,
	CHAR(20)	   as cB_INE,
	CHAR(50)	   as cHabita_en,
	CHAR(1)		   as cPuntualidadCoppel,
	CHAR(3)		   as cProfesion,
	INTEGER 	   as iCredDigitalesAct,
	SMALLINT	   as sId_actividad,
	CHAR(60)	   as cDescAct,
	SMALLINT	   as sId_subactividad,
	CHAR(50)	   as vDescSubAct,
	CHAR(1)		   as cSituacionEspecial,
	SMALLINT 	   as sCausaSituacion,
	CHAR(1)		   as cMotivoRech,
	CHAR(1)		   as cMotivoRechBcpl,
	CHAR(1) 	   as cTipoRech,
	CHAR(300) 	   as cDescMvo,
	MONEY 		   as mTotalVencido,
	MONEY  		   as mAbonoTotal,
	MONEY		   as mAbonoVencidoTotal,
	SMALLINT 	   as sHist_meses,
	CHAR(20) 	   as cCteExcep,
	INTEGER 	   as iCtas_StatusCV,
	INTEGER 	   as iMaxSalVencidoBancoppel,
	DECIMAL(5,2)   as dEficienciaCoppel,
	INTEGER		   as iCred_StatusFC,
	INTEGER		   as iCred_StatusFF_restru,
	INTEGER		   as iCredits_riesgoD,
	INTEGER		   as iCredits_riesgoE,
	INTEGER		   as iCredits_riesgoC,
	INTEGER		   as iMaxMontoReserva,
	INTEGER		   as iCred_StatusDif_FF,
	DECIMAL(18,2)  as dMaxSalVencidoCRD,
	INTEGER		   as iCuentasStatusCVsinFF,
	INTEGER		   as iCtas_StatusDif_FF_6011,
	INTEGER		   as iCredRiesgoD_sinFF,
	INTEGER		   as iCredRiesgoE_sinFF,
	INTEGER		   as iCredRiesgoC_sinFF,
	DECIMAL(18,2)  as dmaxMontoReservaRiesgoC_sinFF,
	CHAR(10) 	   as dtMinFechaAperturasinFF,
	CHAR(10) 	   as dtMinFechaApertura,
	CHAR(1)		   as cSituacion,
	CHAR(10) 	   as dtmaxFechaAperturaDelProducto,
	CHAR(4)		   as cProducto,
	DECIMAL(6,2)   as dminProcentajeProductoMasReciente,
	MONEY		   as mAbonoMuebles,
	MONEY		   as mAbonoPrestamos,
	MONEY		   as mAbonoRopa,
	MONEY		   as mAbonoAire,
	MONEY		   as mAbonoAfiliados,
	MONEY		   as mAbonoReestructura,
	MONEY		   as mVencidoMuebles,
	MONEY		   as mVencidoRopa,
	MONEY		   as mVencidoPrestamos,
	MONEY		   as mVencidoAire,
	MONEY		   as mVencidoAfiliados,
	MONEY		   as mVencidoReestructura,
	CHAR(13)	   as cFechaUltimoPago,
	INTEGER 	   as iReprestamos,
	CHAR(1)		   as cOrigenSol,
	CHAR(60)	   as cDescripcion,
	CHAR(1)		   as cRiesgoViviendaCpl,
	CHAR(1)		   as cRiesgoViviendaBcpl,
	CHAR(1)		   as cActRiesgoCpl,
	CHAR(1)		   as cActRiesgoBCpl,
	CHAR(1)	   	   as cDescpRiesgo,
	CHAR(1)		   as cEjecucion,
	INTEGER 	   as iMax_MOP,
	CHAR(2)		   as cInstCta_MayorMOP,
	DECIMAL(14,2)  as dMonto_UDIS_MayorMOP,
	INTEGER		   as iMax_MOP_Hist_6m,
	CHAR(2)		   as cInstCta_MayorMOP_6m,
	DECIMAL(14,2)  as dMontoUDIS_MM_6m,
	INTEGER		   as iMM_Histo_12m,
	CHAR(2)		   as cInstCta_MayorMOP_12m,
	DECIMAL(14,2)  as dMontoUDIS_MM_12m,
	INTEGER		   as iNumCtasMOP_4_12m,
	INTEGER		   as iNumCtasMOP_5_12m,
	INTEGER		   as iNumCtasMOP_mayor5_12m,
	INTEGER		   as iMOP4_12mCon1o2,
	INTEGER		   as iMOP5_12mCon1o2,
	INTEGER		   as iMOPmayor5_12mCon1o2,
	CHAR(2)		   as cInstitucionMMOP_provocaRech,
	DECIMAL(14,2)  as dMontoUDIS_MM_Rech,
	INTEGER  	   as iNumCtasMOP_4_30m,
	INTEGER  	   as iNumCtasMOP_5_30m,
	INTEGER  	   as iNumCtasMOP_mayor5_30m,
	INTEGER  	   as iCtasMOP_4_30mCon1o2,
	INTEGER  	   as iCtasMOP_5_30mCon1o2,
	INTEGER  	   as iCtasMOP_mayor5_30mCon1o2,
	INTEGER  	   as iMM_Histo_30m,
	CHAR(2)  	   as cInstCta_MM_30m_Rech,
	DECIMAL(14,2)  as dMotoUDIS_MM_30m_Rech,
	INTEGER  	   as iNumCtas_ClvOb,
	DECIMAL(14,2)  as dMontoUdis,
	CHAR(2)  	   as cInstitucion,
	CHAR(2)  	   as cClvObser,
	SMALLINT  	   as sBc_Score,
	VARCHAR(04)    as vClvExclusionMasReciente,
	CHAR(2)		   as cInstitucionClvExclusionMasReciente,
	INTEGER  	   as iCtas_SinComServ,
	INTEGER 	   as iCtas_SinComServ_pagar,
	INTEGER  	   as iNumCtas_SHBr,
	INTEGER  	   as iNumCtas_SHBr_pagar,
	INTEGER 	   as BC1,
	INTEGER  	   as BC_101,
	INTEGER  	   as iMM_act_Bancos,
	INTEGER  	   as iMM_hist_alto_Bancos,
	INTEGER  	   as iMM_hist_Bancos,
	INTEGER  	   as BC_117,
	INTEGER  	   as iCtasBancosMOP_tl26,
	INTEGER  	   as iCtasBancosMOP_tl38,
	INTEGER 	   as iCtasBancosMOP_tl27,
	INTEGER  	   as iCtasBancosMOP_act_hist_alto,
	INTEGER 	   as BC_119,
	INTEGER 	   as iCtasComServMOP_tl26,
	INTEGER  	   as iCtasComServMOP_tl38,
	INTEGER 	   as iCtasComServMOP_tl27,
	INTEGER  	   as iCtasCSM_act_hist_alto,
	INTEGER 	   as BC_20,
	INTEGER 	   as iCtasComServMOP_tl26_12m,
	INTEGER 	   as iCtasComServMOP_tl38_12m,
	INTEGER 	   as iCtasComServMOP_tl27_12m,
	INTEGER		   as iCtasCSM_ActHistAlto_12m,
	DECIMAL(18,2)  as BC_421,
	CHAR(10)	   as dtFechaAux,
	INTEGER		   as BC_85,
	INTEGER		   as iMaxMOP_actBancos,
	INTEGER		   as iMaxMOP_histAltBancos,
	INTEGER		   as iMaxMOP_histBancos,
	INTEGER		   as BC_93,
	INTEGER		   as iMaxMOP_actCtas,
	INTEGER		   as iMaxMOP_histAltCtas,
	INTEGER		   as iMaxMOP_histCtas,
	DECIMAL(5,2)   as dSituacionPagoCoppel,
	MONEY		   as mIngreso_Mensual,
	MONEY		   as mPagoMinimo,
	SMALLINT	   as sCteLargo8,
	INTEGER		   as iMeses_hist_Val,
	CHAR(1)		   as cTipo_Alta_CteProsp,
	MONEY		   as mLinea_tienda,
	MONEY		   as mImporte_hip,
	DECIMAL(9,6)   as dTasa,
	SMALLINT	   as sFlagHuella,
	CHAR(1)		   as cResultadoOsTel,
	CHAR(1)		   as cTieneOstel,
	CHAR(1)		   as cEnvioCat,
	INTEGER		   as iSolMc,
	INTEGER		   as iSolMcAux,
	CHAR(2)		   as cCod_Ult_Identif,
	CHAR(13)	   as cTelCasa,
	CHAR(13)	   as cTelTrabajo,
	SMALLINT	   as sValida_Cel,
	CHAR(10) 	   as dtUltimaCompra,
	INTEGER		   as iBanderareferencia,
	CHAR(10)	   as dtFechaCte,
	CHAR(20)	   as cFolioMovil,
	CHAR(1)		   as cFlagGeoMov,
	INTEGER		   as iFlagGeoSuc,
	INTEGER		   as iCanal_Sol,
	CHAR(1)		   as cOrigenCte,
	SMALLINT	   as sFlagForzarEnvioMC,
	INTEGER		   as iSecuenciaOs,
	CHAR(1)		   as cStatusRespOs,
	CHAR(10)	   as dtFecha_Respuesta,
	CHAR(20)	   as cNumSol_Os,
	CHAR(1)		   as cCompIngresos,
	DECIMAL(14,2)  as dIngresoCac,
	SMALLINT	   as sCompValido,
	CHAR(1)		   as cTipo_movimiento,
	CHAR(4)		   as cSucursal,
	CHAR(1)		   as cTipoSolOS,
	DECIMAL(14,2)  as dCompromisosCac,
	SMALLINT	   as sFlag_oro,
	MONEY		   as mIngreso_Neto,
	CHAR(10)	   as dtFechaNac,
	CHAR(1)		   as cSexo,
	CHAR(50)	   as cEdo_Civil,
	INTEGER	   	   as iTiem_Edo_Civil,
	INTEGER		   as HR0048,
	INTEGER		   as UT0034,
	CHAR(50)	   as cOcupacion,
	INTEGER	       as iTiem_Ocupacion,
	CHAR(50) 	   as cEscolaridad,
	CHAR(50)	   as cTipoResidencia,
	INTEGER	       as iTiem_Residencia,
	VARCHAR(10)    as vClvEdoCob,
	VARCHAR(200)   as vLocalidad,
	CHAR(50)	   as cEntidad,
	SMALLINT	   as sCteLargo,
	SMALLINT	   as sScore_coppel,
	CHAR(20)	   as cCURP,
	INTEGER		   as iFlagEmpleado,
	DECIMAL(14,2)  as dValor_3s,
	CHAR(1)		   as cStatusMovil,
	CHAR(20) 	   as cCteProsp,
	CHAR(2)  	   as cStatusSol_CteProsp,
	CHAR(1) 	   as cRTipo3,
	CHAR(1)  	   as cVigSolOS,
	CHAR(30)	   as sBuenPagos,
	DECIMAL(14,2)  as dCompromisos,
	SMALLINT	   as sFlagBuenPago12,
 	SMALLINT	   as sFlagBuenPago30, 
	SMALLINT	   as sEntidad_Localidad,
	CHAR(2)		   as cNuevoStatusOstel,
	CHAR(20)	   as cCteProspVig,
	MONEY		   as mCompro_banco,
	DECIMAL(14,2)  as dComprobanco_TDC,
	DECIMAL(14,2)  as mCompro_bancoPP,
	CHAR(20)	   as cGeoCte,
	INTEGER		   as iCanalV1,
	INTEGER		   as HR0050,
	INTEGER		   as TR0002,
	INTEGER		   as TR0001,
	INTEGER		   as IQ0002,
	INTEGER		   as iCtas_StatusFF_6011,
	DECIMAL(18,2)  as dSaldo_linea_credi,
	DECIMAL(18,2)  as dSaldo_limit_credi,
	INTEGER	       as iTiem_Edo_Civil_meses,
	DECIMAL(18,4)  as dMontoOtorgado,
	MONEY		   as mCapacidad_pago,
	CHAR(20)	   as cVigenciaBancoppel,
	DECIMAL(14 ,2) as dLineaBanco,
	INTEGER		   as iExisteCliente,
	MONEY 		   as mSaldoRopa,
	MONEY 		   as mSaldoMuebles,
	MONEY 		   as mSaldoPrestamos,
	INTEGER		   as mosSncOldestRevTLOpnd,
	INTEGER		   as numInq0to2Mos,
	DECIMAL(18,2)  as pctBankILTL,
	CHAR(10)	   as pctTL30pDaysEverColl,
	CHAR(10) 	   as avgMosInFileTLRptd0To2Mos,
	INTEGER 	   as highestUtilOnBankNatlRevTL,
	INTEGER		   as lowestRatingIL,
	INTEGER		   as lowestRatingRevOpen,
	CHAR(4)		   as maxDelq0To11Mos,
	INTEGER	   	   as mosSncOldestBankNatlRevOpenTLOpnd,
	CHAR(10)  	   as netFrctTLOpnd0To35Mos,
	MONEY 		   as totBalDelqTL,
	INTEGER 	   as numFinInq0to5Mos,
	INTEGER 	   as maxDelqEver,
	CHAR(10)	   as pctInq0To2MosByInq0To11Mos,
	INTEGER 	   as numRetTLOpnd0to5Mos,
	MONEY 		   as num_sumasaldoscuentasabiertas,
	MONEY 		   as num_sumalineascuentasabiertas,
	DECIMAL(18,2)  as pct_usocuentasabiertas,
	INTEGER		   as num_antiguedadpromediocuentas12meses,
	INTEGER 	   as num_consultasfinanciera,
	INTEGER 	   as num_maxplazodias,
	CHAR(2) 	   as clv_tipoproductocrediticio,	
	MONEY 		   as num_montofechamorosamasgravemasreciente,
	INTEGER 	   as num_totalperiodosreportados,
	DECIMAL(18,2)  as num_porcentajecorrientepromedio,
	INTEGER 	   as num_lineacreditopromedio,
	INTEGER 	   as num_arrendamiento,
	INTEGER 	   as num_tiendacomercial,
	INTEGER 	   as clv_worstcurrentmop,	
	INTEGER 	   as num_direcciones,
	MONEY 		   as num_montopeoratrasohistoricomasreciente,	
	INTEGER 	   as num_mesespeoratrasohistoricomasreciente,	
	MONEY 		   as num_sumasaldoscuentasrevolventessintelcos, 	
	MONEY 		   as num_sumalineascuentasrevolventessintelcos, 
	DECIMAL(18,2)  as pct_usocuentasrevolventessintelcos,		 
	INTEGER 	   as num_tarjetacredito,						 
	INTEGER 	   as num_consultas90dias,						 
	INTEGER 	   as num_cuentasMOP3,							 
	INTEGER 	   as num_cuentas,	
	INT8 	   	   as num_consultassic,		
	SMALLINT	   as vgrupoA,		 
	CHAR(20)	   as NumSolMovil,
	SMALLINT	   as iFlag2credito,
	INTEGER		   as NumCuentaPagoMinimo,
	CHAR(10)		   as dtFechaSolicitud,
	SMALLINT	   as sEdadCte,
	SMALLINT as pMeses_historia_grupo,
	DECIMAL(5,2) as pSituacion_pago_grupo,
	DECIMAL(18,2) as dSalariomin,
    DECIMAL(18,2) as dTasa_Ordinaria,
    DECIMAL(18,2) as dTasa_Moratoria,
    DECIMAL(18,2) as diva,
    DECIMAL(18,2) as dDiaspromedio,
    DECIMAL(18,2) as dTope_ingre,
    DECIMAL(18,2) as dcVeces_smb,
    DECIMAL(18,2) as dPorcpermitido,
    DECIMAL(18,2) as dMesespermitido,
    DECIMAL(18,2) as dMinimomesespermitido,
	CHAR(30) 	  as cEstado,
	CHAR(30)      as cMunicipio,
	CHAR(1) 	  as cBRM_reing;
-------------------------------------------- DEFINICION DE VARIABLES ---------------------------
--DEFINICION DE VARIABLES DATOS DEL CLIENTE
DEFINE cNumCte                  CHAR(20);      --numero de cliente Coppel
DEFINE cNumCteBco		        CHAR(20);      --numero de cliente Bancoppel
DEFINE cB_INE		            CHAR(20);      --Flag de validacion INE B_ife
DEFINE cCurp 					CHAR(20);      --Corresponde al CURP del cliente 
DEFINE dtFechaCte			    CHAR(10);          --Corresponde a la fecha de alta del cliente
DEFINE dtFechaNac 				CHAR(10);          --Corresponde a la Fecha de Nacimiento del cliente 
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);      --Corresponde al estado civil del cliente -**
DEFINE iTiem_Edo_Civil          INTEGER;      --Corresponde al tiempo del estado civil 
DEFINE iTiem_Edo_Civil_meses    INTEGER;      --Corresponde al tiempo de estado civil en  meses
DEFINE cEscolaridad             CHAR(50);      --Corresponde al grado maximo de estudios del cliente 
DEFINE cHabita_en               CHAR (50);     --Tipo de vivienda del cliente -**
DEFINE cTipoResidencia          CHAR (50);     --Corresponde al tipo de residencia
DEFINE cEntidad                 CHAR(50);      --Corresponde a la entidad de residencia del cliente -**
DEFINE vLocalidad        		VARCHAR(200);  -- Corresponde a la localidad del cliente
DEFINE iTiem_Residencia   		INTEGER;      --Corresponde al tiempo de residencia  
DEFINE cGeoCte		  		    CHAR(20);      --Corresponde a las cordenadas de localizacion del cliente 
DEFINE cFlagGeoMov			    CHAR(1);       --Corresponde al flag de geolocalizacion 
DEFINE iFlagGeoSuc		        INTEGER;       --Correspode al flag de geolocalizacion diderente a la ubicacion de la sucursal
DEFINE cTelCasa                 CHAR(13);      --Corresponde al telefono de casa del cliente
DEFINE cTelTrabajo              CHAR(13);      --Corresponde al telefono de trabajo del cliente
DEFINE iBanderaReferencia		INTEGER;       --Corresponde a un flag de coincidencia de las referencias telefonicas vs las enviadas a supervision
DEFINE sValida_Cel	            SMALLINT;      --iValidaCel (numero de tel celulares activos y validados debera ser max=1
DEFINE cOcupacion               CHAR(50);      --Corresponde a la ocupacion del cliente
DEFINE iTiem_Ocupacion          INTEGER;      --Corresponde al tiempo que lleva laborando
DEFINE cProfesion             	CHAR(3);       --profesion del cliente
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente
DEFINE cDescAct 			    CHAR(60);      --descripcion de la actividad que realiza el cliente
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente
DEFINE vDescSubAct      		VARCHAR (50);  --descripcion de la actividad que realiza el cliente
DEFINE mIngreso_Mensual			MONEY;         --Corresponde al ingreso mensual reportado por el cliente
DEFINE mIngreso_Neto            MONEY;         --Corresponde al ingreso mensual neto del cliente ** validar si viene de informacion de coppel
DEFINE cCompIngresos			CHAR(1);       --Corresponde al flag comprobante de ingresos del cliente
DEFINE dIngresoCac              DECIMAL(14,2); --Corresponde al ingreso del cliente con comprobante de ingresos valido por Mesa de Control
DEFINE sCompValido      		SMALLINT;      --Corresponde al flag de validacion por parte de mesa de control del comprobante de ingreso
DEFINE sFlagHuella              SMALLINT;      --corresponde a la coincidencia o no de la hulla del cliente banco vs coppel
DEFINE cCod_Ult_Identif         CHAR(2);       --Corresponde a la ultima identificacion presentada por el cliente ( INE,PASAPORTE....ETC)
DEFINE iReferencia				INTEGER;
DEFINE iReferencia1				INTEGER;
DEFINE iReferencia2 			INTEGER;
DEFINE iMotivoOs				INTEGER;
DEFINE vHuella                  SMALLINT;
DEFINE cValidaINE				CHAR(20);
DEFINE sEdadCte					SMALLINT;
DEFINE cNombreCte				CHAR(50);
DEFINE pMeses_historia_grupo 	SMALLINT;
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);

--DEFINICION DE VARIABLES DE CUENTA COPPEL
DEFINE dtUltimaCompra           CHAR(10) ;           --Fecha ultima compra
DEFINE cPuntualidadCoppel       CHAR(2);        --clasificacion del cliente Coppel de acuerdo al comportamiento de pago en todas sus cuentas
DEFINE dEficienciaCoppel    	DECIMAL(5,2);   --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE dSituacionPagoCoppel     DECIMAL(5,2);   --calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE iCredDigitalesAct        INTEGER;        --cuenta de creditos digitales activos
DEFINE cSituacionEspecial       CHAR(1);        --Corresponde a la revision de situaciones especiales que pueda tener el cliente en coppel
DEFINE sCausaSituacion          SMALLINT;       --Causa de la situacion especial
DEFINE cMotivoRech            	CHAR(1);        --Motivo del rechazo en Coppel
DEFINE cDescMvo             	CHAR(300);      --descripcion del motivo del rechazo en Coppel 
DEFINE sHist_meses              SMALLINT;       -- tiempo de experiencia crediticia en Coppel del cliente pendiente -->Preca
DEFINE cCteExcep		      	CHAR(20);       --Cliente coppel que presenta excepcion
DEFINE dtmaxFechaAperturaDelProducto CHAR(10) ;      --fecha maxima de apertura del producto de porcentaje mas bajo y si existe empate se toma el mas reciente , no son CC, FF
DEFINE cFechaUltimoPago         CHAR(13);       --fecha ultimo pago
DEFINE dtMinFechaAperturasinFF  CHAR(10) ;           --Minima fecha de apertura de las cuentas que no son FFen sd_maecredcrd
DEFINE dtminFechaApertura       CHAR(10) ;           --fecha minima de apertura que tenga el cliente
DEFINE mAbonoTotal              MONEY(14,2);    --abono total de sus cuentas Coppel
DEFINE mAbonoVencidoTotal       MONEY(14,2);    --Abono vencido total vencido de sus cuentas Coppel
DEFINE mAbonoMuebles         	MONEY(14,2);    --Abono mensual del cliente en muebles
DEFINE mAbonoPrestamos       	MONEY(14,2);    --Abono mensual del cliente en prestamo
DEFINE mAbonoRopa            	MONEY(14,2);    --Abono mensual del cliente en ropa
DEFINE mAbonoAire    		    MONEY(14,2);    --Abono mensual del cliente en tiempo aire
DEFINE mAbonoAfiliados 	        MONEY(14,2);    --Abono mensual del cliente en afiliados
DEFINE mAbonoReestructura 	    MONEY(14,2);    --Abono mensual del cliente en reestructuras
DEFINE mVencidoMuebles 	        MONEY(14,2);    --vencido mensual del cliente en muebles
DEFINE mVencidoRopa 	        MONEY(14,2);    --vencido mensual del cliente en ropa
DEFINE mVencidoPrestamos        MONEY(14,2);    --vencido mensual del cliente en prestamo personal
DEFINE mVencidoAire             MONEY(14,2);    --vencido mensual del cliente en tiempo aire
DEFINE mVencidoAfiliados        MONEY(14,2);    --vencido mensual del cliente en afiliados
DEFINE mVencidoReestructura     MONEY(14,2);    --vencido mensual del cliente en reestructura
DEFINE mTotalVencido            MONEY(14,2);    --total vencido de sus cuentas Coppel
DEFINE mPagoMinimo              MONEY(14,2);    --Corresponde al pago minimo del cliente
DEFINE mLinea_tienda            MONEY(14,2);    --Corresponde a la linea de credito del cliente
DEFINE cTipoSolOS		    	CHAR(1);        --Corresponde al tipo de solicitud ( titular/prospecto) de la ultima OS registrada
DEFINE mSaldoRopa				MONEY;
DEFINE mSaldoMuebles			MONEY;
DEFINE mSaldoPrestamos			MONEY;

--DEFINICION DE VARIABLES DE BANCO
DEFINE mCompro_banco            	MONEY (14,2);   --Corresponde a los compromisos banco del cliente 
DEFINE dComprobanco_TDC         	DECIMAL(14,2);  --Corresponde a los compromisos de tarjeta de credito Bancoppel
DEFINE mCompro_bancoPP				DECIMAL(14,2);
DEFINE v_comprobancoprestamo    	MONEY (14,2);
DEFINE cNumcredito              	CHAR(20);
DEFINE cNumcreditoCCFF				CHAR(20);
DEFINE iMaxSalVencidoBancoppel  	INTEGER;        --Maximo saldo vencido de sus cuentas Bancoppel sin considerar status CC,FF
DEFINE iCtas_StatusCV           	INTEGER;        --Corresponde al numero de cuentas que tienen estatus CV ( credito vendido Bancoppel) sin considerar estatus CC,FF
DEFINE iCred_StatusFC           	INTEGER;        --Corresponde al conteo de creditos con estatus FC
DEFINE iCred_StatusFF_restru    	INTEGER;        --Corresponde al conteo de creditos con estatus FC en maecred y que no tienen FF en maecredcrd
DEFINE iCredits_riesgoD         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoE        		INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCredits_riesgoC         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iMaxMontoReserva         	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus CC,FF
DEFINE iCred_StatusDif_FF       	INTEGER;        --Corresponde a los creditos con estatus diferente de FF en sd_maecredcrd
DEFINE dMaxSalVencidoCRD        	DECIMAL(18,2);  --Corresponde al maximo saldo vencido de los creditdos con estatus distinto FF y producto <> 6011
DEFINE iCuentasStatusCVsinFF    	INTEGER;        --Corresponde al numero de cuentas que tienen estatus CV ( credito vendido Bancoppel) sin considerar estatus FF
DEFINE iCtas_StatusDif_FF_6011  	INTEGER;        --Corresponde al # de cuentas con estatuus <> FF y producto =6011
DEFINE iCtas_StatusFF_6011      	INTEGER;        --Corresponde al # de cuentas con estatuus = FF y producto =6011
DEFINE iCredRiesgoD_sinFF		 	INTEGER;        --Corresponde a situaciones especiales, no se considderan estatus FF
DEFINE iCredRiesgoE_sinFF			INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iCredRiesgoC_sinFF		 	INTEGER;        --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE dmaxMontoReservaRiesgoC_sinFF DECIMAL(18,2);  --Corresponde a situaciones especiales,no se considderan estatus FF
DEFINE iReprestamos             	INTEGER;        --correpsonde al flag represtamos
DEFINE cSolBanco					CHAR(20);
DEFINE sFlag_oro					SMALLINT;       --Corresponde al flag de tarjeta Oro
DEFINE vClvEdoCob       			VARCHAR(10);    --Corresponde a la variable Clave Estado Cobranza 
DEFINE cEstado                      CHAR(30);
DEFINE cMunicipio                   CHAR(30);
DEFINE cVigenciaBancoppel       	CHAR(20);       --Vigencia Bancoppel 
DEFINE dLineaBanco              	DECIMAL(14,2);  --Linea de utilizacion  Bancoppel
DEFINE cResultadoOsTel          	CHAR(1);        --Corresponde al resultado de la Orden de Supervision telefonico
DEFINE cTieneOstel              	CHAR(1);        --Corresponde al flag que identifica si la solicitud tiene o no Orden de supervision telefonica
DEFINE cEnvioCat                	CHAR(1);        --Corresponde al flag que identifica si  la solicitud se envio al Centro de atencion telefonica CAT
DEFINE iSolMc				    	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud a mesa de control
DEFINE iSolMcAux		        	INTEGER;        --Corresponde al numero de veces que se ha enviado la solicitud referencia a mesa de control
DEFINE iSecuenciaOs			    	INTEGER;        --Corresponde a la secuencia de orden de supervision  de la ultima OS registrada
DEFINE cStatusRespOs		    	CHAR(1);        --Corresponde al estatus de la respuesta de orden de supervision  de la ultima OS registrada
DEFINE dtFecha_Respuesta			CHAR(10);           --Corresponde a la fecha de respuesta de la Orden de Supervision  de la ultima OS registrada
DEFINE cMotivoRechBcpl  			CHAR(1); 		--Motivo de rechazo BanCoppel
DEFINE cDescripcion					CHAR(60);
DEFINE cRiesgoViviendaCpl  			CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE cEjecucion	  				CHAR(1);
DEFINE cProducto2                	CHAR (4);
DEFINE v_comprobanco            	MONEY (14,2);
DEFINE v_compromi_tdc      			DECIMAL(14,2);
DEFINE dtMaxFechaCorte      		DATE;
DEFINE cGrado_riesgo        		CHAR(2);
DEFINE dMto_reserva         		DECIMAL(18,2);
DEFINE dtFechaAper         			CHAR(10);
DEFINE cStatus_cred					CHAR(2);
DEFINE dSdo_vencido					DECIMAL(18,2);
DEFINE dSdo_vencidocrd      		DECIMAL(18,2);
DEFINE v_capacidad_pago				MONEY(14,2);
DEFINE iPlazo                  		INTEGER;
DEFINE cCredExterno 				VARCHAR(20);
DEFINE iCredCrd 					INTEGER;

--DEFINICION DE VARIABLES DE BURO
DEFINE dCompromisos                 DECIMAL(14,2); --Corresponde a los compromisos de todas las cuentas del cliente BC
DEFINE dMontoUdis                   DECIMAL(14,2); --monto en UDIS de la observacion mas reciente
DEFINE cInstitucion                 CHAR(2);       --nombre de la institucion de la observacion mas reciente
DEFINE cClvObser                    CHAR(2);       --clave de observacion mas reciente (vStatus) 
DEFINE iNumCtas_ClvOb               INTEGER;       --Numero de cuentas que tienen clave de observacion FD,PS,SU,CV,PC,SG,SP,SR,UP,FR en Buro, no considera comunicaciones y servicios
DEFINE iMax_MOP                     INTEGER;       --Maximo MOP actual, no considera Comunicaciones y servicios,cuentas Bancoppel con clave de observacion RV
DEFINE cInstCta_MayorMOP            CHAR(2);       --Nombre de institucion de cuenta con mayor MOP
DEFINE dMonto_UDIS_MayorMOP         DECIMAL(14,2); --Monto UDIS de  cuenta con mayor MOP
DEFINE iMax_MOP_Hist_6m             INTEGER;       --MAXIMO_MOP historico 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_6m         CHAR(2);       --Nombre de institucion de cuenta con mayor MOP historico 6 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_6m             DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP historico 6 meses de cuentas con >=100 UDIS
DEFINE iMM_Histo_12m                INTEGER;       --MMaximo_MOP historico 12 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_12m        CHAR(2);       --Nombre de institucion de cuenta con mayor MOP historico 12 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_12m            DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP historico 12 meses de cuentas con >=100 UDIS
DEFINE iNumCtasMOP_4_12m            INTEGER;       --Numero de cuentas MOP =4 Ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_12m            INTEGER;       --Numero de cuentas MOP =5 Ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_12m       INTEGER;       --Numero de cuentas MOP >5 Ultimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iMOP4_12mCon1o2   			INTEGER;       --Numero de cuentas MOP =4 Ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE iMOP5_12mCon1o2   			INTEGER;       --Numero de cuentas MOP =5 Ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE iMOPmayor5_12mCon1o2			INTEGER;       --Numero de cuentas MOP >5 Ultimos 12 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 6 meses mas recientes con valores 1 0 2
DEFINE cInstCta_MayorMOP_30m        CHAR(2);       --Nombre de institucion de cuenta con mayor MOP historico 30 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_Rech           DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP, de cuenta que provoca el rechazo
DEFINE iNumCtasMOP_4_30m            INTEGER;       --Numero de cuentas MOP =4 Ultimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_30m            INTEGER;       --Numero de cuentas MOP =5 Ultimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_30m       INTEGER;       --Numero de cuentas MOP >5 Ultimos 30 meses, UDIS >=100, sin comunicaciones ni servicios
DEFINE iCtasMOP_4_30mCon1o2         INTEGER;       --Numero de cuentas MOP =4 Ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE iCtasMOP_5_30mCon1o2         INTEGER;       --Numero de cuentas MOP =4 Ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE iCtasMOP_mayor5_30mCon1o2    INTEGER;       --Numero de cuentas MOP >5 Ultimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, debera considerar los 12 meses mas recientes con valores 1 0 2
DEFINE cInstitucionMMOP_provocaRech CHAR(2);       --Nombre de institucion de cuenta con mayor MOP (Ultimos 30 dias),de cuenta que provoca el rechazo
DEFINE dMontoUDIS_30d_Rech          DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (Ultimos 30 dias), de cuenta que provoca el rechazo
DEFINE iMM_Histo_30m                INTEGER;       --Maximo_MOP historico 30 meses de cuentas con >=100 UDIS (Se jerarquizan por fecha_reporte, " para mns de salida")
DEFINE cInstCta_MM_30m_Rech         CHAR(2);       --Nombre de institucion de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de cuenta que provoca el rechazo
DEFINE dMotoUDIS_MM_30m_Rech        DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de la cuenta que provoca el rechazo
DEFINE iMM_act_Bancos               INTEGER;       --Maximo_MOP actual de bancos
DEFINE iMM_hist_alto_Bancos         INTEGER;       --Maximo_MOP historico mas alto bancos
DEFINE iMM_hist_Bancos              INTEGER;       --Maximo_MOP historico bancos
DEFINE iCtasBancosMOP_tl26          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP actual (tl26) en  MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl38          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R ( revolvente) y con MOP historico mas alto (tl38) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_tl27          INTEGER;       --Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" , tl06 = R ( revolvente) y con MOP historico (tl27) en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasBancosMOP_act_hist_alto INTEGER;       --Numero de cuentas de Bancos con MOP actual, historico e historico mas alto ( incluye Bancoppel)
DEFINE iCtasComServMOP_tl26         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mas alto  (tl38) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27         INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27) en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasCSM_act_hist_alto       INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mas alto en MOP 3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl26_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual (tl26) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl38_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico mas alto  (tl38) y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasComServMOP_tl27_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP historico  (tl27)  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iCtasCSM_ActHistAlto_12m     INTEGER;       --Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"  y con MOP actual o MOP historico o MOP historico mas alto  y menos de 12 meses en MOP 2,3,4,5,6,7,96,97,99
DEFINE iMaxMOP_actBancos            INTEGER;       --Maximo_MOP actual de bancos reportadas el ultimo ano
DEFINE iMaxMOP_histAltBancos        INTEGER;       --Maximo_MOP historico mas alto de bancos reportadas el ultimo ano
DEFINE iMaxMOP_histBancos           INTEGER;       --Maximo_MOP historico de bancos reportadas el ultimo ano
DEFINE iMaxMOP_actCtas              INTEGER;       --Maximo_MOP actual de todas las cuentas
DEFINE iMaxMOP_histAltCtas          INTEGER;       --Maximo_MOP histroico mas alto de todas las cuentas
DEFINE iMaxMOP_histCtas             INTEGER;       --Maximo_MOP historico de todas las cuentas
DEFINE iCtas_SinComServ             INTEGER;       --Numero de cuentas sin comunicaciones ni servicios
DEFINE iCtas_SinComServ_pagar       INTEGER;       --Numero de cuentas sin comunicaciones ni servicios con monto a pagar >0
DEFINE iNumCtas_SHBr                INTEGER;       --Numero de cuentas, son de servicios ,hipoteca y bienes raices
DEFINE iNumCtas_SHBr_pagar          INTEGER;       --Numero de cuentas con monto a pagar >0, servicios (tl02), hipoteca (tl06=M),bienes raices (tl07=RE)

DEFINE dMaxMtoUdi	 				DECIMAL(14,2);
DEFINE vCuantos      				SMALLINT;
DEFINE vTpCambioUdi  				DECIMAL(14,6);
DEFINE vTpCambioUs   				DECIMAL(14,6);
DEFINE vCodUdi       				CHAR(2);
DEFINE vCodUs       				CHAR(2);
DEFINE vClase        				CHAR(1);
DEFINE vInstitucion  				CHAR(2);
DEFINE vMontoUdis    				DECIMAL(14,2);
DEFINE vTl27						CHAR(24);
DEFINE var_i        				smallint;
DEFINE var_j	    				smallint;
DEFINE vmeses_pos   				smallint;
define vmeses6      				varchar(6);
define vmeses12     				varchar(12);
define vmeses30     				varchar(30);
DEFINE bandera6  					INTEGER;
DEFINE bandera12 					INTEGER;
DEFINE bandera30 					INTEGER;
define vmeses_ctas   				smallint;
DEFINE pSIC							CHAR(1);
DEFINE MOPHistoricoAltoTl38 		INTEGER; 
DEFINE MaxComServMOP_tl38 			INTEGER;
DEFINE cInstitucionCtas 			CHAR(2);
DEFINE cMOPmeses 					CHAR(2);

--DEFINICION DE VARIABLES DE SOLICITUD
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE dtDiaFF  				CHAR(2);
DEFINE dtMesFF  				CHAR(2);
DEFINE dtAnoFF  				CHAR(4);
DEFINE cCteProsp		        CHAR(20);       --numero de cliente prospecto
DEFINE cStatusSol_CteProsp      CHAR(2);        --Corresponde al estatus de la solicitud del cliente prospecto 
DEFINE cTipo_Alta_CteProsp      CHAR(1);        --Tipo de Alta Cte Prospecto
DEFINE cCteProspVig			    CHAR(20);       --Corresponde a la vigencia del cliente  prospecto
DEFINE cSucursal   			    CHAR(4);        --Numero de Sucursal
DEFINE iFlagEmpleado            SMALLINT;       --Corresponde al flag de empleado Coppel y/o Bancoppel
DEFINE sEntidad_Localidad		SMALLINT;       --Corresponde a la variable entidad/localidad 
DEFINE iCanal_Sol         	    INTEGER;        --Corresponde al canal por el cual se origina la solicitud
DEFINE iCanalV1				    INTEGER;        --Canal de solicitud ingresada por prospecto
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE cPiloto 					CHAR(1);
DEFINE cCausa_Sol			    CHAR(3);        --causa del rechazo de la solicitud
DEFINE cTipoRech                CHAR(1);        --tipo de rechazo de la solicitud
DEFINE cTipoGrupo 			    CHAR(2);        --grupo de evaluacion al cual pertenece la solicitud
DEFINE cSituacion  				CHAR(1); 		--Situacion del producto de porcentaje mas bajo y si existe empate se toma el mas reciente 
DEFINE cProducto                CHAR(4);        --producto de porcentaje mas bajo y si existe empate se toma el mas reciente
DEFINE dminProcentajeProductoMasReciente DECIMAL(6,2);   --porcentaje minimo del producto mas reciente
DEFINE sFlagForzarEnvioMC       SMALLINT;       --Etatus de la ultima solicitud que no termina en (AN,PC) y que su producto si se envia a mesa de control (6300,6400,7600,7700,9100,9300,6001,6800)
DEFINE cNumSol_Os			    CHAR(20);       --Corresponde al numero de solicitud de la Orden de supervision  de la ultima OS registrada
DEFINE sScore_coppel            SMALLINT;       --Corresponde a los puntos asignados en la evaluacion del score de Coppel
DEFINE dValor_3s                DECIMAL(14,2);  --Corresponde al valor del score  de Circulo de credito 
DEFINE cFolioMovil         	    CHAR(20);       --Folio solicitud movil
DEFINE cStatusMovil             CHAR(1);        --Estatus solicitud movil
DEFINE sBc_Score                SMALLINT;  		--valor del score ( Indica la calificacion del score solicitado "Numero positivo")
DEFINE cInstitucionClvExclusionMasReciente CHAR(2); -- Corresponde a la INSTITUCION de exclusion mas reciente
DEFINE vClvExclusionMasReciente VARCHAR(04);	-- Corresponde a la CALVE de exclusion mas reciente
DEFINE cTicket				   	CHAR(20); 
DEFINE cEdo_proceso			   	CHAR(4); 
DEFINE cNum_men				   	CHAR(3); 
DEFINE cEmpresa				   	CHAR(4); 
DEFINE cNumSolRef            	CHAR(20);


--DEFINICION DE VARIABLES DE PARAMETRICOS
DEFINE HR0048               INTEGER;       --Number of ever satisfactory trades open 12 months or older (Numero de cuenta abiertas con 12 meses o mas).
DEFINE hr0048_aux           INTEGER;
DEFINE HR0050               INTEGER;       --# de cuentas abiertas en los ultimos 6 meses o mas. Grupo 53
DEFINE hr0050_aux           INTEGER;
DEFINE hr0050_aux2          INTEGER;
DEFINE TR0002               INTEGER;       --NUMERO PROMEDIO DE MESES
DEFINE TR0001               INTEGER;       --EL MES MAXIMO DE LA CUENTA ABIERTA MAS VIEJA
DEFINE AUX_TR0001           INTEGER;
DEFINE IQ0002               INTEGER;       --Numero de consultas al cliente por institucion
DEFINE BC_421               DECIMAL(18,2); --Corresponde a la variable que se calcula actualmente
DEFINE BC_85                INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_93                INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC1                  INTEGER;       --la maxima cantidad de meses entre la fecha y la fecha de apertura de la cuenta
DEFINE BC_101               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_117               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_119               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE BC_20                INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE UT0034               INTEGER;       --Utilization percent of bank revolving trades (Porcentaje de utilizacion en cuentas revolventes bancarias).
DEFINE ut0034_aux 			INTEGER;
DEFINE ut0034_aux2			INTEGER;
DEFINE vSum_higcred   		DECIMAL(18,2);
DEFINE vSum_bal             DECIMAL(18,2);
DEFINE dSaldo_linea_credi	DECIMAL(18,2); --Corresponde a variables para prestamo
DEFINE dSaldo_limit_credi   DECIMAL(18,2); --Corresponde a variables para prestamo
DEFINE dtFechaHoy           DATE;
DEFINE maxmoptot			INTEGER;
DEFINE pmaxmop				INTEGER;
DEFINE pmaxmop1 		    INTEGER;
DEFINE pcadenaaux 			varchar(30);
DEFINE pmeses		  		INTEGER;
DEFINE Bandera			   	INTEGER;
DEFINE i            		INTEGER;
DEFINE ki           		INTEGER;
DEFINE kiz          		INTEGER;

--DEFINICION DE VARIABLES DE EVALUACION
DEFINE cRTipo3           CHAR(1);       --Corresponde a la clave de envio a OS ( A,R,D.....)
DEFINE cVigSolOS         CHAR(1);       --Corresponde si la solicitud esta vigente o vencida para envio a OS (vVigente)
DEFINE sBuenPagos        CHAR(30);      --Corresponde al buen pago 
DEFINE sFlagBuenPago12   SMALLINT;      --Corresponde al flag de buen pago 12meses
DEFINE sFlagBuenPago30   SMALLINT;      --Corresponde al flag de buen pago 30meses
DEFINE cNuevoStatusOstel CHAR(2);       --Corresponde al estatus despues de la OS tel*** Oscar solicita tabla **rev
DEFINE dMontoOtorgado    DECIMAL(18,4); --Corresponde al monto otorgado 
DEFINE mCapacidad_pago   MONEY(14,2);   --Corresponde a la capacidad de pago 
DEFINE iExisteCliente    INTEGER;       --Conteo de solicitudes del cliente para producto Coppel con estatus diferente de 'PC','AN','MC'
DEFINE cTipo_movimiento  CHAR(1);       --Correspode al tipo de movimiento ( U,M) unico, mixto 
DEFINE dCompromisosCac   DECIMAL(14,2); --Compromisos registrados en las tabla ss_solicitudes_cac ( aparentemenete son los compromisos validados por Mesa de Control, ya no se usa)
DEFINE dtFechaAux        CHAR(10);          --Fecha de la ultima consulta realizada que no sea de Bancoppel
DEFINE dTasa             DECIMAL(9,6);  --
DEFINE dtasaMora		 DECIMAL(9,6);
DEFINE cOrigenSol        CHAR(1);       --Corresponde al origen ( contiene T,B,vacio)*
DEFINE cOrigenCte        CHAR(1);       --Corresponde al origen del cliente ( prospecto, titular...)
DEFINE mImporte_hip      MONEY;         --Corresponde al monto de la hipoteca del cliente
DEFINE iMeses_hist_Val   INTEGER;      	--Numero de de meses de historia validos del cliente de acuerdo a su edad
DEFINE sCteLargo8        SMALLINT;      --Determina si es grupo 8
DEFINE sCteLargo         SMALLINT;      --Corresponde a clientes con cuenta de capacion en su primer producto ( solo debito)
DEFINE vgrupoA 			 SMALLINT;		--Conteo por empresa y cliente de la tabla sd_grupo_cliente
DEFINE NumSolMovil		 CHAR(20);		--Numero de solicitud movil de la tabla ss_solicitudes_movil
DEFINE iFlag2credito 	 SMALLINT;		--Variable flag sale del procedure sp_valida2Credito

DEFINE cCodRet2Cred 	 CHAR(6);
DEFINE iValorICC	     SMALLINT;
DEFINE v_moneda     	 CHAR(2); 
DEFINE v_monto 			 MONEY;

DEFINE v_total      	 MONEY;
DEFINE v_imp_hip   		 MONEY;
DEFINE v_factor    		 DECIMAL(14,6);
DEFINE v_tot_tp          DECIMAL(14,2);

------------------------------------------------------------------------------
------------------  DEFINICION DE VARIABLES DE REINGENIERIA ------------------
------------------------------------------------------------------------------
DEFINE MV0   									 INTEGER;
DEFINE MV1   									 INTEGER;
DEFINE MV5   									 INTEGER;
DEFINE MV7   									 INTEGER;
DEFINE MV9   									 INTEGER;
DEFINE MV18  									 INTEGER;
DEFINE MV21 									 INTEGER;
DEFINE mosSncOldestRevTLOpnd					 INTEGER; ----------------------
DEFINE numInq0to2Mos							 INTEGER;
DEFINE pctBankILTL								 DECIMAL(18,2);
DEFINE pctTL30pDaysEverColl						 CHAR(10); --fico
DEFINE avgMosInFileTLRptd0To2Mos				 CHAR(10); --fico
DEFINE highestUtilOnBankNatlRevTL				 INTEGER; ----------------------
DEFINE lowestRatingIL							 INTEGER;
DEFINE lowestRatingRevOpen						 INTEGER;
DEFINE maxDelq0To11Mos							 CHAR(10); --fico
DEFINE mosSncOldestBankNatlRevOpenTLOpnd		 INTEGER;
DEFINE netFrctTLOpnd0To35Mos					 CHAR(10); --fico
DEFINE totBalDelqTL								 DECIMAL(18,2);
DEFINE numFinInq0to5Mos							 INTEGER;
DEFINE maxDelqEver								 INTEGER;
DEFINE pctInq0To2MosByInq0To11Mos				 CHAR(10); --fico
DEFINE numRetTLOpnd0to5Mos						 INTEGER; --fico
DEFINE num_sumasaldoscuentasabiertas			 DECIMAL(18,2);
DEFINE num_sumalineascuentasabiertas			 DECIMAL(18,2);
DEFINE pct_usocuentasabiertas				 	 DECIMAL(18,2);
DEFINE num_antiguedadpromediocuentas12meses		 INTEGER; ----------------------
DEFINE num_consultasfinanciera					 INTEGER;
DEFINE num_maxplazodias							 INT8;
DEFINE clv_tipoproductocrediticio				 CHAR(2);	
DEFINE num_montofechamorosamasgravemasreciente	 DECIMAL(18,2);
DEFINE num_totalperiodosreportados				 INTEGER;
DEFINE num_porcentajecorrientepromedio			 DECIMAL(18,2);
DEFINE num_lineacreditopromedio					 INTEGER;
DEFINE num_arrendamiento						 INTEGER;
DEFINE num_tiendacomercial						 INTEGER;
DEFINE clv_worstcurrentmop						 INTEGER;	
DEFINE num_direcciones							 INTEGER;
DEFINE num_montopeoratrasohistoricomasreciente	 DECIMAL(18,2);
DEFINE num_mesespeoratrasohistoricomasreciente	 INTEGER;
DEFINE num_sumasaldoscuentasrevolventessintelcos DECIMAL(18,2);DEFINE num_sumalineascuentasrevolventessintelcos DECIMAL(18,2);
DEFINE pct_usocuentasrevolventessintelcos		 DECIMAL(18,2);
DEFINE num_tarjetacredito						 INTEGER;
DEFINE num_consultas90dias						 INT8;
DEFINE num_cuentasMOP3							 INT8;
DEFINE num_cuentas								 INT8;
DEFINE num_consultassic						 	 INT8;
--------
DEFINE num_sumalineascredito		 DECIMAL(18,2);
DEFINE num_cuentasvalidas			 DECIMAL(18,2);
DEFINE mTl38						 DECIMAL(18,2);
DEFINE mTl36 						 DECIMAL(18,2);
DEFINE dtTl37                        CHAR(10);
DEFINE dtFechatl37                   CHAR(10);
--DEFINE dtFechatl37Prueba             CHAR(10);
DEFINE montoTl36 					 DECIMAL(18,2);
DEFINE CadenaTl27 					 VARCHAR(30);
DEFINE CantTl27 					 INTEGER;
DEFINE num_periodos_corriente_cuenta INTEGER;
DEFINE num_periodos_cuenta			 INTEGER;
DEFINE numero_cuentas				 INT8;
DEFINE porc_corriente_cuenta		 INTEGER;
DEFINE  suma_porcentajes_corriente	 INTEGER;
DEFINE maxTl26	 					 INTEGER;
DEFINE maxTl38						 INTEGER;
DEFINE maxTl27						 INTEGER;
DEFINE maxTl33						 INTEGER;
DEFINE maxTl34						 INTEGER;
DEFINE maxTl35						 INTEGER;
DEFINE Tl26act						 INTEGER;
DEFINE Tl38act						 INTEGER;
DEFINE Tl33act						 INTEGER;
DEFINE Tl34act	 					INTEGER;
DEFINE Tl35act						 INTEGER;
DEFINE Saldotl22					 DECIMAL(14,2);
DEFINE Cantl22						 INTEGER;

DEFINE cTl11	     	  CHAR(1);
DEFINE iTl10		  	  INTEGER;
DEFINE dtfechaApertura	  DATE;
DEFINE tipoProducto	  	  CHAR(2);
DEFINE i_plazo			  INTEGER;
DEFINE max_plazo		  INTEGER;
DEFINE producto_max_plazo CHAR(2);
DEFINE fecha_apertura_max DATE;
DEFINE saldo_max 		  DECIMAL(14,2);
DEFINE iMesesHistCont     INTEGER;

DEFINE cTl27_std                        CHAR(24);
DEFINE iMesesFechaReporte               INTEGER;
DEFINE iMesesFechaMasRecienteHistPagos  INTEGER;
DEFINE cTl30_std                        CHAR(2);
DEFINE cTl26_std                        CHAR(2);
DEFINE cTl38_std                        CHAR(2);
DEFINE iTl33_std                        INTEGER;
DEFINE iTl34_std                        INTEGER;
DEFINE iTl35_std                        INTEGER;
DEFINE dTl24                            DECIMAL;
DEFINE dCalculo                         DECIMAL(18,2);
DEFINE iLineasMorosas                   INTEGER;

DEFINE iLineasConMesesFila  	INTEGER;
DEFINE iLineasCollection    	INTEGER;
DEFINE iLineasReport12m     	INTEGER;
DEFINE iLineasRetail        	INTEGER;
DEFINE cFlagLineaComercio  		CHAR(1);
DEFINE cTipoNegocio         	CHAR(2);

DEFINE sumanumrettlopnd0to5mos  INTEGER;
DEFINE cTipoContrato            CHAR(2);
DEFINE iMesesFechaCierre        INTEGER;
DEFINE cFlagInstallment         CHAR(1);
DEFINE cBanderaRev              CHAR(1);
DEFINE cFlagDisputa             CHAR(1);
DEFINE cBanderaCuentaAbierta    CHAR(1);
DEFINE cFlagUnusualTradeLine    CHAR(1);
DEFINE cFlagMortgageTradeLine   CHAR(1);

DEFINE iLineasRevolventes   	INTEGER;
DEFINE iLineasRevAbiertas   	INTEGER;
DEFINE iLineasRevValidas    	INTEGER;
DEFINE FracNetaRev          	INTEGER;

DEFINE iLineasAbiertas035m  	INTEGER;
DEFINE iLineasAbiertas      	INTEGER;
DEFINE iTotalMontoCredito   	INTEGER;
DEFINE iTotalSaldoActual    	INTEGER;
DEFINE cMesesFechaApertura  	CHAR(4);

DEFINE iSaldoActualEstan    INTEGER;
DEFINE iMontoCredito        INTEGER;
DEFINE cTipoCuenta          CHAR(2);
DEFINE mBalance             MONEY;

DEFINE iCollectiontradelines INTEGER;
DEFINE iTradelines           INTEGER;
DEFINE cCodRetEstand         CHAR(6);

DEFINE cFlagLineaComercioRevolvente CHAR(1);
DEFINE iMesesFechaReporte_std       INTEGER;
DEFINE iMesesfechaapertura_std      INTEGER;
DEFINE iMesesfechaapertura_std_rev  INTEGER;
DEFINE iCuentasrevolventes          INTEGER;
DEFINE iCuentasrevolventesvalidas   INTEGER;
DEFINE dLimiteCredito     			DECIMAL;

DEFINE dtFechaHistMorGrave_std      DATE;
DEFINE iSaldomoromasgraveestan_std  INTEGER;
DEFINE dtFecha_Consulta             DATE;


DEFINE iLinesReport3m   			INTEGER;
DEFINE iTotalMesesFila  			INTEGER;
DEFINE iLineasMesesFila 			INTEGER;

DEFINE num_consultas        		INTEGER;
DEFINE iMesesFechaConsulIq  		INTEGER;
DEFINE cFlagRetail          		CHAR(1);
DEFINE cFlagbanknatl        		CHAR(1);

DEFINE iLineasValidas               INTEGER;
DEFINE iLineasDe30                  INTEGER;
DEFINE flag30evertradeline          CHAR(1);
DEFINE iHistPagosMasValorCount      INTEGER;
DEFINE iMesesHistContMasValorOcu    INTEGER;
DEFINE fecha_atraso_mas_grave       CHAR(10);
DEFINE monto_atraso_mas_grave       INTEGER;


------------------------
DEFINE cuenta 					INTEGER;
DEFINE NumCuentaPagoMinimo 		INT8;
DEFINE contenedor 				INTEGER;
DEFINE comparador 				INTEGER;
DEFINE dSalariomin				DECIMAL(18,2);
DEFINE dTasa_Ordinaria 			DECIMAL(18,2);
DEFINE dTasa_Moratoria 			DECIMAL(18,2);
DEFINE diva 					DECIMAL(18,2);
DEFINE dDiaspromedio 			DECIMAL(18,2);
DEFINE dTope_ingre 				DECIMAL(18,2);
DEFINE dcVeces_smb 				DECIMAL(18,2);
DEFINE dPorcpermitido 			DECIMAL(18,2);
DEFINE dMesespermitido 			DECIMAL(18,2);
DEFINE dMinimomesespermitido 	DECIMAL(18,2);
DEFINE vlatitud 				VARCHAR(10);
DEFINE vlongitud 				VARCHAR(11);
------------------------
--Cambios Olivia
DEFINE cBRM_reing CHAR(1);

------------------------
--Cambios 120523
DEFINE cnumcte_stdiq_consultassic			CHAR(20);
DEFINE cnumcte_stdiq_MesesFechaConsulIq		CHAR(20);
DEFINE cnum_clientetl_arrendamiento			CHAR(20);
DEFINE cnumcte_stdiq_consultasfinanciera	CHAR(20);

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cCodRet         CHAR(6);
DEFINE cMensaje_ret    VARCHAR(100,1);
DEFINE cRFC			   CHAR(13);
DEFINE cRFC_determina  CHAR(13);

--MANEJO DE ERROR -535 Already in transaction
DEFINE iTransaccion     SMALLINT;


DEFINE cInst_MayorMOP        CHAR(2);
DEFINE cMax_MOP              INTEGER;
DEFINE cMonto_UDIS_MayorMOP  DECIMAL(14,2);
DEFINE mMonto_UDIS_MayorMOP  DECIMAL(14,2);

--Identificacion canal DUD 
DEFINE cSucursalSol 	CHAR(4);
DEFINE cSubCanal 	CHAR(2);

DEFINE error_info CHAR(80);
--------------------------- DECLARACION DE VARIABLES ---------------------------
LET SumanumRetTLOpnd0to5Mos = 0;
LET MV0  = 0;
LET MV1  = 0;
LET MV5  = 0;
LET MV7  = 0;
LET MV9  = 0;
LET MV18 = 0;
LET MV21 = 0;
--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
LET cNumCte               ="";     
LET cNumCteBco		      ="";      
LET cCurp  				  ="";
LET cB_INE                ="";     
LET cValidaINE					= "";                     
LET dtFechaCte			  = '01/01/1900';          
LET dtFechaNac 			  = '01/01/1900';
LET cSexo                 ="";       
LET cEdo_Civil            ="";       
LET iTiem_Edo_Civil       = 0;       
LET iTiem_Edo_Civil_meses = 0;      
LET cEscolaridad          ="";
LET cHabita_en            ="??";      
LET cTipoResidencia       = "";      
LET cEntidad              ="";
LET vLocalidad         	  = '';
LET iTiem_Residencia   	  = 0;      
LET cGeoCte		  		  ='';      
LET cFlagGeoMov			  ='';       
LET iFlagGeoSuc		      = 0;     
LET cTelCasa              ="";      
LET cTelTrabajo           ="";     
LET iBanderaReferencia	  = 0;                                           
LET sValida_Cel	          = 0;      
LET COcupacion            = "";      
LET iTiem_Ocupacion       = 0;      
LET cProfesion            ="";
LET sId_actividad		  = 0;      
LET cDescAct              ="";                                        
LET sId_subactividad	  = 0;      
LET vDescSubAct           = "";                                         
LET mIngreso_Mensual	  = 0;         
LET mIngreso_Neto         = 0;         
LET cCompIngresos		  ="";       
LET dIngresoCac           = 0; 
LET sCompValido      	  = 0;       
LET sFlagHuella           = 0;      
LET cCod_Ult_Identif      ="";       
LET iReferencia			  = 0;
LET iReferencia1		  = 0;	
LET iReferencia2		  = 0;
LET iMotivoOs			  = 0;
LET vHuella				  = 0;
LET cuenta 				  = 0;
LET sEdadCte			  = 0;
LET cNombreCte 			  ='';
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;
LET vlatitud  			  ="";
LET vlongitud 		      ="";

--INICIALIZACION DE VARIABLES DE CUENTA COPPEL
LET dtUltimaCompra       		 	= '01/01/1900';          
LET cPuntualidadCoppel   		  	='';        
LET dEficienciaCoppel			  	= 0;       
LET dSituacionPagoCoppel		  	= 0; 
LET iCredDigitalesAct    		  	= 0;
LET cSituacionEspecial   		  	="?";
LET sCausaSituacion      		  	= 0;       
LET cMotivoRech          		  	="";   
LET cDescMvo            		  	="Pre-Calificacion Aprobada";
LET sHist_meses               	  	= 0;      
LET cCteExcep           		  	="";
LET dtmaxFechaAperturaDelProducto 	= '01/01/1900';          
LET cFechaUltimoPago     		  	="";
LET dtminFechaAperturasinFF 	  	= '01/01/1900';
LET dtminFechaApertura 			  	= '01/01/1900';
LET mAbonoTotal          			= 0;                
LET mAbonoVencidoTotal   			= 0;    
LET mAbonoMuebles    	 			= 0;        
LET mAbonoPrestamos    				= 0;
LET mAbonoRopa        				= 0;
LET mAbonoAire           			= 0;
LET mAbonoAfiliados     			= 0;
LET mAbonoReestructura   			= 0;
LET mVencidoMuebles 	 			= 0;
LET mVencidoRopa 	     			= 0; 
LET mVencidoPrestamos    			= 0; 
LET mVencidoAire         			= 0; 
LET mVencidoAfiliados    			= 0;
LET mVencidoReestructura 			= 0;  
LET mTotalVencido        			= 0;
LET mPagoMinimo          			= 0;
LET mLinea_tienda        			= 0;    
LET cTipoSolOS		     			="";      
LET mSaldoRopa			 			= 0;
LET mSaldoMuebles		 			= 0;
LET mSaldoPrestamos		 			= 0;

--INICIALIZACION DE VARIABLES DE BANCO
LET mCompro_banco           = 0;    
LET mCompro_bancoPP			= 0;
LET dComprobanco_TDC        = 0;  
LET v_comprobancoprestamo   = 0;
LET cNumcredito             = "";
LET cProducto2				= "";
LET iMaxSalVencidoBancoppel = 0; 
LET iCtas_StatusCV          = 0;
LET iCred_StatusFC          = 0; 
LET iCred_StatusFF_restru   = 0;
LET cCredExterno 			= '';
LET iCredCrd 				= 0;
LET iCredits_riesgoD        = 0;
LET iCredits_riesgoE        = 0; 
LET iCredits_riesgoC        = 0; 
LET iMaxMontoReserva        = 0;
LET iCred_StatusDif_FF      = 0;
LET dMaxSalVencidoCRD       = 0;
LET iCuentasStatusCVsinFF   = 0;
LET iCtas_StatusDif_FF_6011 = 0;
LET iCtas_StatusFF_6011     = 0; 
LET iCredRiesgoD_sinFF      = 0;
LET iCredRiesgoE_sinFF      = 0;             
LET iCredRiesgoC_sinFF      = 0; 
LET dmaxMontoReservaRiesgoC_sinFF = 0;
LET iReprestamos           	= 0;
LET cSolBanco				= pNumSol;
LET sFlag_oro		        = 0;       
LET vClvEdoCob              ="";    
LET cEstado 				='';
LET cMunicipio 				='';
LET cVigenciaBancoppel      ="";
LET dLineaBanco		        = 0;
LET cResultadoOsTel         ="";         
LET cTieneOstel             ="";        
LET cEnvioCat               ="";        
LET iSolMc			        = 0;        
LET iSolMcAux		        = 0;        
LET iSecuenciaOs	        = 0;        
LET cStatusRespOs	        ="";        
LET dtFecha_Respuesta       = '01/01/1900';       
LET cMotivoRechBcpl 		= "";
LET cDescripcion			="";
LET cRiesgoViviendaCpl  	=""; 
LET cRiesgoViviendaBcpl 	="";
LET cActRiesgoCpl       	="";
LET cActRiesgoBCpl			="";
LET cDescpRiesgo			= "";
LET cEjecucion	  			= "";
LET cNumcreditoCCFF			= "";
LET v_comprobanco       	= 0;
LET v_compromi_tdc 			= 0;
LET dtMaxFechaCorte			= DATE(1);
LET cStatus_cred			= "";
LET cGrado_riesgo			= "";
LET dMto_reserva			= "";
LET dtFechaAper        		= DATE(1);
LET dSdo_vencido			= 0;
LET dSdo_vencidocrd			= 0;
LET v_capacidad_pago   		= 0;
LET iPlazo              	= 0;


--INICIALIZACION DE VARIABLES DE BURO
LET dCompromisos              = 0; 
LET dMontoUdis                = 0; 
LET cInstitucion              ="";
LET cClvObser				  ="";
LET iNumCtas_ClvOb            = 0;       
LET iMax_MOP                  = 0;     
LET cInstCta_MayorMOP         ="";       
LET dMonto_UDIS_MayorMOP      = 0; 
LET iMax_MOP_Hist_6m          = 0;       
LET cInstCta_MayorMOP_6m      ="";       
LET dMontoUDIS_MM_6m          = 0; 
LET iMM_Histo_12m             = 0;       
LET cInstCta_MayorMOP_12m     ="";      
LET dMontoUDIS_MM_12m         = 0; 
LET iNumCtasMOP_4_12m         = 0;       
LET iNumCtasMOP_5_12m         = 0;       
LET iNumCtasMOP_mayor5_12m    = 0;       
LET iMOP4_12mCon1o2           = 0;                                  
LET iMOP5_12mCon1o2           = 0;       
LET iMOPmayor5_12mCon1o2      = 0;
LET cInstCta_MayorMOP_30m     ="";       
LET dMontoUDIS_MM_Rech        = 0; 
LET iNumCtasMOP_4_30m         = 0;       
LET iNumCtasMOP_5_30m         = 0;       
LET iNumCtasMOP_mayor5_30m    = 0;
LET iCtasMOP_4_30mCon1o2      = 0;
LET iCtasMOP_5_30mCon1o2      = 0;
LET iCtasMOP_mayor5_30mCon1o2 = 0;    
LET cInstitucionMMOP_provocaRech ="";       
LET dMontoUDIS_30d_Rech          = 0; 
LET iMM_Histo_30m                = 0;        
LET cInstCta_MM_30m_Rech         =""; 
LET dMotoUDIS_MM_30m_Rech        = 0; 
LET iMM_act_Bancos               = 0;        
LET iMM_hist_alto_Bancos         = 0;       
LET iMM_hist_Bancos              = 0;       
LET iCtasBancosMOP_tl26          = 0;       
LET iCtasBancosMOP_tl38          = 0;       
LET iCtasBancosMOP_tl27          = 0;       
LET iCtasBancosMOP_act_hist_alto = 0;      
LET iCtasComServMOP_tl26         = 0;       
LET iCtasComServMOP_tl38         = 0;       
LET iCtasComServMOP_tl27         = 0;       
LET iCtasCSM_act_hist_alto       = 0;        
LET iCtasComServMOP_tl26_12m     = 0;       
LET iCtasComServMOP_tl38_12m     = 0;       
LET iCtasComServMOP_tl27_12m     = 0;        
LET iCtasCSM_ActHistAlto_12m     = 0;       
LET iMaxMOP_actBancos            = 0;       
LET iMaxMOP_histAltBancos        = 0;        
LET iMaxMOP_histBancos           = 0;       
LET iMaxMOP_actCtas              = 0;       
LET iMaxMOP_histAltCtas          = 0;       
LET iMaxMOP_histCtas             = 0;       
LET iCtas_SinComServ             = 0;       
LET iCtas_SinComServ_pagar       = 0;      
LET iNumCtas_SHBr                = 0;       
LET iNumCtas_SHBr_pagar          = 0;       
LET dMaxMtoUdi				     = 0;
LET vCodUdi      				 = "";
LET vCodUs      				 = "";
LET vTpCambioUdi 				 = 0;
LET vTpCambioUs  				 = 0;
LET vCuantos  				 	 = 0;
LET vClase       				 = "";
LET vInstitucion 				 = '';
LET vMontoUdis 			  		 = 0;
LET var_i      			  		 = 0;  
LET vmeses_pos 			  		 = 0;
LET vmeses_ctas 		  		 = 0;
LET cInstitucionCtas 	  		 = '';
LET cMOPmeses			  		 = '';
LET pSIC                  		 = "";
LET  MOPHistoricoAltoTl38 		 = 0; 
LET  MaxComServMOP_tl38   		 = 0; 
LET iLinesReport3m 				 = 0;
LET iTotalMesesFila 			 = 0;
LET iLineasMesesFila 			 = 0;

--INICIALIZACION DE VARIABLES DE SOLICITUD
LET dtFechaSolicitud       = '01-01-1900';
LET dtDiaFF  			   = '01';
LET dtMesFF  			   = '01';
LET dtAnoFF		 	       = '1900';
LET cCteProsp		       ="";
LET cStatusSol_CteProsp    ="";
LET cTipo_Alta_CteProsp	   ="";
LET cCteProspVig		   ="";
LET cSucursal   	       ="";
LET iFlagEmpleado          = 0;
LET sEntidad_Localidad     =0;
LET iCanal_Sol             = 0;
LET iCanalV1		       = 0;
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET cPiloto 			   ="";
LET cCausa_Sol		       ="";
LET cTipoRech              ="";  
LET cTipoGrupo 		       ="";
LET cSituacion             = "?";
LET cProducto              ='????';   
LET dminProcentajeProductoMasReciente = 0;
LET sFlagForzarEnvioMC     = 0;
LET cNumSol_Os		       ="";
LET sScore_coppel          = 0;
LET dValor_3s              = 0;
LET cFolioMovil            ="";
LET cStatusMovil           ='';
LET sBc_Score              = 0;  
LET cInstitucionClvExclusionMasReciente = "";
LET vClvExclusionMasReciente = "";
LET cTicket				   =""; 
LET cEdo_proceso	   	   =""; 
LET cNum_men		       =""; 
LET cEmpresa		       =""; 
LET cNumSolRef             = '';

--INICIALIZACION DE VARIABLES DE PARAMETRICOS
LET HR0048             = 0;
LET hr0048_aux         = 0;
LET HR0050             = 0;
LET hr0050_aux         = 0;
LET hr0050_aux2        = 0;
LET TR0002             = 0;
LET TR0001             = 0;
LET AUX_TR0001         = 0;
LET IQ0002             = 0;
LET BC_421             = 0;
LET BC_85              = 0;
LET BC_93              = 0;
LET BC1                = 0;
LET BC_101             = 0;
LET BC_117             = 0;
LET BC_119             = 0;
LET BC_20              = 0;
LET UT0034             = 0;
LET ut0034_aux         = 0;
LET ut0034_aux2        = 0;
LET vSum_bal           = 0;
LET vSum_higcred       = 0;
LET dSaldo_linea_credi = 0;
LET dSaldo_limit_credi = 0;
LET dtFechaHoy         = DATE(1);      
LET maxmoptot     	   = 0;
LET pmaxmop			   = 0;
LET pmaxmop1 		   = 0;
LET pcadenaaux		   = "";
LET pmeses		       = 0;
LET Bandera			   = 0;
LET ki                 = 0;
LET kiz                = 0;

--INICIALIZACION DE VARIABLES DE EVALUACION
LET cRTipo3           ="";
LET cVigSolOS		  ="";
LET sBuenPagos        = "";
LET sFlagBuenPago12	  = 0;
LET sFlagBuenPago30	  = 0;
LET cNuevoStatusOstel ="";
LET dMontoOtorgado    = 0;
LET mCapacidad_pago   = 0;
LET iExisteCliente    = 0;
LET cTipo_movimiento  ="";
LET dCompromisosCac   = 0;
LET dtFechaAux		  = '01/01/1900';
LET dTasa			  = 0;
LET dtasaMora = 0;
LET cOrigenSol        ='1';
LET cOrigenCte		  ="";
LET mImporte_hip      = 0;
LET iMeses_hist_Val   = 0;
--LET sDeter_Grupo_A    = 0;
LET sCteLargo8		  = 0;
LET sCteLargo         = 0;
LET vgrupoA 		  = 0;
LET NumSolMovil		  = '';
LET iFlag2credito 	  = 0;
LET NumCuentaPagoMinimo = 0;

LET v_moneda    	  = '';
LET v_monto 		  =0;
LET v_total       	  = 0;
LET v_imp_hip    	  = 0;
LET v_factor    	  = 0;
LET v_tot_tp     	  = 0;

--INICIALIZACION DE VARIABLES DE REINGENIERIA
LET MV0  = 0;
LET MV1  = 0;
LET MV5  = 0;
LET MV7  = 0;
LET MV9  = 0;
LET MV18 = 0;
LET MV21 = 0;
LET mosSncOldestRevTLOpnd				= 0;
LET numInq0to2Mos						= 0;
LET pctBankILTL							= 0;
LET pctTL30pDaysEverColl				= '0';
LET avgMosInFileTLRptd0To2Mos			= '0';
LET iLinesReport3m = 0;
LET iTotalMesesFila = 0;
LET iLineasMesesFila = 0;
LET highestUtilOnBankNatlRevTL			= -999;
LET lowestRatingIL						= 0;
LET lowestRatingRevOpen					= 0;
LET maxDelq0To11Mos						= '0';
LET mosSncOldestBankNatlRevOpenTLOpnd	= 0;
LET netFrctTLOpnd0To35Mos				= '0';
LET totBalDelqTL						= 0;
LET numFinInq0to5Mos					= 0;
LET maxDelqEver							= 0;
LET pctInq0To2MosByInq0To11Mos			= 0;
LET numRetTLOpnd0to5Mos					= 0;
LET num_sumasaldoscuentasabiertas		= 0;
LET num_sumalineascuentasabiertas		= 0;
LET pct_usocuentasabiertas				= 0;
LET num_antiguedadpromediocuentas12meses 	= 0;
LET num_consultasfinanciera					= 0;
LET num_maxplazodias						= 0;
LET clv_tipoproductocrediticio				= 0;
LET num_montofechamorosamasgravemasreciente		= 0;
--LET num_mesesfechamorosamasgravemasreciente		= 0;
LET num_totalperiodosreportados					= 0;
LET num_porcentajecorrientepromedio				= -1;
LET num_lineacreditopromedio					= 0;
LET num_arrendamiento							= 0;
LET num_tiendacomercial							= 0;
LET clv_worstcurrentmop							= 0;
LET num_direcciones								= 0;
LET num_montopeoratrasohistoricomasreciente		= 0;
LET num_mesespeoratrasohistoricomasreciente		= 0;
LET num_sumasaldoscuentasrevolventessintelcos	= 0;	
LET num_sumalineascuentasrevolventessintelcos 	= 0;
LET pct_usocuentasrevolventessintelcos		 	= 0;
LET num_tarjetacredito						 	= 0;
LET num_consultas90dias						 	= 0;
LET num_cuentasMOP3								= 0;
LET num_cuentas								 	= 0;
LET num_consultassic							= 0;
LET NumCuentaPagoMinimo 						= 0;
LET iCredCrd									= 0;

LET mTl38 		= 0;
LET mTl36 		= 0;
LET dtTl37 		= DATE(1);
LET dtFechatl37 = DATE(1);
--LET dtFechatl37Prueba = DATE(1);
LET montoTl36 	= 0;
LET CadenaTl27 	= '';
LET CantTl27 	= 0;
LET cuenta 		= 0;

LET suma_porcentajes_corriente = 0;
LET porc_corriente_cuenta 	   = 0;
LET num_periodos_cuenta 	   = 0;
LET numero_cuentas			   = 0;
LET Saldotl22 	= 0;
LET Cantl22 	= 0;
LET maxTl26 	= 0;
LET maxTl38 	= 0;
LET maxTl27 	= 0;
LET Tl26act 	= 0;
LET Tl38act 	= 0;
LET Tl33act 	= 0;
LET Tl34act 	= 0;
LET Tl35act 	= 0;
LET Tl35act 	= 0;

LET iSaldoActualEstan   = 0;
LET iMontoCredito       = 0;
LET cTipoCuenta         = '';
LET mBalance            = 0;

LET cFlagLineaComercioRevolvente    = '';
LET imesesfechaapertura_std_rev     = 0;
LET iCuentasrevolventesvalidas      = 0;
LET iMesesfechaapertura_std         = 0;
LET iMesesFechaReporte_std          = 0;
LET iCuentasrevolventes             = 0;
LET dLimiteCredito                  = 0;


--parametros tdc visa Olivia
LET dSalariomin 			= 0;
LET dTasa_Ordinaria 		= 0; --
LET dTasa_Moratoria 		= 0; 
LET diva 					= 0;
LET dDiaspromedio 			= 0;
LET dTope_ingre 			= 0;
LET dcVeces_smb 			= 0;
LET dPorcpermitido 			= 0;
LET dMesespermitido 		= 0;
LET dMinimomesespermitido 	= 0;

LET cBRM_reing = 1;

------------------------
--Cambios 120523
LET cnumcte_stdiq_consultassic			= '';
LET cnumcte_stdiq_MesesFechaConsulIq	= '';
LET cnum_clientetl_arrendamiento		= '';
LET cnumcte_stdiq_consultasfinanciera	= '';

--DECLARACION DE VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="000000";
LET cMensaje_ret        = '';
LET cCodRetEstand = '000000';

LET cRFC = '';
LET cRFC_determina = '';


LET cInst_MayorMOP         ="";
LET cMax_MOP               = 0; 
LET cMonto_UDIS_MayorMOP   = 0;
LET mMonto_UDIS_MayorMOP   = 0;

LET cSucursalSol = '';
LET cSubCanal = '';

LET error_info = '';

--MANEJO DE ERROR -535 Already in transaction
LET iTransaccion    = 0;

BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, error_info
		IF iSqlErr != 0 THEN
		
			SET DEBUG FILE TO "/home/sp_consultadatos_motor" || TRIM(pNumSol) || ".err";
			TRACE iSqlErr||" * "||iIsamErr||" * "||error_info;
	  
			LET cCodRet = iSqlErr;
			INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_consultadatos_motor", cCodRet, CURRENT ||iIsamErr||'|'||TRIM(pNumSol));

			RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
			NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
			nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
			nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
			nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
			nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
			nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
			nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
			nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
			nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
			nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
			nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
			nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,0), Nvl(cInstCta_MayorMOP,''), 
			nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,0), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,0), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
			nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
			nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
			nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
			nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,0), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
			nvl(iNumCtas_ClvOb,0), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
			nvl(vClvExclusionMasReciente,'0'), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
			nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
			nvl(iMM_act_Bancos,0), nvl(iMM_hist_alto_Bancos,0), nvl(iMM_hist_Bancos,0), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
			nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
			nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
			nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
			nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,0),	NVL(iMaxMOP_actBancos,0), 
			NVL(iMaxMOP_histAltBancos,0), nvl(iMaxMOP_histBancos,0), nvl(BC_93,0), nvl(iMaxMOP_actCtas,0), nvl(iMaxMOP_histAltCtas,0),
			nvl(iMaxMOP_histCtas,0), nvl(dSituacionPagoCoppel,0), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
			nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
			nvl(sFlagHuella,0), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
			nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,0), 
			NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,0), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,0), nvl(iCanal_Sol,0), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,0), 
			nvl(iSecuenciaOs,0), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
			nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
			nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
			nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,0), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,0), NVL(dValor_3s,0),
			nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
			nvl(dCompromisos,0), nvl(sFlagBuenPago12,0), NVL(sFlagBuenPago30,0), NVL(sEntidad_Localidad,0), nvl(cNuevoStatusOstel,''), 
			nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,99), 
			nvl(HR0050,-1), nvl(TR0002,-999), nvl(TR0001,-999), nvl(IQ0002,0), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,0), 
			NVL(dSaldo_limit_credi,0), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
			nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
			nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,0), nvl(pctBankILTL,0), nvl(pctTL30pDaysEverColl,'0'), 
			nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,0), nvl(lowestRatingRevOpen,0),
			nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,-1), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,0), 
			nvl(numFinInq0to5Mos,0), nvl(maxDelqEver,99), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,0),
			nvl(num_sumasaldoscuentasabiertas,0), nvl(num_sumalineascuentasabiertas,0), nvl(pct_usocuentasabiertas,0),
			nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
			nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
			nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
			nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
			nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
			nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
			nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
			nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
			NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,'0');
		END IF;
	END EXCEPTION;
	
	------------CAMBIO MANEJO ERROR Already in transaction 
	ON EXCEPTION IN (-535)
		LET iTransaccion = 1;
      --ROLLBACK WORK;
        COMMIT WORK;
		BEGIN WORK;
		--COMMIT WORK;
	END EXCEPTION WITH RESUME; 
	
	--------------------------------------------------
	--SET debug file to '/home/c90236357/Pruebas/Trace/sp_consultadatos_motor_modif_2.out';
    --TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	-----------------------------
	SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;
	

	---------------------------------------------------- VARIABLES DATOS DEL CLIENTE
	IF NVL(pEmpresa,'') = '' OR nvl(pNumSol,'') = '' THEN
		 LET cCodRet = '020202';
	ELSE
		SELECT numcte
			INTO cNumCteBco  
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_solicitud = pNumSol;

		SELECT NVL(numcte_ref, ""), fecha_insert, RFC --Fecha de alta cliente 1ra vez
		INTO cNumCte, dtFechaCte, cRFC
		FROM bdinteg:"informix".si_cliente
		WHERE numcte= cNumCteBco;

		IF 	NVL(cNumCteBco,'') = '' THEN
			LET cCodRet = '030303';
		ELSE

			IF NVL(cNumCte,'') = '' THEN
				LET cNumCte = cNumCteBco;
			END IF;

			LET dtDiaFF = LPAD(DAY(dtFechaCte::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtFechaCte::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtFechaCte::DATE), 4, '0');

			LET dtFechaCte = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

			--LET cValidaINE = '';
			--FOREACH
				SELECT limit 1 TRIM(NVL(resultado,''))
				INTO cValidaINE
				FROM bdinteg:"informix".si_bitacora_ife 
				WHERE numcte = cNumCteBco AND fecha = (SELECT MAX(fecha) from bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumCteBco); 
				--ORDER BY fecha DESC
			--END FOREACH
			IF cValidaINE IS NULL THEN
			LET cValidaINE = '';
			END IF;

			LET cValidaINE = UPPER(cValidaINE);

			IF cValidaINE = 'TRUE' OR cValidaINE = 'VERDADERO' THEN
				LET cB_INE = '1';
			ELSE
				LET cB_INE = '0';
			END IF;

			/*UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET b_ine = cB_INE --alter -- OK -- OK
				WHERE num_solicitud = pNumSol;*/

			SELECT edad, DECODE(edo_civil,'C','Casado(a)','S', 'Soltero(a)','U', 'Union Libre', 'D', 'Divorciado(a)', 'V', 'Viudo(a)', '') as edoCivil, 
					escolaridad_descrip,fecha_nacimiento, sexo, NVL(profesion, ""),actividad, subactividad, actividad_descrip, NVL(rfc,'') , NVL(flag2credito,0) 
			INTO sEdadCte, cEdo_Civil, cEscolaridad,dtFechaNac, cSexo,cProfesion, sId_actividad, sId_subactividad, vDescSubAct,cRFC_determina, iFlag2credito
			FROM bdisolic:ss_revision_determinacion 
			WHERE empresa = pEmpresa 
			AND num_solicitud = pNumSol;
			
			IF NVL(cRFC_determina,'') <> '' THEN
				LET cRFC = cRFC_determina;
			END IF;

			IF NVL(sEdadCte, 0 ) = 0 THEN
				EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, cNumCteBco) 
				INTO cCodRet, cNombreCte, sEdadCte;
			END IF;	
			
				--VVVF
				--Se actualiza el sexo en la tabla ss_revision determinacion para los casos donde lo tenga vacio
				IF NVL(cSexo,'') = '' THEN
					SELECT sexo INTO cSexo 
					FROM bdinteg:si_ctepf 
					WHERE numcte = cNumCteBco;
				
					UPDATE bdisolic:"informix".ss_revision_determinacion 
					SET sexo = cSexo 
					WHERE num_solicitud = pNumSol;
				END IF;

			SELECT sum(case when d.grupo = 4 then NVL(e.rango_minimo, 0) else  0 end) d1, --Tiempo Estado Civil
             sum(case when d.grupo = 41 then NVL(e.rango_minimo,-99) else  0 end) d2, --Tiempo Estado Civil Meses
             max(case when d.grupo = 21 then descripcion else  '' end) d3, --Escolaridad
             max(case when d.grupo = 3  then nvl(descripcion,'') else  '' end) d4, --Estado Civil
             max(case when d.grupo = 5  then nvl(descripcion,'') else  '' end) d5, --Tipo residencia
             sum(case when d.grupo = 6  then NVL(e.rango_minimo,-99) else  0 end) d6, --Tiempo residencia 
             max(case when d.grupo = 7 then NVL(descripcion,'') else '' end) d7, --Ocupacion
             sum(case when d.grupo = 8  then NVL(e.rango_minimo,-99) else  0 end) d8 --Tiempo ocupacion
			 INTO iTiem_Edo_Civil,iTiem_Edo_Civil_meses,cEscolaridad,cEdo_Civil,cTipoResidencia,iTiem_Residencia,cOcupacion,iTiem_Ocupacion
            FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
            where e.grupo = d.grupo 
            AND e.elemento = d.elemento
            AND e.seccion = d.seccion
            AND e.grupo in (4,41,21,3,5,6,7,8)
--          AND d.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where fecha_insert >= today - 30 and status_Solicitud not in ('PC','AN'))
            and d.num_solicitud = pNumSol;
			
			
			
			--LET cEscolaridad = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cEscolaridad,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEscolaridad)
			INTO cEscolaridad;

			
				--LET cEdo_Civil = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cEdo_Civil,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEdo_Civil)
				INTO cEdo_Civil;
			--END IF;

			IF NVL(dtFechaNac,'') = '' THEN
				SELECT fecha_nac
				INTO dtFechaNac
				FROM bdinteg:"informix".si_ctepf -- Revisisar las 4 consultas
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco;
			END IF;

			LET dtDiaFF = LPAD(DAY(dtFechaNac::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtFechaNac::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtFechaNac::DATE), 4, '0');

			LET dtFechaNac = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

			IF NVL(cProfesion, "") =  "" THEN
				SELECT NVL(profesion, "")
				INTO cProfesion 
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco;
			END IF;	

			
			IF iTiem_Edo_Civil_meses = 12 AND (iTiem_Edo_Civil = 0 OR iTiem_Edo_Civil IS NULL OR iTiem_Edo_Civil = 16) THEN
				IF iTiem_Edo_Civil IS NULL THEN -- Si es nulo tiempo estado civil, registrar elemento ya que no tiene asignado ese grupo.
					 --PRUEBA EN MAQUETA INSERT INTO bdisolic:ss_detalle_scoring VALUES('001', 2, 4, 17, '01', pNumSol, 0);
				END IF;

				SELECT NVL(e.rango_minimo, 0) --Tiempo Estado Civil
				INTO iTiem_Edo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 4
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;
				--LET iTiem_Edo_Civil = 17;
			END IF;

			SELECT TRIM(habita_en), codidentifi, curp 
				INTO cHabita_en, cCod_Ult_Identif, cCurp 
				FROM bdinteg:"informix".si_ctepf
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco;


			SELECT a.nombre 
				INTO cEntidad
				FROM bdinteg:"informix".si_estados a, bdinteg:"informix".si_ctepf b
				WHERE a.estado = b.lugar_nac 
				AND b.numcte = cNumCteBco;

			--LET cTipoResidencia = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cTipoResidencia,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cTipoResidencia)
			INTO cTipoResidencia;

			--FOREACH 
					--SELECT  LIMIT 1 catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, nvl(trim(ciu.nombre),'') --SE QUITA LIMIT PORQUE NO EXISTEN MAS REGISTROS CON TIPO_DIR = 1
					SELECT catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, nvl(trim(ciu.nombre),'')
					INTO vClvEdoCob, vLocalidad --Localidad y Estado de cobranza
					FROM bdinteg:"informix".si_direcciones_actual dir
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad) -- Revisar Sepomex
					LEFT OUTER JOIN bdinteg:"informix".si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
					WHERE dir.numcte = cNumCteBco 
					AND dir.tipo_dir='1';
					--order by dir.fecha_insert desc
			--END FOREACH;

			SELECT grupo
				INTO sEntidad_Localidad
				FROM bdisolic:"informix".ss_cat_edo_localidad_param
				WHERE clave_estado = vClvEdoCob
				AND localidad = vLocalidad;
			
			IF NVL(sEntidad_Localidad, 0) = 0 THEN
				LET sEntidad_Localidad = 6;
			END IF;


			--FOREACH
				--SELECT LIMIT 1 rpad(TRIM(nvl(e.nombre,'')),30,' '), nvl(z.municipiozona, '')
				SELECT rpad(TRIM(nvl(e.nombre,'')),30,' '), nvl(z.municipiozona, '')
				INTO cEstado, cMunicipio
				FROM bdinteg:"informix".si_cliente a
					LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte)
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
					LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
					LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia) -- Unir con cunsulta de direcciones
				WHERE a.NumCte = cNumCteBco
				AND nvl(d.tipo_dir,'') = '1';
				--order by d.fecha_insert desc
			--END FOREACH;
			
			EXECUTE PROCEDURE bdinteg:sp_eliminaacentos(cEstado)
			into cEstado;
			
			EXECUTE PROCEDURE bdinteg:sp_eliminaacentos(cMunicipio)
			into cMunicipio;


			--------
					-------------parametros tdc visa Olivia
			/*SELECT valor::DECIMAL(14,2)
			INTO dSalariomin -- Salario Minimo Base
			FROM bdisolic:"informix".ss_param -- Agrupar en una sola cansulta
			WHERE empresa = pEmpresa
			AND secuencia = 354;*/
			
			/*SELECT valor
			INTO dTasa_Ordinaria
			FROM bdisolic:"informix".ss_param
			WHERE empresa = pEmpresa
			AND secuencia = 312;*/


			/*SELECT valor::DECIMAL(14,2)
				INTO dDiaspromedio -- Salario Minimo Base
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 355;
			
			SELECT valor::DECIMAL(9,6)
			INTO dTope_ingre
			FROM bdisolic:"informix".ss_param
			WHERE empresa = pEmpresa
			AND secuencia=353;

			SELECT valor::DECIMAL(14,2)
				INTO dcVeces_smb 
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 364;

			SELECT valor
				INTO dPorcpermitido -- Porcentaje de Situacion de pago
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 307;

			SELECT valor
				INTO dMesespermitido -- Meses de Historia base
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 308;

			SELECT valor
			INTO dMinimomesespermitido --  Meses de Historia Minimo
			FROM bdisolic:"informix".ss_param
			WHERE empresa = pEmpresa
			AND secuencia = 329;*/--VICTOR
			
							
			SELECT a.valor::DECIMAL(14,2), b.valor::DECIMAL(14,2), d.valor::DECIMAL(14,2), e.valor, f.valor, g.valor
			INTO dSalariomin, dDiaspromedio, dcVeces_smb, dPorcpermitido, dMesespermitido, dMinimomesespermitido
			FROM bdisolic:"informix".ss_param a-- Agrupar en una sola cansulta
			LEFT OUTER JOIN bdisolic:"informix".ss_param b on (b.empresa = pEmpresa and b.secuencia = 355)
			--LEFT OUTER JOIN bdisolic:"informix".ss_param c on (c.empresa = pEmpresa and c.secuencia = 353)
			LEFT OUTER JOIN bdisolic:"informix".ss_param d on (d.empresa = pEmpresa and d.secuencia = 364)
			LEFT OUTER JOIN bdisolic:"informix".ss_param e on (e.empresa = pEmpresa and e.secuencia = 307)
			LEFT OUTER JOIN bdisolic:"informix".ss_param f on (f.empresa = pEmpresa and f.secuencia = 308)
			LEFT OUTER JOIN bdisolic:"informix".ss_param g on (g.empresa = pEmpresa and g.secuencia = 329)
			WHERE a.empresa = pEmpresa
			AND a.secuencia = 354;
			----------------------------------------------

			SELECT folio_movil
				INTO cFolioMovil
				FROM bdisolic:"informix".ss_solicitudes_movil
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND status <> '3';
				
			SELECT num_solicitud
				INTO NumSolMovil
				FROM bdisolic:"informix".ss_solicitudes_movil
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND numcte = cNumCteBco;

			SELECT domicilio_alta, TRIM(geolocalizacion), substr(geolocalizacion,1,10), substr(geolocalizacion,12,21)
				INTO cFlagGeoMov,cGeoCte, vlatitud, vlongitud 
				FROM bdinteg:"informix".si_solicitud_movil
				WHERE folio = cFolioMovil; --Se tiene el domicilio_alta solo si es movil

			SELECT {+INDEX(bdinteg:"informix":si_ptf idx_si_pft_lat_lon)} count (id_ptf)
				INTO iFlagGeoSuc
				FROM bdinteg:"informix".si_ptf 
				WHERE latitud = vlatitud 
				AND longitud  = vlongitud;

			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END 
				INTO cTelCasa 
				FROM bdinteg:"informix".si_telefonos_actual -- Tener los 3 telefonos en una consulta
				WHERE numcte = cNumCteBco
				AND tipo_tel = 1;

			/*UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET telefono_domicilio = cTelCasa -- alter Ya existe -- OK -- OK
				WHERE num_solicitud = pNumSol;*/


			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END
				INTO cTelTrabajo
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 3;
						

			SELECT  count(numcte) --Cantidad de celulares activos y validados
				INTO sValida_Cel
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 2
				AND status_tel = 'A'
				AND cofetel = 'V';

		
			--LET cOcupacion = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cOcupacion,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cOcupacion)
			INTO cOcupacion;

			/*SELECT nvl(e.rango_minimo, -99) 
				INTO iTiem_Ocupacion  
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 8
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;*/

			IF NVL(sId_actividad,'') = '' THEN
				SELECT a.claveopcionpuesto, a.clavesubopcionpuesto
				INTO sId_actividad, sId_subactividad
				FROM bdinteg:"informix".si_ingresos a
				WHERE a.numcte = cNumCteBco
				AND a.tipo_ingreso='T'
				AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
									FROM bdinteg:"informix".si_ingresos b
									WHERE b.numcte=a.numcte
									AND b.tipo_ingreso='T');
			END IF;

			/*IF NVL(sId_subactividad,'') = '' THEN
				SELECT a.clavesubopcionpuesto
				INTO sId_subactividad 
				FROM bdinteg:"informix".si_ingresos a
				WHERE a.numcte = cNumCteBco
				AND a.tipo_ingreso='T'
				AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
									FROM bdinteg:"informix".si_ingresos b
									WHERE b.numcte=a.numcte
									AND b.tipo_ingreso='T');
			END IF;*/

			--IF NVL(cDescAct,'') = '' THEN
				SELECT descrip
				INTO cDescAct
				FROM bdinteg:"informix".si_actsubact
				WHERE  id_subact = 0 
				AND id_act = sId_actividad;
			--END IF;

			--LET cDescAct = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cDescAct,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cDescAct)
			INTO cDescAct;

			IF NVL(vDescSubAct,'') = '' THEN
				SELECT descrip
				INTO vDescSubAct
				FROM bdinteg:"informix".si_actsubact
				WHERE  id_subact = sId_subactividad AND id_act = sId_actividad;
			END IF;

			--LET vDescSubAct = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(vDescSubAct,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(vDescSubAct)
			INTO vDescSubAct;

			SELECT {+INDEX bdinteg:"informix".si_clientecomparacionbanconomatch idx_clientecomparacionbanconomatch)} COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanconomatch
				WHERE numcte = cNumCteBco
				AND tipo = 6;
					
			IF vHuella = 0 THEN
				SELECT {+INDEX bdinteg:"informix".si_clientecomparacionbanconomatch idx_clientecomparacionbanconomatch)} COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanco
				WHERE numcte = cNumCteBco
				AND tipo = 7;
				IF vHuella > 0 THEN
					LET sFlagHuella = 1;
				END if;
			END if;

			SELECT NVL(b.ingreso_cac,0),NVL(compromisos_cac,0),NVL(comprobante_valido_cac,"N")
				INTO dIngresoCac, dCompromisosCac, cCompIngresos
				FROM bdisolic:"informix".ss_solicitudes a
				LEFT OUTER JOIN	bdisolic:"informix".ss_solicitudes_cac b ON ( a.num_solicitud = b.num_solicitud)
				WHERE a.num_solicitud = pNumSol;

			EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(pEmpresa, cNumCteBco, pNumSol) 
				INTO cCodRet, cMensaje_ret, sCompValido;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_ConsultaReferencias (pEmpresa, cNumCteBco)
				INTO cCodRet,iReferencia1,iReferencia2;
			
			/*FOREACH -- OS no se requiere, no esta activa
				SELECT num_referencia
					INTO iReferencia
					FROM  bdisolic:"informix".ss_ostelrefsolicitud
					WHERE num_solicitud = pNumSol
						
				IF iReferencia NOT IN (iReferencia1,iReferencia2) THEN
					LET iBanderareferencia = 1;
					IF iMotivoOs = 0  THEN
						LET iMotivoOs = 9;		--Ref. de cte distinta a enviada a supervision tel.		
					END IF;					
					EXIT FOREACH;
				END IF;
			END FOREACH;*/
			
			SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
				WHERE numcte = cNumCteBco;	
					
			IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
				SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea_hist a   
				WHERE numcte = cNumCteBco								 
				AND fecha_consulta = (SELECT MAX(fecha_consulta)
										FROM bdinteg:"informix".si_huella_linea_hist b 
										WHERE   numcte = cNumCteBco)
				AND secuencia = (SELECT MAX(secuencia)
									FROM bdinteg:"informix".si_huella_linea_hist c 
									WHERE  numcte = cNumCteBco);
			END IF;
				
			IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
				
				SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
					INTO cEdo_proceso, cNum_men, cEmpresa
					FROM bdinteg:"informix".si_huella_linea_resultado 
					WHERE ticket = cTicket
					AND estado_proceso = '2'
					AND empresa IN (0,1,2,3)
					AND num_mensaje = "602";

				IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresa,"") <> "" THEN
					LET iFlagEmpleado = 1;
				END if;
			END if;

			------------------------------------------------------ VARIABLES DE CUENTA COPPEL
			LET mAbonoAfiliados,mAbonoReestructura, mAbonoRopa,mAbonoMuebles,mAbonoPrestamos = 0,0,0,0,0;
			LET mSaldoRopa, mSaldoMuebles, mSaldoPrestamos, cOrigenCte, mImporte_hip = 0,0,0,0,0;
			LET dtUltimaCompra = '01/01/1900';

/*			SELECT puntualidad,	porcentaje_efic
				INTO  cPuntualidadCoppel, dEficienciaCoppel
				FROM bdisolic:"informix".ss_cliente_coppel_pp
				WHERE empresa = pEmpresa
				AND cliente_coppel = cNumCte; 
*/
			SELECT situacion_pago,meses_historia, fuente, fecha_ultima_compra, ingreso_mensual, tipo_movimiento, linea_tienda,
					abonomensualaire, abonomensualafiliados, abonomensualreestructura, abonomensualropa, abonomensualmuebles,
					abonomensualprestamos,saldoropa,saldomuebles, saldoprestamos, origen, monto_hipoteca,vencidototalaire, 
					vencidototalafiliados,vencidototalreestructura,situacion_especial,causa, vencidoropa,vencidomuebles,vencidoprestamos,puntualidad,situacion_pago

			INTO dSituacionPagoCoppel,sHist_meses,cOrigenSol, dtUltimaCompra, mIngreso_Neto, cTipo_movimiento, mlinea_tienda,
				mAbonoAire, mAbonoAfiliados, mAbonoReestructura, mAbonoRopa, mAbonoMuebles,
				mAbonoPrestamos, mSaldoRopa, mSaldoMuebles,	mSaldoPrestamos, cOrigenCte, mImporte_hip, mVencidoAire, 
				mVencidoAfiliados, mVencidoReestructura,cSituacionEspecial,sCausaSituacion,	mVencidoRopa,mVencidoMuebles, mVencidoPrestamos, cPuntualidadCoppel, dEficienciaCoppel
			FROM bdisolic:"informix".ss_resum_scor_fin
			WHERE empresa =  pEmpresa
			AND num_solicitud = pNumSol;

			LET mTotalVencido = mVencidoMuebles + mVencidoRopa + mVencidoPrestamos + mVencidoAire + mVencidoReestructura;
			LET mAbonoTotal = mAbonoMuebles + mAbonoPrestamos + mAbonoRopa + mAbonoAire + mAbonoAfiliados + mAbonoReestructura;	

			IF NVL(mAbonoTotal,0) > 0 THEN
				LET mAbonoVencidototal = mTotalVencido / mAbonoTotal;
			END IF;	

			LET dtDiaFF = LPAD(DAY(dtUltimaCompra::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtUltimaCompra::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtUltimaCompra::DATE), 4, '0');

			LET dtUltimaCompra = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;
			
			FOREACH		  
				SELECT a.tl08,a.tl12,b.factor
				INTO v_moneda,v_imp_hip,v_factor
					FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b 
					WHERE a.tl11 = b.tipo
						AND num_cliente = cNumCteBco
						AND tl07 IN ('RE','MI') AND tl12 <> 0 
						AND ((tl06 IN ('M','I') and tl02 <> 'SIC')
						AND (tl02 = 'BIENES RAICES' OR tl02 MATCHES "HIPOTECA*"))
				UNION ALL
				SELECT  a.tl08,a.tl12,b.factor
					FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b 
					WHERE a.tl11 = b.tipo
						AND num_cliente =  cNumCteBco AND tl12 <> 0 
						AND tl06  = 'M' AND tl07 = 'MI' AND tl02 MATCHES "HIPOTECA*"
								
				IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
					LET v_tot_tp = v_imp_hip * v_factor; 
					IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_imp_hip = 0; END IF;
				END IF;
				IF v_moneda = 'UD' THEN  
					LET v_tot_tp = vTpCambioUdi * (v_imp_hip * v_factor);
					IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_imp_hip = 0; END IF;
				END IF;
				IF v_moneda = 'US' THEN
					LET v_tot_tp = vTpCambioUs * (v_imp_hip * v_factor);			
					IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_imp_hip = 0; END IF;
				END IF;
				LET mImporte_hip = v_total;
			END FOREACH;

			SELECT  MIN(fecha_apertura)
				INTO dtMinFechaApertura
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco           
				AND status_cred = 'E1';
				
			LET dtDiaFF = LPAD(DAY(dtMinFechaApertura::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtMinFechaApertura::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtMinFechaApertura::DATE), 4, '0');

			LET dtMinFechaApertura = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

			SELECT MIN(fecha_apertura) 
				INTO dtMinFechaAperturasinFF
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND status_cred <> "FF"
				and num_producto <> '6011';

			LET dtDiaFF = LPAD(DAY(dtMinFechaAperturasinFF::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtMinFechaAperturasinFF::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtMinFechaAperturasinFF::DATE), 4, '0');

			LET dtMinFechaAperturasinFF = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;


			SELECT motivo_rechazo_sol, nvl(tipo_rechazo,''),nvl(descripcion,'')
				INTO cMotivoRech, cTipoRech, cDescMvo
				FROM bdicred:"informix".sd_situacion_cred
				WHERE empresa = pEmpresa
				AND situacion = cSituacionEspecial;

			--LET cDescMvo = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cDescMvo,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cDescMvo)
			INTO cDescMvo;
			LET cSituacionEspecial = '';

			SELECT situacion_credito
			INTO cSituacionEspecial	  
			FROM bdisolic:"informix".ss_resum_scor_fin
			WHERE empresa =  pEmpresa
			AND num_solicitud = pNumSol;

			SELECT COUNT(a.num_credito) 
				INTO iCredDigitalesAct 
				FROM bdicred:"informix".sd_maecredcrd a 
				JOIN bdicred:"informix".sd_linea_prestamo b ON (a.num_credito = b.num_credito and a.num_producto = '6800')  
				WHERE a.numcte = cNumCteBco
				AND b.fecha_cancela IS NULL;

			SELECT valor 
				INTO cCteExcep
				FROM bdisolic:"informix".ss_param 
				WHERE empresa = pEmpresa
				AND secuencia = 324;

			SELECT porcentaje, situacion, fecha_apertura, num_producto
				INTO dminProcentajeProductoMasReciente, cSituacion, dtmaxFechaAperturaDelProducto, cProducto
				FROM bdicred:"informix".sd_situacion_pago a, bdicred:"informix".sd_maecred b
				WHERE b.numcte = cNumCteBco
				AND b.empresa = pEmpresa
				AND a.empresa = b.empresa
				AND a.num_credito = b.num_credito
				AND a.fecha = (SELECT MAX(fecha) 
								FROM bdicred:"informix".sd_situacion_pago s
								WHERE s.empresa = b.empresa
								AND s.num_credito = b.num_credito
								AND s.porcentaje=(SELECT MIN(porcentaje)
													FROM bdicred:"informix".sd_situacion_pago j
													WHERE j.empresa = b.empresa
													AND j.num_credito=b.num_credito));

			LET dtDiaFF = LPAD(DAY(dtmaxFechaAperturaDelProducto::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtmaxFechaAperturaDelProducto::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtmaxFechaAperturaDelProducto::DATE), 4, '0');

			LET dtmaxFechaAperturaDelProducto = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;	
			
			IF cNumCte <> "" THEN
				SELECT fecha_ultimo_pago, re_prestamo INTO cFechaUltimoPago, iReprestamos
				FROM bdisolic: "informix".ss_cliente_coppel_pp WHERE cliente_coppel = cNumCte;	
			ELSE
				LET cFechaUltimoPago = '1900-01-01';
				LET iRePrestamos = '0';
				LET cCodRet = '000000';
			END IF;

			------------------------------------------------------VARIABLES DE SOLICITUD
			/*SELECT sol.tipo_solicitud, sol.num_producto, sol.status_solicitud, sol.sucursal, mov.status
			INTO cTp_solicitud,cNum_Producto,cStatusSolicitud, cSucursal,cStatusMovil
			FROM bdisolic:"informix".ss_solicitudes sol
			LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov 
					on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
			WHERE sol.empresa = pEmpresa
			AND sol.num_solicitud = pNumSol;*/--VICTOR

			SELECT sol.tipo_solicitud, sol.num_producto, sol.status_solicitud, sol.sucursal, mov.status,sol2.fecha_insert
			INTO cTp_solicitud,cNum_Producto,cStatusSolicitud, cSucursal,cStatusMovil, dtFechaSolicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov 
					on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
			LEFT OUTER JOIN bdisolic:ss_solicitudes sol2 on (sol2.empresa = pEmpresa and sol2.numcte = cNumCteBco and sol2.num_solicitud = sol.num_solicitud)
			WHERE sol.empresa = pEmpresa
			AND sol.num_solicitud = pNumSol;  			

			-------------------------------------------------------------
			--Cambios Olivia

				--SELECT brm_reing INTO cBRM_reing FROM bdicred:"informix".sd_sucursales_motor where numsucursal = cSucursal;--VVVF

			-------------------------------------------------------------
			SELECT iva 
			into diva
			FROM bdinteg:"informix".si_sucursales 
			where sucursal = cSucursal;

			/*SELECT fecha_insert
			INTO dtFechaSolicitud
			FROM bdisolic:"informix".ss_solicitudes -- Agrupar en consulta de solicitudes
			WHERE  numcte = cNumCteBco
			AND num_solicitud = pNumSol;*/

			LET dtDiaFF = LPAD(DAY(dtFechaSolicitud::DATE), 2, '0');
			LET dtMesFF = LPAD(MONTH(dtFechaSolicitud::DATE), 2, '0');
			LET dtAnoFF = LPAD(YEAR(dtFechaSolicitud::DATE), 4, '0');

			LET dtFechaSolicitud = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

			--FOREACH
				SELECT COUNT(numcte) 
				INTO iExisteCliente
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = cNumCteBco
				AND num_solicitud <> pNumSol 
				AND  tipo_solicitud = "C"
				AND status_solicitud NOT IN ('PC','AN','MC');
			--END FOREACH;

			/*UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET existecliente = iExisteCliente --alter -- OK -- OK
				WHERE num_solicitud = pNumSol;*/

			SELECT numcte_pros,status_numcte_pros
				INTO cCteProsp,cStatusSol_CteProsp
				FROM bdiprospectos:"informix".pr_cliente 
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND tipo_cliente = 3 
				AND status_numcte_pros NOT IN ('AN','PC','CN','CP');

			IF cStatusSol_CteProsp IS NULL THEN
				LET cPiloto	= '1';
			ELIF (iExisteCliente > 0) THEN
				LET cPiloto	= '1';		
			END IF;

			IF NVL(cCteProsp,'') = '' AND cPiloto = '1' THEN
				SELECT numcte_pros INTO cCteProspVig
				FROM bdiprospectos:"informix".pr_cliente 
				WHERE empresa = pEmpresa AND numcte = cNumCteBco AND tipo_cliente = 3;
			ELSE
				LET cCteProspVig = cCteProsp;
			END IF;

			/*SELECT c.tipo_alta
				INTO cTipo_Alta_CteProsp
				FROM bdisolic:"informix".ss_resum_scor_fin a, bdisolic:"informix".ss_solicitudes b, outer bdiprospectos:"informix".pr_cliente c
				WHERE a.empresa = pEmpresa 
				AND a.num_solicitud = b.num_solicitud 
				AND b.numcte = c.numcte
				AND a.num_solicitud = pNumSol;*/

			SELECT c.tipo_alta, a.num_solicitud_ref, a.meses_historia, a.situacion_pago,a.grupo
				INTO cTipo_Alta_CteProsp,cNumSolRef, pMeses_historia_grupo, pSituacion_pago_grupo, cTipoGrupo
				FROM bdisolic:"informix".ss_resum_scor_fin a, bdisolic:"informix".ss_solicitudes b, outer bdiprospectos:"informix".pr_cliente c
				WHERE a.empresa = pEmpresa 
				AND a.num_solicitud = b.num_solicitud 
				AND b.numcte = c.numcte
				AND a.num_solicitud = pNumSol;
				
			--Se agrega la consulta de sucursal y subcanal para validar que sea 8503 y verificar si viene por un subcanal
			SELECT nvl(canal_sol, 99), NVL(sub_canal_sol,'')
				INTO iCanalV1,  cSubCanal
				FROM bdisolic:"informix".ss_prospecteo_solicitudes
				WHERE num_solicitud = pNumSol 
				AND estatus <> 'F';
			 
			IF cSubCanal <> '' THEN
				LET iCanalV1 = cSubCanal;
			END IF;
			/*SELECT num_solicitud_ref
			INTO cNumSolRef	  
			FROM bdisolic:"informix".ss_resum_scor_fin -- Agrupar en colsulta previa
			WHERE empresa =  pEmpresa
			AND num_solicitud = pNumSol;*/

			LET pNumSol = pNumSol;
			LET cNumSolRef = cNumSolRef;
			
			-- 39461 Obtencion del Score Telcos para input BRM TDC (Solucion intermedia) - Para obtener y asignar el valor de scoreTelcos
			-- 09/07/2024			
			IF cTipo_movimiento = 'M' THEN
				IF cTp_solicitud = 'C' THEN
					--REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL 
					SELECT puntos_parcn, score_domicilio 
					INTO sScore_coppel, dTope_ingre
					FROM bdisolic:"informix".ss_nuevo_parametrico 
					WHERE num_solicitud = pNumSol
					AND empresa = pEmpresa;
				
				ELIF cTp_solicitud = 'T' THEN		 
					--REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL 
					SELECT puntos_parcn, score_domicilio  
					INTO sScore_coppel, dTope_ingre
					FROM bdisolic:"informix".ss_nuevo_parametrico 
					WHERE num_solicitud = cNumSolRef
					AND empresa = pEmpresa;	
				END IF;
			ELIF cTipo_movimiento = 'U' THEN
				--REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL/BANCO
				SELECT puntos_parcn, score_domicilio 
				INTO sScore_coppel, dTope_ingre
				FROM bdisolic:"informix".ss_nuevo_parametrico 
				WHERE num_solicitud = pNumSol
				AND empresa = pEmpresa;	
			END IF;	

			IF sScore_coppel IS NULL OR sScore_coppel = '' THEN
				LET sScore_coppel = 0;
			END IF;			
			
			IF dTope_ingre IS NULL OR dTope_ingre = 0 THEN
				LET dTope_ingre = 0;
			END IF;

			SELECT sc01::INTEGER
			INTO sBc_Score
			FROM bdiburo:"informix".br_sc a
			WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= cNumCteBco AND sc00 <> "004")
			AND institucion = 'BC'
			AND num_cliente = cNumCteBco AND sc00 <> "004";

			/*SELECT a.meses_historia,a.situacion_pago,a.grupo
			INTO pMeses_historia_grupo, pSituacion_pago_grupo, cTipoGrupo
			FROM bdisolic:ss_resum_scor_fin a, bdisolic:ss_solicitudes b, outer bdiprospectos:pr_cliente c -- Agrupar consulta previa
			WHERE a.empresa = pEmpresa 
			AND a.num_solicitud = b.num_solicitud 
			AND b.numcte = c.numcte
			AND a.num_solicitud = pNumSol;*/

			/*SELECT count(numcte)
				INTO sCteLargo
				FROM bdisolic:"informix".ss_clienteslargos -- Agrupar 2 consultas
				WHERE numcte = cNumCteBco 	
				AND fecha_vig_ini<= dtFechaHoy 
				AND fecha_vig_fin >= dtFechaHoy;

			SELECT count(numcte) 
				INTO sCteLargo8
				FROM bdisolic:"informix".ss_clienteslargos
				WHERE numcte = cNumCteBco
				AND fecha_vig_ini <= dtFechaHoy 
				AND fecha_vig_fin >= dtFechaHoy
				AND status = 'AC';*/--VICTOR
				
			SELECT count(ctesl.numcte) , count(ctes2.numcte)
				INTO sCteLargo,sCteLargo8
				FROM bdisolic:"informix".ss_clienteslargos ctesl-- Agrupar 2 consultas
			    LEFT JOIN bdisolic:"informix".ss_clienteslargos ctes2 on (ctes2.numcte = cNumCteBco AND ctes2.fecha_vig_ini<= dtFechaHoy AND ctes2.fecha_vig_fin >= dtFechaHoy AND ctes2.status = 'AC')
				WHERE ctesl.numcte = cNumCteBco 	
				AND ctesl.fecha_vig_ini<= dtFechaHoy 
				AND ctesl.fecha_vig_fin >= dtFechaHoy;
			
			
			-- Determina si es grupo A  -- sDeter_Grupo_A
			SELECT COUNT(numcte) 
				INTO vgrupoA
				FROM bdicred:"informix".sd_grupo_cliente 
				WHERE empresa = pEmpresa
				AND numcte  = cNumCteBco;

			EXECUTE PROCEDURE bdinteg:"informix".mesesvalidoscte (cNumCteBco)
				INTO cCodRet,iMeses_hist_Val;
			
			/*SELECT  NVL(flag2credito,0) INTO iFlag2credito -- OK
				FROM bdisolic:"informix".ss_revision_determinacion					 
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol;*/

			--FOREACH
				SELECT NVL(causa_solicitud,"")
				INTO cCausa_Sol 
				FROM bdisolic:"informix".ss_autorizacion 
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND status_solicitud = cStatusSolicitud
				AND fecha_hora = (SELECT MAX(fecha_hora) 
								FROM bdisolic:"informix".ss_autorizacion 
								WHERE empresa = pEmpresa
								AND num_solicitud = pNumSol);
			--END FOREACH;

			SELECT sc01::INTEGER 
			INTO dValor_3s -- Validar validez de la consulta
			FROM bdiburo:"informix".br_sc a
			WHERE a.rowid = (SELECT MAX(b.rowid) 
								FROM bdiburo:"informix".br_sc b
								WHERE institucion = 'CC'
								AND b.num_cliente = cNumCteBco
								AND sc00 <> "004")
			AND institucion = 'CC'
			AND num_cliente = cNumCteBco
			AND sc00 <> "004";

			FOREACH
				SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
				INTO  iSecuenciaOs,cStatusRespOs,dtFecha_Respuesta,cNumSol_Os,cTipoSolOS
				FROM  bdisolic:"informix".ss_solicitudes a
				JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
				WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) 
																from bdisolic:"informix".ss_osclientesupervisar AS d 
																WHERE d.num_solicitud = b.num_solicitud)
				AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte = cNumCteBco 
				UNION 
				SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
				FROM bdisolic:"informix".ss_osclientesupervisar
				WHERE empresa  = '001' AND num_solicitud  = cCteProspVig --cCteProsp
				AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar 
									WHERE num_solicitud  = cCteProspVig) --cCteProsp
				ORDER BY fecharespuesta DESC

				LET dtDiaFF = LPAD(DAY(dtFecha_Respuesta::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFecha_Respuesta::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFecha_Respuesta::DATE), 4, '0');

				LET dtFecha_Respuesta = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;
			END FOREACH;
			------------------------------------------------------ VARIABLES DE BANCOPPEL

			FOREACH
				SELECT num_credito,num_producto
				INTO cNumcreditoCCFF,cProducto2
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

				SELECT NVL(a.capital_mto_cuota,0)
				INTO v_comprobancoprestamo 
				FROM bdicred:"informix".sd_amortiza_creditocrd a
				WHERE a.empresa     = pEmpresa
				AND a.num_credito = cNumcreditoCCFF
				AND a.num_pago = 1;

				IF v_comprobancoprestamo IS NULL THEN
					LET v_comprobancoprestamo = 0;
				END IF;

				LET mCompro_banco = mCompro_banco + v_comprobancoprestamo;
				IF cProducto2  <> '6400' THEN
					LET mCompro_bancoPP = mCompro_bancoPP + v_comprobancoprestamo;
				END IF;
			END FOREACH;


			/*UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET mto_pagos_bco  = mCompro_banco, -- OK
					pago_tdc = dComprobanco_TDC, -- NO SE CARGA
					pago_prest = mCompro_bancoPP -- alter Ya existe -- OK
				WHERE num_solicitud = pNumSol; */


			SELECT COUNT(num_solicitud)
				INTO iSolMc
				FROM bdisolic:"informix".ss_solicitudes_mc
				WHERE empresa = pEmpresa
				AND  num_solicitud = pNumSol; 	
			
			SELECT COUNT(num_solicitud)--
				INTO iSolMcAux 
				FROM bdisolic:"informix".ss_solicitudes_mc
				WHERE empresa = pEmpresa
				AND  num_solicitud = cNumSolRef; 

			FOREACH
				SELECT NVL(credito_externo,'')  
				INTO cCredExterno
				FROM bdicred:"informix".sd_maecred
				WHERE  numcte = cNumCteBco
				AND empresa = pEmpresa
				AND status_cred = "FC" 

				SELECT COUNT(num_credito)
				INTO iCredCrd
				FROM bdicred:"informix".sd_maecredcrd
				WHERE num_credito = cCredExterno
				AND empresa = pEmpresa
				AND status_cred = "FF";

				IF iCredCrd = 0 THEN
					LET iCred_StatusFF_restru = iCred_StatusFF_restru + 1;
				END IF;
			END FOREACH;

			EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy,-1)
			INTO dtMaxFechaCorte;
			LET dtMaxFechaCorte= mdy(month(dtMaxFechaCorte),'20',year(dtMaxFechaCorte));	

			-- Creditos Riesgos son CC y FF
			LET cNumcreditoCCFF = "";
			LET cStatus_cred = "";
			LET dtFechaAper = "";
			LET cGrado_riesgo = "";
			FOREACH
				SELECT NVL(num_credito,''), status_cred,fecha_apertura
				INTO cNumcreditoCCFF, cStatus_cred, dtFechaAper
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND status_cred NOT IN ("CC","FF")   

				IF cNumcreditoCCFF <> '' THEN
					SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
					INTO dSdo_vencido
					FROM bdicred:"informix".sd_maesdos
					WHERE empresa = pEmpresa
					AND num_credito = cNumcreditoCCFF;

					IF TRIM(cStatus_cred) IN ('AA','E1') AND dSdo_vencido = 0 THEN							
						SELECT grado_riesgo_edo_resultados
						INTO cGrado_riesgo
						FROM bdicred:"informix".sd_hist_reserva
						WHERE empresa = pEmpresa
						AND num_credito = cNumcreditoCCFF
						AND fecha_corte = dtMaxFechaCorte; 
							
						IF cGrado_riesgo IS NULL THEN
							LET cGrado_riesgo = "";
						END IF;
							
						IF cGrado_riesgo = 'D' THEN
							LET iCredits_riesgoD = iCredits_riesgoD + 1;
						ELIF cGrado_riesgo = 'E' THEN
							LET iCredits_riesgoE = iCredits_riesgoE + 1;
						ELIF cGrado_riesgo = 'C' THEN
							LET iCredits_riesgoC = iCredits_riesgoC + 1;
						END IF;		
					END IF;
				END IF;      
			END FOREACH;
				
			--iMaxMontoReserva
			LET cNumcreditoCCFF = "";
			LET dSdo_vencido = 0;
			LET cGrado_riesgo = "";

			FOREACH 
				SELECT NVL(crd.num_credito,''),  MAX(reserva_edo_resultados) AS maximo
				INTO cNumcreditoCCFF, iMaxMontoReserva
				FROM bdicred:"informix".sd_maecred crd 
				INNER JOIN bdicred:"informix".sd_hist_reserva rsv ON rsv.num_credito = crd.num_credito
				WHERE crd.empresa = pempresa
				AND rsv.fecha_corte = dtMaxFechaCorte
				AND crd.numcte = cNumCteBco
				AND crd.status_cred IN ('AA','E1')
				GROUP BY crd.num_credito
				ORDER BY maximo DESC

				IF cNumcreditoCCFF <> '' THEN				
					SELECT (NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0))
						INTO dSdo_vencido
						FROM bdicred:"informix".sd_maesdos 
						WHERE empresa = pempresa
						AND num_credito = cNumcreditoCCFF;
						
					SELECT grado_riesgo_edo_resultados
						INTO cGrado_riesgo
						FROM bdicred:"informix".sd_hist_reserva
						WHERE empresa = pempresa
						AND num_credito = cNumcreditoCCFF
						AND fecha_corte = dtMaxFechaCorte;       
						
					IF dSdo_vencido = 0 AND cGrado_riesgo = 'C' THEN 
						EXIT FOREACH;
					END IF;	
				END IF;	
			END FOREACH;

			FOREACH
				SELECT LIMIT 1 (SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
				--SELECT (SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
						FROM bdicred:"informix".sd_maesdoscrd 
					WHERE empresa = pEmpresa
					AND num_credito = crd.num_credito) AS maximo 
					INTO dMaxSalVencidoCRD
				FROM bdicred:"informix".sd_maecredcrd crd
				WHERE crd.empresa = pEmpresa
				AND crd.numcte = cNumCteBco           
				AND crd.status_cred <> "FF"
				AND crd.num_producto <> '6011'
				ORDER BY maximo DESC
			END FOREACH;

			--Creditos Riesgos SIN FF
			LET cNumcreditoCCFF = "";
			LET cStatus_cred = "";
			LET dtFechaAper = "";
			LET cGrado_riesgo = "";

			FOREACH 
				SELECT 
				NVL(num_credito,''), status_cred, fecha_apertura
				INTO cNumcreditoCCFF, cStatus_cred, dtFechaAper
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco
				AND num_producto <> '6011'
				AND status_cred <> "FF"			

				IF cNumcreditoCCFF <> '' THEN
					SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
					INTO dSdo_vencidocrd
					FROM bdicred:"informix".sd_maesdoscrd
					WHERE empresa = pEmpresa
					AND num_credito = cNumcreditoCCFF;

					IF (TRIM(cStatus_cred) in ('AA','E1') AND dSdo_vencidocrd = 0) THEN	
						SELECT grado_riesgo_edo_resultados
						INTO cGrado_riesgo
						FROM bdicred:"informix".sd_hist_reserva
						WHERE empresa = pEmpresa
						AND num_credito = cNumcreditoCCFF
						AND fecha_corte = dtMaxFechaCorte; 

						IF cGrado_riesgo IS NULL THEN
							LET cGrado_riesgo = "";
						END IF;
						
						IF (cGrado_riesgo = 'D') THEN
							LET iCredRiesgoD_sinFF = iCredRiesgoD_sinFF + 1;
						ELIF (cGrado_riesgo = 'E') THEN
							LET iCredRiesgoE_sinFF = iCredRiesgoE_sinFF + 1;
						ELIF (cGrado_riesgo = 'C') THEN
							LET iCredRiesgoC_sinFF = iCredRiesgoC_sinFF + 1;
						END IF;
					END IF;    
				END IF;			
			END FOREACH;

			LET dSdo_vencidocrd = 0;
			LET cNumcreditoCCFF = "";
			LET dtFechaAper = "";
			FOREACH --Max monto reserva para (creditos con status (AA o E1) Y Saldo vencido =0 y Grado de riesgo= C)
				SELECT NVL(crd.num_credito,''), MAX(reserva_edo_resultados) AS reserva
				INTO cNumcreditoCCFF, dmaxMontoReservaRiesgoC_sinFF
				FROM bdicred:"informix".sd_maecredcrd crd
				INNER JOIN bdicred:"informix".sd_hist_reserva rsv ON rsv.num_credito = crd.num_credito
				WHERE rsv.fecha_corte = dtMaxFechaCorte
				AND crd.empresa = pEmpresa
				AND rsv.empresa = crd.empresa
				AND crd.numcte = cNumCteBco 
				AND crd.status_cred IN ('AA','E1')
				AND crd.num_producto <> '6011'
				GROUP BY crd.num_credito
				ORDER BY reserva DESC

				IF cNumcreditoCCFF <> '' THEN
					
					SELECT (NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0))
					INTO dSdo_vencidocrd
					FROM bdicred:"informix".sd_maesdoscrd 
					WHERE empresa = pEmpresa
					AND num_credito = cNumcreditoCCFF;
					
					SELECT grado_riesgo_edo_resultados
					INTO cGrado_riesgo
					FROM bdicred:"informix".sd_hist_reserva
					WHERE empresa = pEmpresa
					AND num_credito = cNumcreditoCCFF
					AND fecha_corte = dtMaxFechaCorte;       
					
					IF dSdo_vencidocrd = 0 AND cGrado_riesgo = 'C' THEN 
						EXIT FOREACH;
					END IF;	
				END IF;
			END FOREACH;
			--OPT CASE
			SELECT COUNT(numcte) 
				INTO iCred_StatusDif_FF
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa 
				AND numcte = cNumCteBco 		       
				AND status_cred <> "FF";

			SELECT COUNT(num_credito)
				INTO iCuentasStatusCVsinFF 
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco 
				AND status_cred =  "CV"
				AND num_producto <> '6011';

			SELECT COUNT(num_credito) 
				INTO iCtas_StatusDif_FF_6011
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco          
				AND status_cred <> "FF"
				AND num_producto = '6011';

			SELECT COUNT(num_credito) 
				INTO iCtas_StatusFF_6011
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco          
				AND status_cred = "FF"
				AND num_producto = '6011';

			/*UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET ctas_statusff_6011 = iCtas_StatusFF_6011 --alter -- OK
				WHERE num_solicitud = pNumSol;*/
				
			SELECT COUNT(num_credito)
				INTO iCtas_StatusCV
				fROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND numcte = cNumCteBco 		
				AND status_cred = "CV";

			SELECT COUNT(num_credito)
				INTO iCred_StatusFC
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = '001'
				AND numcte = cNumCteBco  
				AND status_cred = "FC";

			/*FOREACH--join 
				SELECT LIMIT 1 (SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0) -- cambiar por join
				FROM bdicred:"informix".sd_maesdos 
				WHERE empresa = pEmpresa
				AND num_credito = crd.num_credito) AS maximo 
				INTO iMaxSalVencidoBancoppel
				FROM bdicred:"informix".sd_maecred crd
				WHERE crd.empresa = pEmpresa
				AND crd.numcte = cNumCteBco 
				AND status_cred NOT IN ("CC","FF")
				ORDER BY maximo DESC
			END FOREACH;*/--VICTOR
			
				SELECT NVL(SUM(NVL(maes.monto_vencido,0) + NVL(maes.mto_venc_trasp,0)),0) -- cambiar por join
				INTO iMaxSalVencidoBancoppel
				FROM bdicred:"informix".sd_maesdos maes
				INNER JOIN bdicred:"informix".sd_maecred crd ON crd.empresa = pEmpresa AND crd.num_credito = maes.num_credito AND crd.status_cred NOT IN ("CC","FF")
				WHERE maes.empresa = pEmpresa
				AND maes.num_credito = crd.num_credito
				AND crd.numcte = cNumCteBco; 
			

			IF cNum_Producto = '8100' THEN  --ACP

				SELECT flag_oro
					INTO sFlag_oro
					FROM bdisolic:"informix".ss_solicitudes_tdcoro
					WHERE empresa = pEmpresa
					AND numcte = cNumCteBco
					AND numero_solicitud_oro = pNumSol;
					
			ELSE
			
				SELECT flag_oro
					INTO sFlag_oro
					FROM bdisolic:"informix".ss_solicitudes_tdcoro
					WHERE empresa = pEmpresa
					AND numero_solicitud = pNumSol;
					
			END IF;		

			------- dComprobanco_TDC
			SELECT valor
				INTO v_compromi_tdc
				FROM bdisolic:"informix".ss_param
				WHERE empresa= pEmpresa AND secuencia= 35;

			LET cNumcreditoCCFF = "";

			FOREACH
				SELECT num_credito
					INTO cNumcreditoCCFF
					FROM bdicred:"informix".sd_maecred
					WHERE empresa = pEmpresa
					AND numcte = cNumCteBco
					AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

				SELECT NVL(a.sdo_cap_insoluto,0)
					INTO dComprobanco_TDC
					FROM bdicred:"informix".sd_maesdos a
					WHERE a.empresa     = pEmpresa
					AND a.num_credito = cNumcreditoCCFF;

				IF dComprobanco_TDC IS NULL or dComprobanco_TDC <= 0 THEN
					LET dComprobanco_TDC = 0;
				ELSE
					IF Round(dComprobanco_TDC,-1) - dComprobanco_TDC < 0 THEN
						LET dComprobanco_TDC = Round(dComprobanco_TDC,-1) + 10;
					ELSE
						LET dComprobanco_TDC = Round(dComprobanco_TDC,-1);
					END IF;
				END IF;

				LET v_comprobanco = round((v_comprobanco + dComprobanco_TDC) * v_compromi_tdc ,-1);
			END FOREACH;

			LET dComprobanco_TDC = v_comprobanco;	
			
			
			-- INI Realiza un solo UPDATE a ss_revision_determinacion
			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET 				
					b_ine = cB_INE,
					habita_en = cHabita_en, 
					cod_ult_identif = cCod_Ult_Identif,
					entidad = cEntidad,
					ClvEdoCob = vClvEdoCob,
					localidad = vLocalidad,
					telefono_domicilio = cTelCasa,
					telefono_trabajo = cTelTrabajo,
					valida_cel = sValida_Cel,
					existecliente = iExisteCliente,
					mto_pagos_bco  = mCompro_banco,
					pago_tdc = dComprobanco_TDC, 
					pago_prest = mCompro_bancoPP,
					ctas_statusff_6011 = iCtas_StatusFF_6011
				WHERE num_solicitud = pNumSol; 
				--PRUEBA EN MAQUETA
			-- FIN Realiza un solo UPDATE a ss_revision_determinacion			
			
			

			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_act_riesgo( pEmpresa,cNumCteBco) -- Nota obtener consultas
			INTO cCodRet,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo;

			LET cDescripcion = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cDescripcion,'ÃÂ¡','a'),'ÃÂ©','e'),'ÃÂ­','i'),'ÃÂ³','o'),'ÃÂº','u'),'ÃÂ','A'),'ÃÂ','E'),'ÃÂ','I'),'ÃÂ','O'),'ÃÂ','U');

			LET cDescripcion =  REPLACE(cDescripcion, ',', ' /');

			EXECUTE PROCEDURE bdisolic:"informix".sp_OStelConsultaResultado (pEmpresa, pNumSol)--Actualmente no se valida
				INTO cCodRet, cResultadoOsTel, cTieneOstel, cEnvioCat;

			IF cCodRet <> '000' THEN
				LET cCodRet = '00001';
				RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
				nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
				NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
				NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
				NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
				nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
				nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
				nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
				nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
				nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
				nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
				nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
				nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
				nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
				nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
				nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
				nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,0), Nvl(cInstCta_MayorMOP,''), 
				nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,0), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
				NVL(iMM_Histo_12m,0), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
				nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
				nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
				nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
				nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,0), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
				nvl(iNumCtas_ClvOb,0), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
				nvl(vClvExclusionMasReciente,'0'), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
				nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
				nvl(iMM_act_Bancos,0), nvl(iMM_hist_alto_Bancos,0), nvl(iMM_hist_Bancos,0), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
				nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
				nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
				nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
				nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,0),	NVL(iMaxMOP_actBancos,0), 
				NVL(iMaxMOP_histAltBancos,0), nvl(iMaxMOP_histBancos,0), nvl(BC_93,0), nvl(iMaxMOP_actCtas,0), nvl(iMaxMOP_histAltCtas,0),
				nvl(iMaxMOP_histCtas,0), nvl(dSituacionPagoCoppel,0), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
				nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
				nvl(sFlagHuella,0), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
				nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,0), 
				NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,0), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
				NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,0), nvl(iCanal_Sol,0), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,0), 
				nvl(iSecuenciaOs,0), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
				nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
				NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
				nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
				nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
				NVL(cEntidad,''), NVL(sCteLargo,0), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,0), NVL(dValor_3s,0),
				nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
				nvl(dCompromisos,0), nvl(sFlagBuenPago12,0), NVL(sFlagBuenPago30,0), NVL(sEntidad_Localidad,0), nvl(cNuevoStatusOstel,''), 
				nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,99), 
				nvl(HR0050,-1), nvl(TR0002,-999), nvl(TR0001,-999), nvl(IQ0002,0), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,0), 
				NVL(dSaldo_limit_credi,0), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
				nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
				nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,0), nvl(pctBankILTL,0), nvl(pctTL30pDaysEverColl,'0'), 
				nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,0), nvl(lowestRatingRevOpen,0),
				nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,-1), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,0), 
				nvl(numFinInq0to5Mos,0), nvl(maxDelqEver,99), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,0),
				nvl(num_sumasaldoscuentasabiertas,0), nvl(num_sumalineascuentasabiertas,0), nvl(pct_usocuentasabiertas,0),
				nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
				nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
				nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
				nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
				nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
				nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
				nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
				nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
				NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
				NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
				NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,'0');
			END IF;

			LET cCodRet = '000000';
			--------------
			SELECT COUNT(a.status_solicitud) 
				INTO sFlagForzarEnvioMC -- Bandera para el envio forzado de solicitud a MC
				FROM bdisolic:"informix".ss_solicitudes s
				LEFT JOIN bdisolic:"informix".ss_autorizacion a ON s.empresa = a.empresa AND a.num_solicitud = s.num_solicitud
				WHERE s.empresa = pEmpresa
				AND s.numcte = cNumCteBco
				AND s.num_solicitud <> pNumSol
				AND s.fecha_hora = (SELECT MAX(fecha_hora)
										FROM bdisolic:"informix".ss_solicitudes 
										WHERE empresa = pEmpresa
										AND numcte = cNumCteBco
										AND num_solicitud <> pNumSol 
										--AND status_solicitud NOT IN('AN','PC') AND num_producto IN('6800','6001','6300','7600','7700'))
										AND status_solicitud NOT IN('AN','PC') AND num_producto IN (SELECT num_producto
																										FROM bdicred:"informix".sd_definicion
																										WHERE empresa = pEmpresa
																										and envio_mesa_control = '1'))
				AND a.status_solicitud = 'CM' AND s.status_solicitud IN('CM','CN');

			------------------------------------------------------VARIABLES DE BURO
			LET vClvExclusionMasReciente = '0';
			LET cInstitucionClvExclusionMasReciente = '';
			FOREACH
				select institucion,TRIM(sc01)
					into cInstitucionClvExclusionMasReciente, vClvExclusionMasReciente
					from bdiburo:"informix".br_sc
					where num_cliente = cNumCteBco
					order by sc01 desc		
			
				IF (NVL(vClvExclusionMasReciente,'') != '')  THEN
					LET vClvExclusionMasReciente = vClvExclusionMasReciente;
					LET cInstitucionClvExclusionMasReciente = cInstitucionClvExclusionMasReciente;
					EXIT FOREACH;
				ELSE
					LET vClvExclusionMasReciente = '0';
					LET cInstitucionClvExclusionMasReciente = '';
				END IF;
			END FOREACH;

			SELECT valor 
				INTO dMaxMtoUdi
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = "309";

			SELECT TRIM(valor) 
				INTO vCodUdi
				FROM bdinteg:"informix".si_param
				WHERE empresa = pEmpresa
				AND cod_param = 16;

			SELECT TRIM(valor) 
				INTO vCodUs
				FROM bdinteg:"informix".si_param
				WHERE empresa = pEmpresa
				AND cod_param = 17;

			SELECT TRIM(valor)
				INTO vClase
				FROM bdicred:"informix".sd_param
				WHERE empresa = pEmpresa
				AND cod_param = "336";

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa,dtFechaHoy,vCodUdi,vClase,'0')
				INTO cCodRet,vTpCambioUdi;

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa,dtFechaHoy,vCodUs,vClase,'1')
				INTO cCodRet,vTpCambioUs;

			-- cInstCta_MayorMOP, iMax_MOP, dMonto_UDIS_MayorMOP
			LET vCuantos = 0;
			FOREACH
				SELECT institucion, nvl(tl26,''), round(CASE WHEN tl08 = 'N$' 
																OR tl08   = 'MX' THEN  (nvl(b.tl24,0))/vTpCambioUdi
																WHEN tl08 = 'US' THEN ((nvl(b.tl24,0) * vTpCambioUs)) /vTpCambioUdi
																WHEN tl08 = 'UD' THEN   nvl(b.tl24,0) 
															ELSE nvl(b.tl24,0) 
															END,2) as mtoudis 
				INTO cInst_MayorMOP, cMax_MOP, cMonto_UDIS_MayorMOP
				FROM bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND NVL(tl26,'') <> ''
				AND b.tl11 = c.tipo
				and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:"informix".ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				AND b.tl26 NOT IN ('UR')
				ORDER BY tl26 DESC
				
				IF EXISTS(SELECT 1 FROM bdiburo:br_tlmop WHERE codigo = cMax_MOP AND status_cons IN (1,3)) AND cMonto_UDIS_MayorMOP >= dMaxMtoUdi THEN
					LET vCuantos = 1;
					LET cInstCta_MayorMOP = cInst_MayorMOP;
					LET iMax_MOP = cMax_MOP;
					LET dMonto_UDIS_MayorMOP = cMonto_UDIS_MayorMOP;
					EXIT FOREACH;
			   END IF;
				
			END FOREACH;

			-- Maximos MOP historicos por meses
			let vCuantos = 0;
			let i = 0;
			let var_i = 0;
			let bandera6 = 0;
			let bandera12 = 0;
			let bandera30 = 0;
			let sFlagBuenPago12 = 0;
			let sFlagBuenPago30 = 0;
			FOREACH
				SELECT 	institucion, tl27,
						round(CASE  WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl36,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((nvl(b.tl36,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   nvl(b.tl36,0) 
								ELSE nvl(b.tl24,0) END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				INTO vInstitucion, vTl27, vMontoUdis, vmeses_pos
				FROM bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND NVL(tl26,'') <> ''
				AND b.tl11=c.tipo
				and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				ORDER BY tl17 DESC
			
				-- VALIDAR 6 MESES
				let vmeses6 = '';
				let vmeses12 = '';
				let vmeses30 = '';

				for var_i = 1 to case when vmeses_pos > 6 then 6 else vmeses_pos end
					let vmeses6 = vmeses6||'0';
				end for;

				let vmeses6 = replace(replace(replace(replace(vmeses6||substr(vTl27,1,6),'-','0'),'X','0'),'U','0'),' ','0');
				for var_i = 1 to 6
					if (substr(vmeses6,var_i,1) >= 4 and vMontoUdis >= dMaxMtoUdi and bandera6 = 0) then
						LET vCuantos = 1;
						LET iMax_MOP_Hist_6m = substr(vmeses6,var_i,1);
						LET cInstCta_MayorMOP_6m = vInstitucion;
						LET dMontoUDIS_MM_6m = vMontoUdis;
						LET bandera6 = 1;
						exit for;
					end if;
				end for;
			
				-- VALIDAR 12 MESES
				let vCuantos = 0;
				let var_i = 0;

				for var_i = 1 to case when vmeses_pos > 12 then 12 else vmeses_pos end
					let vmeses12 = vmeses12||'0';
				end for;

				let vmeses12 = replace(replace(replace(replace(vmeses12||substr(vTl27,1,12),'-','0'),'X','0'),'U','0'),' ','0');
				let var_i = 0;

				for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) >= 4 and vMontoUdis >= dMaxMtoUdi and bandera12 = 0) then
							LET iMM_Histo_12m = substr(vmeses12,var_i,1);
							LET cInstCta_MayorMOP_12m = vInstitucion;
							LET dMontoUDIS_MM_12m = vMontoUdis;
							LET bandera12 = 1;	
							
						if (substr(vmeses12,var_i,1) = 4) then
							LET vCuantos = 2;
							LET sFlagBuenPago12 = vCuantos;
						else
							LET vCuantos = 1;
							LET sFlagBuenPago12 = vCuantos;
						end if;
						exit for;
					end if;
				end for;

				--VALIDAR 30 MESES
				let vCuantos = 0;
				let var_i = 0;
				let vmeses30 = '';

				for var_i = 1 to case when vmeses_pos > 30 then 30 else vmeses_pos end
					let vmeses30 = vmeses30||'0';
				end for;

				let vmeses30 = replace(replace(replace(replace(vmeses30||substr(vTl27,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				
				for var_i = 1 to 30
					if (substr(vmeses30,var_i,1) >= 5 and vMontoUdis >= dMaxMtoUdi and bandera30 = 0) then
						LET iMM_Histo_30m = substr(vmeses30,var_i,1);
						LET cInstCta_MayorMOP_30m = vInstitucion;
						LET bandera30 = 1;
						LET vCuantos = 2;
						LET sFlagBuenPago30 = vCuantos;
						exit for;
					end if;
				end for;
			END FOREACH;

			LET vCuantos = 0;
			LET cuenta = 0;
			LET v_factor =0;
			FOREACH 
				SELECT tl08,tl12,b.factor
				INTO v_moneda,v_monto,v_factor		
					FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
					WHERE a.tl11 = b.tipo
					AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
					AND num_cliente = cNumCteBco
				UNION ALL
				SELECT tl08,tl12,b.factor
					FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
					WHERE a.tl11 = b.tipo
						AND a.tl06 = 'M' AND a.tl07 = 'RE'
						AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
						AND num_cliente = cNumCteBco
					
				IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
					LET v_tot_tp = v_monto * v_factor; 
					IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_monto = 0; END IF;
				END IF;
				IF v_moneda = 'UD' THEN  
					LET v_tot_tp = vTpCambioUdi * (v_monto * v_factor);
					IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_monto = 0; END IF;
				END IF;
				IF v_moneda = 'US' THEN
					LET v_tot_tp = vTpCambioUs * (v_monto * v_factor);
					IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
					ELSE LET v_monto = 0; END IF;
				END IF;										
				LET cuenta = cuenta + 1; 		
			END FOREACH; 
			
			LET mPagoMinimo = v_total;
			LET NumCuentaPagoMinimo = cuenta;	
			LET dCompromisos = mPagoMinimo;
			---------------- Institucion y Monto UDIS 30 meses que generan Rechazo
			let vCuantos = 0;
			let i = 0;
			let var_i = 0;
			let bandera30 = 0;
			LET dMotoUDIS_MM_30m_Rech = 0;
			LET cInstCta_MM_30m_Rech = '';
			FOREACH
				SELECT 	institucion, tl27,
						round(CASE 	WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl36,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((nvl(b.tl36,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   nvl(b.tl36,0) 
							ELSE nvl(b.tl24,0) END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				INTO vInstitucion, vTl27, vMontoUdis, vmeses_pos
				FROM bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND NVL(tl26,'') <> ''
				AND b.tl11=c.tipo
				and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				ORDER BY tl17 DESC

				let vCuantos = 0;
				let i = 0;
				let vmeses30 = '';

				for var_i = 1 to case when vmeses_pos > 30 then 30 else vmeses_pos end
					let vmeses30 = vmeses30||'0';
				end for;

				let vmeses30 = replace(replace(replace(replace(vmeses30||substr(vTl27,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				for var_i = 1 to 30
					if (substr(vmeses30,var_i,1) >= 5 and vMontoUdis >= dMaxMtoUdi) then
						LET vCuantos = 1;
						exit for;
					end if;
				end for;

				if (vCuantos = 1) then
					LET dMotoUDIS_MM_30m_Rech = vMontoUdis;
					LET cInstCta_MM_30m_Rech = vInstitucion;
				end if;
			END FOREACH;

			-------------------- dMontoUDIS_MM_Rech
			let vCuantos = 0;
			let i = 0;
			let var_i = 0;
			let bandera12 = 0;
			LET dMontoUDIS_MM_Rech = 0;

			FOREACH
				SELECT 	institucion, tl27,
						round(CASE 	WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl36,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((nvl(b.tl36,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   nvl(b.tl36,0) 
							ELSE nvl(b.tl24,0) END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				INTO vInstitucion, vTl27, vMontoUdis, vmeses_pos
				FROM bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND NVL(tl26,'') <> ''
				AND b.tl11=c.tipo
				and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				ORDER BY tl17 DESC

				let vCuantos = 0;
				let i = 0;
			
				let vmeses12 = replace(replace(replace(replace(vmeses12||substr(vTl27,1,12),'-','0'),'X','0'),'U','0'),' ','0');
				for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) >= 5 and vMontoUdis >= dMaxMtoUdi) then
						LET vCuantos = 1;
						exit for;
					end if;
				end for;

				if (vCuantos = 1) then
					LET dMontoUDIS_MM_Rech = vMontoUdis;
				end if;
			END FOREACH;

			-------------------- Numero de cuentas
			let i = 0;
			let var_i = 0;
			--let dMonto_UDIS_MayorMOP = 0;
			let mMonto_UDIS_MayorMOP = 0;
			FOREACH
				SELECT institucion, tl27, case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
											then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
											else 0
											end +
											month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos,
											round(CASE WHEN tl08 = 'N$' 
																OR tl08   = 'MX' THEN  (nvl(b.tl24,0))/vTpCambioUdi
																WHEN tl08 = 'US' THEN ((nvl(b.tl24,0) * vTpCambioUs)) /vTpCambioUdi
																WHEN tl08 = 'UD' THEN   nvl(b.tl24,0) 
															ELSE nvl(b.tl24,0) 
															END,2) as mtoudis 
				INTO cInstitucionCtas, cMOPmeses,vmeses_ctas, mMonto_UDIS_MayorMOP --dMonto_UDIS_MayorMOP
				FROM bdiburo:"informix".br_tl b,  bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND   b.tl11 = c.tipo
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS')

				--if nvl(dMonto_UDIS_MayorMOP,0) < dMaxMtoUdi THEN
				if nvl(mMonto_UDIS_MayorMOP,0) < dMaxMtoUdi THEN
					continue foreach;
				end if;

				let vmeses12 = '';
				let vmeses30 = '';
				
				--  MOP=4 =5 >5 en los Ultimos 12 meses con UDIS>=100, no considera telecomunicaciones ni servicios
				let var_i = 0;

				for var_i = 1 to case when vmeses_ctas > 12 then 12 else vmeses_ctas end
					let vmeses12 = vmeses12||'0';
				end for;

				let vmeses12 = replace(replace(replace(replace(vmeses12||substr(cMOPmeses,1,12),'-','0'),'X','0'),'U','0'),' ','0');
				let var_i = 0;

				for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) = 4) then
						LET iNumCtasMOP_4_12m = iNumCtasMOP_4_12m + 1;
					ELIF (substr(vmeses12,var_i,1) = 5) THEN
						LET iNumCtasMOP_5_12m = iNumCtasMOP_5_12m + 1;
					ELIF (substr(vmeses12,var_i,1) >5) THEN
						LET iNumCtasMOP_mayor5_12m = iNumCtasMOP_mayor5_12m + 1;		
					end if;
				end for;

				--  MOP=4 =5 >5 en los Ultimos 30 meses con UDIS>=100, no considera telecomunicaciones ni servicios
				let var_i = 0;

				for var_i = 1 to case when vmeses_ctas > 30 then 30 else vmeses_ctas end
					let vmeses30 = vmeses30||'0';
				end for;

				let vmeses30 = replace(replace(replace(replace(vmeses30||substr(cMOPmeses,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				let var_i = 0;

				for var_i = 1 to 30
					if (substr(vmeses30,var_i,1) = 4) THEN
						LET iNumCtasMOP_4_30m = iNumCtasMOP_4_30m + 1;
					ELIF (substr(vmeses30,var_i,1) = 5) THEN
						LET iNumCtasMOP_5_30m = iNumCtasMOP_5_30m + 1;
					ELIF (substr(vmeses30,var_i,1) >5) THEN
						LET iNumCtasMOP_mayor5_30m = iNumCtasMOP_mayor5_30m + 1;		
					end if;
				end for;
			END FOREACH;

				-------------------- Numero de cuentas con 1 o 2
			let i = 0;
			let var_i = 0;
			
			FOREACH
				SELECT institucion, tl27, case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
											then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
											else 0
											end +
											month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos,
											round(CASE WHEN tl08 = 'N$' 
																OR tl08   = 'MX' THEN  (nvl(b.tl24,0))/vTpCambioUdi
																WHEN tl08 = 'US' THEN ((nvl(b.tl24,0) * vTpCambioUs)) /vTpCambioUdi
																WHEN tl08 = 'UD' THEN   nvl(b.tl24,0) 
															ELSE nvl(b.tl24,0) 
															END,2) as mtoudis 
				INTO cInstitucionCtas, cMOPmeses,vmeses_ctas, mMonto_UDIS_MayorMOP --dMonto_UDIS_MayorMOP
				FROM bdiburo:"informix".br_tl b,  bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND   b.tl11 = c.tipo
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS')

				--if nvl(dMonto_UDIS_MayorMOP,0) < dMaxMtoUdi THEN
				if nvl(mMonto_UDIS_MayorMOP,0) < dMaxMtoUdi THEN
					continue foreach;
				end if;

				let vmeses12 = '';
				let vmeses30 = '';
				
				--  MOP=4 =5 >5 en los Ultimos 12 meses con UDIS>=100, no considera telecomunicaciones ni servicios y en los 6 meses mas recientes con 1 o 2
				let var_i = 0;
				let var_j = 0;

				for var_i = 1 to case when vmeses_ctas > 12 then 12 else vmeses_ctas end
					let vmeses12 = vmeses12||'0';
				end for;

				let vmeses12 = replace(replace(replace(replace(vmeses12||substr(cMOPmeses,1,12),'-','0'),'X','0'),'U','0'),' ','0');
				let var_i = 0;

				for var_i = 1 to 6
					if(substr(vmeses12,var_i,1) in ('1','2')) then
						for var_j = 1 to 12 
							if (substr(vmeses12,var_i,1) = 4) then
								LET iMOP4_12mCon1o2 = iMOP4_12mCon1o2 + 1;
							end if;
							if (substr(vmeses12,var_i,1) = 5) THEN
								LET iMOP5_12mCon1o2 = iMOP5_12mCon1o2 + 1;
							end if;
							if (substr(vmeses12,var_i,1) >5) THEN
								LET iMOPmayor5_12mCon1o2 = iMOPmayor5_12mCon1o2 + 1;		
							end if;
						end for;
					end if;
				end for;

				--  MOP=4 =5 >5 en los Ultimos 30 meses con UDIS>=100, no considera telecomunicaciones ni servicios y en los 12 meses mas recientes con 1 o 2
				let var_i = 0;
				let var_j = 0;

				for var_i = 1 to case when vmeses_ctas > 30 then 30 else vmeses_ctas end
					let vmeses30 = vmeses30||'0';
				end for;

				let vmeses30 = replace(replace(replace(replace(vmeses30||substr(cMOPmeses,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				let var_i = 0;

				for var_i = 1 to 12
					if(substr(vmeses30,var_i,1) in ('1','2')) then
						for var_j = 1 to 30
							if (substr(vmeses30,var_i,1) = 4) THEN
								LET iCtasMOP_4_30mCon1o2 = iCtasMOP_4_30mCon1o2 + 1;
							end if;
							IF (substr(vmeses30,var_i,1) = 5) THEN
								LET iCtasMOP_5_30mCon1o2 = iCtasMOP_5_30mCon1o2 + 1;
							end if;
							IF (substr(vmeses30,var_i,1) >5) THEN
								LET iCtasMOP_mayor5_30mCon1o2 = iCtasMOP_mayor5_30mCon1o2 + 1;		
							end if;
						end for;
					end if;
				end for;
			END FOREACH;

			--Numero de cuentas que tienen clave de observacion FD,PS,SU,CV,PC,SG,SP,SR,UP,FR en BurÃÂ¿ÃÂ³, no considera comunicaciones y servicios

			FOREACH
				SELECT 	round(CASE 	WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) 
								ELSE nvl(b.tl24,0) END,2) 
				INTO dMontoUdis 
				FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND a.status = b.tl30
				AND a.rango_rechazo IN ('1','3')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:"informix".ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				AND NVL(tl26,'') <> ''
				AND b.tl11 = c.tipo
				and b.tl30 in ('FD','PS','SU','CV','PC','SG','SP','SR','UP','FR')
				ORDER BY tl26 DESC

				if nvl(dMontoUdis,0) >= dMaxMtoUdi THEN
					let iNumCtas_ClvOb = iNumCtas_ClvOb + 1;
				end if; 
			END FOREACH;

			--Corresponde al nombre de la institucion de la observacion mas reciente
			LET cInstitucion ='';
			LET cClvObser='';
			LET dMontoUdis = 0;
			FOREACH
				SELECT limit 1 institucion,b.tl30,
						round(CASE 	WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0))/vTpCambioUdi
									WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs)) /vTpCambioUdi
									WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) 
								ELSE nvl(b.tl24,0) END,2) 
				INTO cInstitucion,cClvObser, dMontoUdis 
				FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl b, bdisolic:"informix".ss_circulo_frecpag c
				WHERE b.num_cliente  = cNumCteBco
				AND a.status = b.tl30
				AND a.rango_rechazo IN ('1','3')
				and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:"informix".ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				AND NVL(tl26,'') <> ''
				AND b.tl11 = c.tipo
				and b.tl30 in ('FD','PS','SU','CV','PC','SG','SP','SR','UP','FR')
				ORDER BY tl26 DESC
			END FOREACH;	
			--------------------- Maximos MOPs BANCOS 
			/*SELECT MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
				INTO iMM_act_Bancos
				FROM bdiburo:br_tl WHERE num_cliente = cNumCteBco
				AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo from bdiburo:"informix".br_tltco where status_cons=1);

			SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMM_hist_alto_Bancos
				FROM bdiburo:br_tl WHERE num_cliente = cNumCteBco
				AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo from bdiburo:"informix".br_tltco where status_cons=1);*/--VICTOR

			IF cInstitucion IS NULL THEN
			LET cInstitucion = '';
			END IF;
			
			IF cClvObser IS NULL THEN
			LET cClvObser = '';
			END IF;
			
			IF dMontoUdis IS NULL THEN
			LET dMontoUdis = 0;
			END IF;
			
			
			SELECT MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
				   MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMM_act_Bancos,iMM_hist_alto_Bancos
				FROM bdiburo:br_tl WHERE num_cliente = cNumCteBco
				AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo from bdiburo:"informix".br_tltco where status_cons=1);
			
			LET var_i = 0;
			LET CantTl27 = 0;
			LET CadenaTl27 = '';
			LET contenedor = '';
			LET comparador = 0;
			LET iMM_hist_Bancos = 0;
			FOREACH
				SELECT length(trim (tl27)), tl27
					INTO CantTl27 , CadenaTl27
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo from bdiburo:"informix".br_tltco where status_cons=1)

				if nvl(CadenaTl27,'') = '' THEN
					continue foreach;
				end if;

				for var_i = 1 to CantTl27
					IF (SUBSTR(CadenaTl27,var_i,1) NOT IN ('U','X', 'D', '-', ' ', '0') ) THEN
						LET contenedor = SUBSTR(CadenaTl27,var_i,1);
						IF(contenedor::INTEGER > comparador) THEN
							LET comparador = contenedor;
						END IF;
					END IF;
				end for;
				LET iMM_hist_Bancos = comparador;
			END FOREACH;

			--------------------- Numero de cuentas del cliente que son "Banco,Bancos,Bancoppel" ,tl06 = R	
			SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO MOPHistoricoAltoTl38
				FROM bdiburo:br_tl WHERE num_cliente = cNumCteBco;

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl38
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco;
			--END FOREACH;

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl27
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco;
			--END FOREACH;	

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_tl26
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06 = 'R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco;
			--END FOREACH;	

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasBancosMOP_act_hist_alto
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('BANCO','BANCOPPEL','BANCOS')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco;
			--END FOREACH;

			--------------------- Numero de cuentas del cliente que son "'COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL'"
			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl38
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND tl38 = MOPHistoricoAltoTl38
					AND num_cliente = cNumCteBco;
			--END FOREACH;

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl26
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl26 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco;
			--END FOREACH;	

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasComServMOP_tl27
					FROM bdiburo:"informix".br_tl
					WHERE  tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl06='R'
					AND tl27 in ('2','3','4','5','6','7','96','97','99') 
					AND num_cliente = cNumCteBco;
			--END FOREACH;	

			--FOREACH
				SELECT count (num_cliente)
					INTO iCtasCSM_act_hist_alto
					FROM bdiburo:"informix".br_tl
					WHERE (tl26 in ('2','3','4','5','6','7','96','97','99') 
							OR tl27 in ('2','3','4','5','6','7','96','97','99') )
					AND num_cliente = cNumCteBco
					AND tl02 IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
					AND tl38 = MOPHistoricoAltoTl38
					AND tl06='R';
			--END FOREACH;	

			------------------------------------------------------ VARIABLES DE PARAMETRICOS
			-- VARIABLE HR0048 Numero de cuentas abiertas con 12 meses o mas de antiguedad

			LET HR0048 = -1;
			LET hr0048_aux = 0;
			
			IF SUBSTR(pNumSol,1,2) <> '78' THEN   
				SELECT NVL(Count(0),0) INTO HR0048 From (
						SELECT count(num_cliente) 
						FROM bdiburo:"informix".br_tl a
						WHERE num_cliente = cNumCteBco
						AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
						AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 
						AND (((year(dtFechaHoy) - year(nvl(tl13,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl13,dtFechaHoy)))) >= 12 -- fecha apertura
						AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
						AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
						GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
					);  -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.

					-- Obtiene en caso de que tenga cuenta, pero que no cumplan con la condicion del tiempo.
				SELECT NVL(Count(0),0) INTO hr0048_aux From (
					SELECT count(num_cliente)
					FROM bdiburo:"informix".br_tl a WHERE num_cliente = cNumCteBco
					AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
					AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 		   
					AND (((year(dtFechaHoy) - year(nvl(tl13,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl13,dtFechaHoy)))) < 12 -- fecha apertura
					AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
				);
						-- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.
			end if;

			IF HR0048 = 0  AND NVL(pSIC,'X') != 'X' THEN
				LET HR0048 = -999;
			END IF;

			IF HR0048 = 0 AND hr0048_aux >= 1 THEN -- Si tiene cuentas pero no cumplen condicion del tiempo.
				LET HR0048 = -997;
			END IF;

			-------------------- VARIABLE: UT0034 Porcentaje de utilizacion en cuentas revolventes bancarias. Grupo 51
			LET UT0034 = -999;
			LET ut0034_aux = 0;
			LET vSum_bal  = 0;
			LET vSum_higcred = 0;
			IF SUBSTR(pNumSol,1,2) <> '78' THEN
				Select Sum(rev_bal), sum(max_cred) INTO vSum_bal, vSum_higcred From (
					SELECT Sum( nvl(tl22,0)) rev_bal, Sum((case when tl23 > tl21 then tl23 else tl21 end )) max_cred
					FROM bdiburo:br_tl a
					WHERE num_cliente = cNumCteBco
					AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					AND tl06 = 'R'  -- revolvente
					AND ( (SUBSTR(tl01,1,2) IN ('BA','BB','BC','BM','BY')) OR (tl02 IN ('BANCO','BANCOPPEL','BANCOS')) )    -- bandera banco
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
				);    -- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.
				
				IF (vSum_higcred IS NOT NULL) THEN
					IF (vSum_higcred <= 0) THEN
						LET UT0034 = -993;
					ELSE
						LET UT0034 = round((vSum_bal / vSum_higcred) * 100,0);
					END IF;
				END IF;

				SELECT NVL(Count(0),0) INTO ut0034_aux From (           -- Si tiene registros pero no tiene bandera de Cred Revolvente y Banco.
					SELECT Count(num_cliente) 
					FROM bdiburo:"informix".br_tl a WHERE num_cliente = cNumCteBco
					AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					AND tl06 != 'R'  -- revolvente
					AND ( (SUBSTR(tl01,1,2) NOT IN ('BA','BB','BC','BM','BY')) OR (tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS')) )          -- bandera banco
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23
				);  

				SELECT NVL(Count(0),0) INTO ut0034_aux2 From (      -- Si tiene registros pero limite de credito = 0
					SELECT Count(num_cliente) 
					FROM  bdiburo:"informix".br_tl a WHERE num_cliente = cNumCteBco
					AND TL30 NOT IN ('AD','CO','DR') -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					AND tl06 = 'R'  -- revolvente
					AND ( (SUBSTR(tl01,1,2) IN ('BA','BB','BC','BM','BY')) OR (tl02 IN ('BANCO','BANCOPPEL','BANCOS')))         
					AND TL23 = 0
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23);
			end if;

			IF NVL(UT0034,0) = 0 THEN
				LET UT0034 = -999;
			END IF;

			IF NVL(UT0034,0) = -999 AND ut0034_aux > 0 THEN           -- Si tiene registros pero no tiene bandera de Cred Revolvente y Banco.
				LET UT0034 = -998;
			END IF;

			IF NVL(UT0034,0) = -999 AND ut0034_aux2 > 0 THEN          -- Si tiene registros pero limite de credito = 0
				LET UT0034 = -993;
			END IF

			IF UT0034 IS NULL THEN
				LET UT0034 = 999999; 								  -- Valor "De lo contrario"
			END IF;
			

			-- VARIABLE HR0050 # de cuentas abiertas en los ultimos 6 meses o mas. Grupo 53
			LET HR0050 = -1;
			LET hr0050_aux = 0;

			IF SUBSTR(pNumSol,1,2) <> '78' THEN   
				SELECT NVL(Count(0),0) INTO HR0050 From (
						SELECT count(num_cliente) 
						FROM bdiburo:"informix".br_tl a
						WHERE num_cliente = cNumCteBco
						AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
						AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0    -- historico de pagos
						AND months_between (dtFechaHoy,tl13) >= 6 -- fecha apertura
						AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme
						AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
						GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23);
				-- TL13: Fecha Apertura, TL06: Tipo cuenta, TL23: Lim credito, TL07: TIPO CONTRATO, TL02 Memeber Name, TL01 Clave otorgante, TL04 No de Cta.

				-- Obtiene en caso de que cumpla con variables, pero historial de pagos sea mayor a cero.
				SELECT NVL(Count(0),0)
					INTO hr0050_aux2 
					FROM (SELECT count(num_cliente)
							FROM bdiburo:"informix".br_tl a WHERE num_cliente = cNumCteBco
							AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) > 0   -- historico de pagos
							AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0    -- historico de pagos
							AND months_between (dtFechaHoy,tl13) >= 6 -- fecha apertura
								AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23);

					-- Obtiene en caso de que tenga cuenta, pero que no cumplan con la condicion del tiempo.
				SELECT NVL(Count(0),0) INTO hr0050_aux From (
					SELECT count(num_cliente)
					FROM bdiburo:"informix".br_tl a WHERE num_cliente = cNumCteBco
					AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1',''),'0',''))) = 0   -- historico de pagos
					AND length(trim(replace(replace(replace(replace((case when tl26='' then 0 when tl26='UR' THEN 0 when tl26='00' THEN 0 else tl26::integer end)||tl27,'U',''),'X',''),'1','1'),'0',''))) > 0 
					AND months_between (dtFechaHoy,tl13) < 6 -- fecha apertura
					AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa
					AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
					GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23);
			end if;
			
			IF HR0050 = 0 AND hr0050_aux2 > 0 THEN	-- Hay transaciones pero ninguna es MOP = 1	
				LET HR0050 = 0;
			ELIF HR0050 = 0 AND hr0050_aux = 0 THEN	--	No hay cuentas
				LET HR0050 = -999;
			ELIF HR0050 = 0 AND hr0050_aux > 0 THEN -- Si tiene cuentas pero no cumplen condicion del tiempo > 6.
				LET HR0050 = -997;
			END IF;	
			----------------
			SELECT evalua_cc,ingreso_mensual
				INTO pSIC,  mIngreso_Mensual
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol;
			----------------  TR0001 
			LET TR0001 = -999;
			LET AUX_TR0001 = '';

			--- OBTIENE EL MES MAXIMO DE LA CUENTA ABIERTA MAS VIEJA
			SELECT ceil (NVL (MAX (months_between (dtFechaHoy,tl13)),''))
			INTO TR0001
			From (
				SELECT tl13
				FROM bdiburo:"informix".br_tl a
				WHERE num_cliente = cNumCteBco
				AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
				AND (tl30 != 'CC' OR tl06 not in ('I','M') and tl22 != 0)		-- ME TRD CLOSED FLAG
				AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
				GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
				);
			--- CONSULTA MESES DE LA CUENTA CERRADA Y SALDADA EXISTENTE
			IF NVL (TR0001,'') = '' THEN
				SELECT NVL (MAX (months_between (dtFechaHoy,tl13)),'')   
				INTO AUX_TR0001
					From (
						SELECT tl13
						FROM bdiburo:"informix".br_tl a
						WHERE num_cliente = cNumCteBco
						AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
						AND (tl30 = 'CC' OR tl06 in ('I','M') and tl22 = 0)		-- ME TRD CLOSED FLAG
						AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
						GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
						);
			END IF;

			IF NVL (TR0001,'') = '' AND NVL (AUX_TR0001,'') = '' THEN
				LET TR0001 = -999999;
			ELIF NVL (AUX_TR0001,'') != '' THEN
				LET TR0001 = -999996;
			END IF;
			---------------- Numero de cuentas BCSCORE
			--LET iCtas_SinComServ = 0;
			
			--FOREACH
				SELECT count (num_cliente) --Validar con cal_circulocredito
				INTO iCtas_SinComServ	-----sin comunicaciones ni servicios	iCtas_SinComServ
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
				AND num_cliente = cNumCteBco;
			--END FOREACH;
			
			IF iCtas_SinComServ IS NULL THEN
			LET iCtas_SinComServ = 0;
			END IF;
			
			--LET iCtas_SinComServ_pagar = 0;
			
			--FOREACH
				SELECT count (num_cliente)
				INTO iCtas_SinComServ_pagar--pagar iCtas_SinComServ_pagar
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
				AND a.tl12 <> 0
				AND num_cliente = cNumCteBco;
			--END FOREACH;
			
			IF iCtas_SinComServ_pagar IS NULL THEN
			LET iCtas_SinComServ_pagar = 0;
			END IF;
			
			--LET iNumCtas_SHBr_pagar = 0;
			
			--FOREACH
				SELECT count (num_cliente)
				INTO iNumCtas_SHBr_pagar
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl06 = 'M' AND a.tl07 = 'RE'
				AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
				AND num_cliente = cNumCteBco;
			--END FOREACH;	

			IF iNumCtas_SHBr_pagar IS NULL THEN
			LET iNumCtas_SHBr_pagar = 0;
			END IF;
			
			--LET iNumCtas_SHBr = 0; 
			--FOREACH
				SELECT count (num_cliente)
				INTO iNumCtas_SHBr
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl06 = 'M' AND a.tl07 = 'RE'
				AND a.tl02 = 'SERVICIOS'
				AND num_cliente = cNumCteBco;
			--END FOREACH;
			
			IF iNumCtas_SHBr IS NULL THEN
			LET iNumCtas_SHBr = 0;
			END IF;
			
			
			---------------- BC_1
			SELECT max(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
			INTO BC1
			FROM bdiburo:"informix".br_tl
			WHERE num_cliente = cNumCteBco;

			IF BC1 IS NULL THEN LET BC1 =-1; END IF;

			---------------- BC_101
			IF SUBSTR( pNumSol ,1,2) <> '78' THEN
				SELECT 	MAX(case when tl38 ='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
						MAX(case when tl26 ='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
				INTO pmaxmop,pmaxmop1
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco
				AND tl02 IN ('BANCO','BANCOS') AND tl06='I' AND tl07 NOT IN (select codigo
																					from bdiburo:br_tltco
																					where status_cons=1);

				IF pmaxmop IS NULL AND pmaxmop1 IS NULL THEN
						LET BC_101      = -1;
						LET pmaxmop     = 0;
						LET pmaxmop1    = 0;
						LET pcadenaaux  = "";
						LET maxmoptot   = 0;
				ELIF pmaxmop IS NULL THEN
						LET pmaxmop     = 0;
				ELIF pmaxmop1 IS NULL THEN
						LET pmaxmop1    = 0;
				END IF;

				IF pmaxmop > pmaxmop1 THEN
					LET maxmoptot = pmaxmop;
				ELSE
					LET maxmoptot = pmaxmop1;
				END IF;

				LET pmaxmop  =0;
				LET pmaxmop1 =0;

				FOREACH
					SELECT TRIM(tl27),LENGTH(tl27)
					INTO pcadenaaux,pmaxmop1
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl02 IN ('BANCO','BANCOS') AND tl06='I'
					AND tl07 NOT IN (select codigo from bdiburo:br_tltco where status_cons=1)
					
					LET i = 1;

					WHILE i <= pmaxmop1
						LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::integer END;
					-- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
						IF  pmaxmop > maxmoptot THEN
							let maxmoptot = pmaxmop;
						END IF;
						LET i = i + 1;
					END WHILE;
				END FOREACH;

				LET BC_101      = (case when BC_101 = 0 then maxmoptot else BC_101 end);
				LET pmaxmop     = 0;
				LET pmaxmop1    = 0;
				LET pcadenaaux  = "";
				LET maxmoptot   = 0;

					----------------BC_117
				FOREACH
					SELECT (case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
						(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
							TRIM(tl27),LENGTH(tl27)
						INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco
						AND tl02 IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
				
					LET Bandera = 1;

					IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)))
					OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3))) THEN
						LET ki = ki + 1;
					ELSE
						LET i = 1;
						WHILE i <= pmaxmop1
							LET pmaxmop = 	CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
							IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)) THEN
								LET ki = ki + 1;
								LET i = pmaxmop1;
							END IF;
							LET i = i + 1;
						END WHILE;
					END IF;
				END FOREACH;

				LET BC_117      = (case when ki=0 and Bandera=0 then -1 else ki end);
				LET ki          = 0;
				LET pmaxmop     = 0;
				LET pmaxmop1    = 0;
				LET pcadenaaux  = "";
				LET maxmoptot   = 0;
				LET Bandera     = 0;

				----------------BC_119
				FOREACH
					SELECT  (case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
							(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
							TRIM(tl27),LENGTH(tl27),(((year(fecha) - year(nvl(tl13,fecha)))*12)+ month(fecha) - month(nvl(tl13,fecha)))
					INTO pmaxmop,maxmoptot,pcadenaaux,pmaxmop1,pmeses
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')

					LET Bandera     = 1;

					IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,3)))
					OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,3))) THEN
						LET ki = ki + 1;
					ELSE
						LET i = 1;

						WHILE i <= pmaxmop1
							LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
							IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlphp where status_cons in (1,3)) THEN
								LET ki = ki + 1;
								LET i = pmaxmop1;
							END IF;
							LET i = i + 1;
						END WHILE;
					END IF;
					IF pmeses <= 12 THEN
						IF (pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3)))
						OR (maxmoptot IN (select codigo::INTEGER from bdiburo:br_tlmop where status_cons in (1,2,3))) THEN
							LET kiz = kiz + 1;
						ELSE
							LET i = 1;

							WHILE i <= pmaxmop1
								LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
								IF  pmaxmop IN (select codigo::INTEGER from bdiburo:br_tlphp where status_cons in (1,2,3)) THEN
									LET kiz = kiz + 1;
									LET i = pmaxmop1;
								END IF;
								LET i = i + 1;
							END WHILE;
						END IF;
					END IF;
				END FOREACH;

				LET BC_119      = (case when ki=0 and Bandera=0 then -1 else ki end);
				LET BC_20       = (case when kiz=0 and Bandera=0 then -1 else kiz end);
				LET ki          = 0;
				LET kiz         = 0;
				LET pmeses      = 0;
				LET pmaxmop     = 0;
				LET pmaxmop1    = 0;
				LET pcadenaaux  = "";
				LET maxmoptot   = 0;
				LET Bandera     = 0;

				---------------- BC_421
				SELECT max(iqiq)
					INTO dtFechaAux
					FROM bdiburo:"informix".br_iq
					WHERE num_cliente = cNumCteBco
					AND iq02 NOT IN ('BANCOPPEL');

				LET BC_421 = ((year(dtFechaHoy) - year(nvl(dtFechaAux,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(dtFechaAux,dtFechaHoy)));
				LET BC_421 = (case when BC_421=0 then -1 else BC_421 end);

				LET dtDiaFF = LPAD(DAY(dtFechaAux::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaAux::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaAux::DATE), 4, '0');

				LET dtFechaAux = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;
			
				---------------- BC_85
				LET maxmoptot       = -1;
				FOREACH
					SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
							MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
							TRIM(tl27),(((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy))))--LENGTH(tl27),
						INTO pmaxmop,pmaxmop1,pcadenaaux,pmeses
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco
						AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
						AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12
						GROUP BY 3,4

					IF maxmoptot > pmaxmop THEN
						LET pmaxmop=maxmoptot;
					END IF;

					IF pmaxmop > pmaxmop1 THEN
						LET maxmoptot = pmaxmop;
					ELSE
						LET maxmoptot=pmaxmop1;
					END IF;
					
					LET pmaxmop = 0;
					LET i = 1;

					WHILE i <= 12
						LET pmaxmop=CASE WHEN substr(pcadenaaux,i,1) IN (select codigo from bdiburo:"informix".br_tlphp where status_cons=-1) THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
					IF pmaxmop > maxmoptot THEN
						LET maxmoptot = pmaxmop;
					END IF;
						LET i = i + 1;
					END WHILE;
				END FOREACH;

				SELECT count(num_cliente)
					INTO Bandera
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R';

				LET BC_85       = (case when maxmoptot=-1 and Bandera>0 then 0 else maxmoptot end);
				LET pmeses      = 0;
				LET pmaxmop     = 0;
				LET pmaxmop1    = 0;
				LET pcadenaaux  = "";
				LET maxmoptot   = 0;

				----------------BC_93 
				SELECT	 MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end),
						MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
					INTO pmaxmop,pmaxmop1
					FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;

				IF	pmaxmop is null then 
					let pmaxmop = 0;
				END IF;

				IF pmaxmop1 is null then 
					let pmaxmop1 = 0; 
				END IF;

				IF pmaxmop > pmaxmop1 THEN
					LET maxmoptot = pmaxmop;
				ELSE
					LET maxmoptot = pmaxmop1;
				END IF;
				LET pmaxmop  =0;
				LET pmaxmop1 =0;

				FOREACH
					SELECT nvl(TRIM(tl27),''),nvl(LENGTH(tl27),0)
					INTO pcadenaaux,pmaxmop1
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco

					LET i = 1;

					WHILE i <= pmaxmop1
						LET pmaxmop = CASE WHEN substr(pcadenaaux,i,1) IN (select codigo
																			from bdiburo:"informix".br_tlphp
																			where status_cons = -1)
																	THEN -1 ELSE substr(pcadenaaux,i,1)::INTEGER END;
						IF  pmaxmop > maxmoptot THEN
							let maxmoptot = pmaxmop;
						END IF;
							LET i = i + 1;
					END WHILE;
				END FOREACH;
			end if; --validacion anticipo

			LET BC_93       = (case when maxmoptot = 0 then -1 else maxmoptot end);
			LET pmaxmop     = 0;
			LET pmaxmop1    = 0;
			LET pcadenaaux  = "";
			LET maxmoptot   = 0;

			---------------- TR0002
			LET TR0002 = -999;

			--- OBTIENE EL NUMERO PROMEDIO DE MESES
			SELECT NVL (ROUND (AVG (months_between (dtFechaHoy,tl13)),0),'')
			INTO TR0002
			From (
				SELECT tl13
				FROM bdiburo:"informix".br_tl a
				WHERE num_cliente = cNumCteBco
				AND tl30 NOT IN ('AD','CO','DR')  -- no en disputa, no en controversia, disputa resuelta pero inconforme - ME TRD DISPUTED FLAG
				AND (select substr(rs18,1,1) from bdiburo:"informix".br_rs where a.num_cliente = num_cliente and substr(rs18,1,1)  = 'N' group by 1 ) = 'N'-- no fallecido
				GROUP BY TL01, TL02, TL04, TL06, TL07, TL13, TL23 --- ME TRD DUPLICATE FLAG
				);
				
			IF NVL (TR0002,'') = '' THEN 
				LET TR0002 = -999999;
			END IF;	

			---------------- IQ0002	
			SELECT NVL (count(0),0)
				INTO IQ0002
				FROM (select skip 1 iqiq,iq02						--- INQ SEG TYPE CNT
						from bdiburo:"informix".br_iq 
						where num_cliente = cNumCteBco
						and institucion = 'BC'
						and months_between (dtFechaHoy,iqiq) <= 3	--- ME INQ AGE IN MONTHS
						group by 1,2								--- ME INQ VALID FLAG
						order by 1 desc); 	

			---------------- Maximo MOP de bancos 

			/*SELECT  MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
				INTO iMaxMOP_actBancos
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;

			SELECT  MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMaxMOP_histAltBancos
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;*/--VICTOR

			SELECT  MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
				    MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMaxMOP_actBancos,iMaxMOP_histAltBancos
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;
			
			LET var_i = 0;
			LET CantTl27 = 0;
			LET CadenaTl27 = '';
			LET contenedor = '';
			LET comparador = 0;

			FOREACH
				SELECT length(trim (tl27)), tl27
					INTO CantTl27 , CadenaTl27
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl02 NOT IN ('BANCO','BANCOPPEL','BANCOS') AND tl06 = 'R'
					AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12

				if nvl(CadenaTl27,'') = '' THEN
					continue foreach;
				end if;
				for var_i = 1 to CantTl27
					IF (SUBSTR(CadenaTl27,var_i,1) NOT IN ('U','X', 'D', '-', ' ', '0') ) THEN
						LET contenedor = SUBSTR(CadenaTl27,var_i,1);
						IF(contenedor::INTEGER > comparador) THEN
							LET comparador = contenedor;
						END IF;
					END IF;
				end for;

				LET iMaxMOP_histBancos = contenedor;

			END FOREACH;
			
			---------------- Maximo MOP de bancos 

			/*SELECT MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
				INTO iMaxMOP_actCtas
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;

			SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMaxMOP_histAltCtas
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;*/--VICTOR
			
			SELECT MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end),
			       MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO iMaxMOP_actCtas, iMaxMOP_histAltCtas
				FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;

			LET var_i = 0;
			LET CantTl27 = 0;
			LET CadenaTl27 = '';
			LET contenedor = '';
			LET comparador = 0;

			FOREACH
				SELECT length(trim (tl27)), tl27
					INTO CantTl27 , CadenaTl27
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco

				if nvl(CadenaTl27,'') = '' THEN
					continue foreach;
				end if;
				for var_i = 1 to CantTl27
					IF (SUBSTR(CadenaTl27,var_i,1) NOT IN ('U','X', 'D', '-', ' ', '0') ) THEN
						LET contenedor = SUBSTR(CadenaTl27,var_i,1);
						IF(contenedor::INTEGER > comparador) THEN
							LET comparador = contenedor;
						END IF;
					END IF;
				end for;
				LET iMaxMOP_histCtas = contenedor;
			END FOREACH;
			------------

			SELECT  MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end)
				INTO MaxComServMOP_tl38
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco;
			
			SELECT count (num_cliente)
				INTO iCtasComServMOP_tl38_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl38 = MaxComServMOP_tl38
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;			

			SELECT count (num_cliente)  
				INTO iCtasComServMOP_tl26_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl26 in ('2','3','4','5','6','7','96','97','99')
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL') --- Ver opcion de meterlas a catalogo BRM = 1
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;
			
			SELECT count (num_cliente)  
				INTO iCtasComServMOP_tl27_12m
				FROM bdiburo:"informix".br_tl
				WHERE num_cliente = cNumCteBco
				AND tl27 in ('2','3','4','5','6','7','96','97','99')
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL')
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12;

			SELECT count (num_cliente)  
				INTO iCtasCSM_ActHistAlto_12m
				FROM bdiburo:"informix".br_tl
				WHERE (tl27 in ('2','3','4','5','6','7','96','97','99')
						OR tl38 = MaxComServMOP_tl38)
				AND num_cliente = cNumCteBco
				AND (((year(dtFechaHoy) - year(nvl(tl17,dtFechaHoy)))*12) + (month(dtFechaHoy) - month(nvl(tl17,dtFechaHoy)))) <= 12
				AND tl26 in ('2','3','4','5','6','7','96','97','99') 
				AND tl02 NOT IN ('COMUNICACIONES','SERVICIOS','UTILIDAD','EDITORIAL');

				------------------------------------------------------ VARIABLES DE EVALUACION
			--se contempla validaciones para determinar el status de la solicitud de acuerdo a la OS telefonica y sus meses de historia del cliente		 
			SELECT resultado 
				INTO cNuevoStatusOstel
				FROM bdisolic:"informix".ss_ostel
				WHERE empresa = pEmpresa
				AND tp_solicitud = cTp_solicitud
				AND min_mes_hist <= sHist_meses
				AND max_mes_hist >= sHist_meses
				AND origen= cOrigenCte
				AND os_tel = cResultadoOsTel; 

			EXECUTE PROCEDURE bdisolic:"informix".sp_os_consultatipo3(pEmpresa, cNumCteBco,cProducto,2 ) 
				INTO  cCodRet, cRTipo3, cVigSolOS; 

			EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pNumSol, '') INTO cCodRet, dTasa, dTasa_Moratoria;
			
			--SE COMENTARIZA PARAMETROS PARA INCIDENCIA, ABRIL 2024
			IF cNum_Producto='6500' then
				LET dTasa = 10;
				LET dTasa_Moratoria = 15;	
			END IF;	

			
			LET dTasa_Ordinaria = dTasa;
			EXECUTE PROCEDURE bdisolic:"informix".cal_buen_pago(cNumCteBco,'0') INTO cCodRet, sBuenPagos;

			--Se agrega la consulta de sucursal y subcanal para validar que sea 8503 y verificar si viene por un subcanal
			SELECT canal_sol, sucursal
			INTO  iCanal_Sol, cSucursalSol
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE empresa = pEmpresa 
			AND num_solicitud = pNumSol;
			
			IF cSucursalSol = '8503' then
				SELECT NVL(sub_canal_sol,'')
				INTO  cSubCanal  
				FROM bdisolic:"informix".ss_prospecteo_solicitudes 
				WHERE empresa = pEmpresa 
				AND num_solicitud = pNumSol;
				
				IF cSubCanal <> '' then
					LET iCanal_Sol = cSubCanal;
				END IF;
				
			END IF;
			
			----------------------------------------------------- VARIABLES DE REINGENIERIA -----------------------------------------------------
			--IF cBRM_reing = '1' THEN --VVVF
				/*select valor into MV0  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV0';
				select valor into MV1  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV1';
				select valor into MV7  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV7';
				select valor into MV9  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV9';
				select valor into MV18 from bdiburo:"informix".br_cat_error_estand where codigo = 'MV18';
				select valor into MV21 from bdiburo:"informix".br_cat_error_estand where codigo = 'MV21';*/--VICTOR
				
				SELECT a.valor ,b.valor, c.valor,d.valor,e.valor,f.valor
				INTO MV0,MV1,MV7,MV9,MV18,MV21
				FROM bdiburo:"informix".br_cat_error_estand a
				LEFT JOIN bdiburo:"informix".br_cat_error_estand b ON b.codigo = 'MV1'
				LEFT JOIN bdiburo:"informix".br_cat_error_estand c ON c.codigo = 'MV7'
				LEFT JOIN bdiburo:"informix".br_cat_error_estand d ON d.codigo = 'MV9'
				LEFT JOIN bdiburo:"informix".br_cat_error_estand e ON e.codigo = 'MV18'
				LEFT JOIN bdiburo:"informix".br_cat_error_estand f ON f.codigo = 'MV21'
				WHERE a.codigo = 'MV0';

				--------------------------------------------------------
				-------- REINGENIERIA antes de estandarizar ------------
				--------------------------------------------------------        

				EXECUTE PROCEDURE bdiburo:"informix".sp_estandarizacion_cuentas_motor(pEmpresa, cNumCteBco)
				INTO cCodRetEstand, iCollectiontradelines, iTradelines; 
				IF cCodRetEstand <> '000000' THEN 
					LET cCodRet = cCodRetEstand;
					RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
					nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
					NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
					NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
					NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
					nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
					nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
					nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
					nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
					nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
					nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
					nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
					nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
					nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
					nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
					nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
					nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,0), Nvl(cInstCta_MayorMOP,''), 
					nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,0), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
					NVL(iMM_Histo_12m,0), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
					nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
					nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
					nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
					nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,0), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
					nvl(iNumCtas_ClvOb,0), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
					nvl(vClvExclusionMasReciente,'0'), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
					nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
					nvl(iMM_act_Bancos,0), nvl(iMM_hist_alto_Bancos,0), nvl(iMM_hist_Bancos,0), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
					nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
					nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
					nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
					nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,0),	NVL(iMaxMOP_actBancos,0), 
					NVL(iMaxMOP_histAltBancos,0), nvl(iMaxMOP_histBancos,0), nvl(BC_93,0), nvl(iMaxMOP_actCtas,0), nvl(iMaxMOP_histAltCtas,0),
					nvl(iMaxMOP_histCtas,0), nvl(dSituacionPagoCoppel,0), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
					nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
					nvl(sFlagHuella,0), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
					nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,0), 
					NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,0), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
					NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,0), nvl(iCanal_Sol,0), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,0), 
					nvl(iSecuenciaOs,0), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
					nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
					NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
					nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
					nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
					NVL(cEntidad,''), NVL(sCteLargo,0), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,0), NVL(dValor_3s,0),
					nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
					nvl(dCompromisos,0), nvl(sFlagBuenPago12,0), NVL(sFlagBuenPago30,0), NVL(sEntidad_Localidad,0), nvl(cNuevoStatusOstel,''), 
					nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,99), 
					nvl(HR0050,-1), nvl(TR0002,-999), nvl(TR0001,-999), nvl(IQ0002,0), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,0), 
					NVL(dSaldo_limit_credi,0), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
					nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
					nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,0), nvl(pctBankILTL,0), nvl(pctTL30pDaysEverColl,'0'), 
					nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,0), nvl(lowestRatingRevOpen,0),
					nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,-1), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,0), 
					nvl(numFinInq0to5Mos,0), nvl(maxDelqEver,99), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,0),
					nvl(num_sumasaldoscuentasabiertas,0), nvl(num_sumalineascuentasabiertas,0), nvl(pct_usocuentasabiertas,0),
					nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
					nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
					nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
					nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
					nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
					nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
					nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
					nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
					NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
					NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
					NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,'0');
				END IF;	
 
				
				------- 1 MonMeses reportados en la fecha morosa mas grave mas reciente hit sin experiencia
				--LET montoTl36 = 0;
				--LET dtFechatl37 = DATE(1);
				LET num_mesespeoratrasohistoricomasreciente = 0;
				
				--FOREACH
					--SELECT LIMIT 1 NVL(tl36,0),NVL(tl37,date(1))
					/*SELECT NVL(tl36,0),NVL(tl37,date(1))
						INTO montoTl36, dtFechatl37
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco and tl37 = (SELECT MAX(NVL(tl37,date(1))) FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco);*/
						--ORDER BY tl37 DESC
				--END FOREACH;

				--LET mTl38 = 0 ;
				--LET mTl36 = 0;
				--LET dtTl37 = DATE(1);
				LET num_montofechamorosamasgravemasreciente = 0;
				
				/*IF dtFechatl37 = '' or dtFechatl37 is null THEN
				LET dtFechatl37 = DATE(1);
				END IF;
				
				IF montoTl36 = '' or montoTl36 is null THEN
				LET montoTl36 = 0;
				END IF;*/
				--SELECT MAX(NVL(tl37,date(1))) INTO dtFechatl37Prueba
				--FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco;
				FOREACH
					--SELECT LIMIT 1 (CASE WHEN tl38='' THEN 0 WHEN tl38='UR' THEN 0 else tl38::integer END),  nvl(tl36,DATE(1)), nvl(tl37,DATE(1))
					SELECT LIMIT 1 (CASE WHEN tl38='' THEN 0 WHEN tl38='UR' THEN 0 else tl38::integer END),nvl(tl36,DATE(1)), nvl(tl37,DATE(1)), NVL(tl36,0),NVL(tl37,date(1))
					INTO mTl38, mTl36, dtTl37, montoTl36, dtFechatl37
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco --and tl37 = dtFechatl37Prueba;
						--and tl37 = (SELECT MAX(NVL(tl37,date(1))) FROM bdiburo:"informix".br_tl WHERE num_cliente = cNumCteBco)
						ORDER BY tl37 DESC
						
				END FOREACH;
				
				IF dtFechatl37 = '' or dtFechatl37 is null THEN
				LET dtFechatl37 = DATE(1);
				END IF;
				
				IF montoTl36 = '' or montoTl36 is null THEN
				LET montoTl36 = 0;
				END IF;
				
				IF mTl38 = '' or mTl38 is null THEN
				LET mTl38 = 0;
				END IF;
				
				IF mTl36 = '' or mTl36 is null THEN
				LET mTl36 = 0;
				END IF;
				
				IF dtTl37 = '' or dtTl37 is null THEN
				LET dtTl37 = DATE(1);
				END IF;		

				LET dtDiaFF = LPAD(DAY(dtFechatl37::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechatl37::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechatl37::DATE), 4, '0');

				LET dtFechatl37 = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

				LET dtDiaFF = LPAD(DAY(dtTl37::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtTl37::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtTl37::DATE), 4, '0');

				LET dtTl37 = dtDiaFF || '/' || dtMesFF || '/' || dtAnoFF;

			IF (mTl38 > mTl36) THEN
					LET num_montofechamorosamasgravemasreciente = montoTl36;
					LET num_mesespeoratrasohistoricomasreciente = TRUNC (MONTHS_BETWEEN(to_date(dtFechaSolicitud,'%d/%m/%Y'), to_date(dtFechatl37,'%d/%m/%Y')));

				ELSE
					LET num_montofechamorosamasgravemasreciente = mTl36;
					LET num_mesespeoratrasohistoricomasreciente = TRUNC (MONTHS_BETWEEN(to_date(dtFechaSolicitud,'%d/%m/%Y'), to_date(dtTl37,'%d/%m/%Y')));
				END IF;        

				IF num_mesespeoratrasohistoricomasreciente > 1200 THEN
				LET num_mesespeoratrasohistoricomasreciente  = -1;
				END IF;

			
				------- 2 Numero de consultas en los Ultimos 2 meses
				--LET numInq0to2Mos = 0;
				
				--FOREACH
					SELECT count(a.num_cliente)
					INTO numInq0to2Mos
					FROM bdiburo:"informix".br_iq a
					INNER JOIN bdisolic:"informix".ss_solicitudes b ON a.num_cliente = b.numcte
					WHERE ( 	( ( month(b.fecha_insert)- month(a.iqiq) ) ) <= 2
							AND ( ( month(b.fecha_insert)- month(a.iqiq) ) ) > 0
						)
					AND a.num_cliente = cNumCteBco;
				--END FOREACH;
				
				IF numInq0to2Mos IS NULL THEN
				LET numInq0to2Mos = 0;
				END IF;

				------- 3 Suma de saldos de cuentas abiertas
				LET num_sumasaldoscuentasabiertas = 0;
				LET pct_usocuentasabiertas        = 0;
				LET num_sumalineascuentasabiertas = 0;
				LET iMesesFechaCierre = 0;
				LET iSaldoActualEstan = 0;
				
				FOREACH            
					SELECT mesesfechacierre_std,saldoactualestan_std
						INTO iMesesFechaCierre, iSaldoActualEstan
						FROM bdiburo:"informix".br_tl_estand
						WHERE numcte_std = cNumCteBco


					IF iMesesFechaCierre  IN (MV1,MV7) AND iSaldoActualEstan NOT IN (MV9,MV21, MV18) THEN
						LET num_sumasaldoscuentasabiertas = num_sumasaldoscuentasabiertas + iSaldoActualEstan;
					END IF;
				
				END FOREACH;
				------- 4 Suma de lineas de credito de cuentas abiertas
				LET num_sumalineascuentasabiertas = 0;
				LET iMesesFechaCierre = 0;
				LET iMontoCredito = 0;

				FOREACH
					SELECT mesesfechacierre_std, montocredito_std
						INTO iMesesFechaCierre, iMontoCredito
						FROM bdiburo:"informix".br_tl_estand
						WHERE numcte_std = cNumCteBco
						AND mesesfechacierre_std IS NOT NULL


					IF iMesesFechaCierre  IN (MV1,MV7) AND iMontoCredito NOT IN ( MV1,MV18, MV21, MV9) THEN
						LET num_sumalineascuentasabiertas = num_sumalineascuentasabiertas + iMontoCredito;
					END IF;

				
				END FOREACH;
				------- 5 Porcentaje de uso de lineas de cuentas abiertas
				IF num_sumalineascuentasabiertas = 0 THEN
					LET pct_usocuentasabiertas = -1;
				ELSE
					LET pct_usocuentasabiertas = ROUND ((num_sumasaldoscuentasabiertas * 100) / num_sumalineascuentasabiertas);
				END IF;

				------- 6 Numero de periodos totales reportados en buro   
				LET CantTl27 = 0;
				LET CadenaTl27 = '';
				LET num_totalperiodosreportados = 0;

				FOREACH
					SELECT LENGTH(trim (tl27))
						INTO CantTl27
						FROM bdiburo:"informix".br_tl 
						WHERE num_cliente = cNumCteBco

					LET     num_totalperiodosreportados = num_totalperiodosreportados + CantTl27;
				END FOREACH;
			
				------- 7 Porcentaje de periodos al corriente promedio 
				LET var_i = 0;
				LET num_periodos_corriente_cuenta = 0;
				LET CantTl27 = 0;
				LET CadenaTl27 = '';
				LET num_periodos_cuenta = 0;
				LET numero_cuentas = 0;
				LET porc_corriente_cuenta = 0;
				LET suma_porcentajes_corriente = 0;
				LET num_porcentajecorrientepromedio = 0;

				FOREACH
					SELECT LENGTH(trim (tl27)), tl27
						INTO CantTl27 , CadenaTl27
						FROM bdiburo:"informix".br_tl 
						WHERE num_cliente = cNumCteBco

					IF nvl(CadenaTl27,'') = '' THEN
						continue foreach;
					END IF;

					LET num_periodos_corriente_cuenta = 0;
					LET num_periodos_cuenta = 0;
					
					FOR var_i = 1 to CantTl27 
						IF (SUBSTR(CadenaTl27,var_i,1) NOT IN ('U','X', 'D', '-', '0', '3', '5', '6', '7', '8', '9') ) THEN
							LET num_periodos_cuenta = num_periodos_cuenta + 1;
							IF (SUBSTR(CadenaTl27,var_i,1) = 1) THEN 
								LET num_periodos_corriente_cuenta = num_periodos_corriente_cuenta + 1;
							END IF;
						END IF;
					END FOR;

					IF num_periodos_cuenta > 0 THEN
						LET numero_cuentas = numero_cuentas + 1;
						LET porc_corriente_cuenta = TRUNC((num_periodos_corriente_cuenta*100) / (num_periodos_cuenta));
						LET  suma_porcentajes_corriente = suma_porcentajes_corriente + porc_corriente_cuenta;
					END IF;
				END FOREACH;

				IF numero_cuentas = 0 THEN
					LET num_porcentajecorrientepromedio = -1;
				ELSE 
					LET num_porcentajecorrientepromedio = TRUNC((suma_porcentajes_corriente / numero_cuentas ));
				END IF;

				-------8 Numero de cuentas reportadas por tipo de usuario: Tienda Comercial cambios 120523
			
				--LET num_arrendamiento = 0;
				--LET cnum_clientetl_arrendamiento		= '';

				--FOREACH
					SELECT LIMIT 1 num_cliente
						INTO cnum_clientetl_arrendamiento
						FROM bdiburo:"informix".br_tl
						where num_cliente = cNumCteBco;
						--and tl07 = 'LS' --Cambio 29052023
				--END FOREACH;
				
				IF cnum_clientetl_arrendamiento IS NULL THEN
				LET cnum_clientetl_arrendamiento = '';
				END IF;

				IF NVL(cnum_clientetl_arrendamiento,'') = '' THEN
					LET num_arrendamiento = -1;
				ELSE
					--FOREACH	
						SELECT count (num_cliente)
							INTO num_arrendamiento
							FROM bdiburo:"informix".br_tl
							where tl07 = 'LS'
							and num_cliente = cNumCteBco;
					--END FOREACH;
					
					IF num_arrendamiento IS NULL THEN
				    LET num_arrendamiento = 0;
				    END IF;
				END IF;

				
				
				-------9 Numero de cuentas reportadas por tipo de usuario: Tienda Comercial
				--LET num_tiendacomercial = 0;

				--FOREACH
					SELECT count (num_cliente)
						INTO num_tiendacomercial
						FROM bdiburo:"informix".br_tl
						where tl02 = 'TIENDA COMERCIAL'
						and num_cliente = cNumCteBco;
				--END FOREACH;
				
				IF num_tiendacomercial IS NULL THEN
				 LET num_tiendacomercial = 0;
				END IF;

				-------10 Numero de direcciones reportadas en las sociedades informacion crediticia
				--LET num_direcciones = 0;

				--FOREACH
					SELECT	count (num_cliente)
						INTO num_direcciones
						FROM bdiburo:"informix".br_pa
						WHERE num_cliente =  cNumCteBco;
				--END FOREACH; 

				IF num_tiendacomercial IS NULL THEN
				 LET num_direcciones = 0;
				END IF;
				
				-------- 11 Numero de consultas por tipo de negocio Financiera  cambios 120523
				--LET num_consultasfinanciera = 0; 
				--LET cnumcte_stdiq_consultasfinanciera	= '';

				--FOREACH
					SELECT LIMIT 1 numcte_stdiq
						INTO cnumcte_stdiq_consultasfinanciera
						FROM bdiburo:"informix".br_iq_estand
						WHERE empresa_stdiq = pEmpresa
						AND numcte_stdiq = cNumCteBco;
						--AND iq02_std IN ('FF') --Cambio 29052023
				--END FOREACH;

				IF cnumcte_stdiq_consultasfinanciera IS NULL THEN
				 LET cnumcte_stdiq_consultasfinanciera ='';
				END IF;
				
				IF NVL(cnumcte_stdiq_consultasfinanciera,'') = '' THEN
					LET num_consultasfinanciera = -1;
				ELSE
					--FOREACH
						SELECT COUNT (numcte_stdiq)
							INTO num_consultasfinanciera
							FROM bdiburo:"informix".br_iq_estand
							WHERE empresa_stdiq = pEmpresa
							AND numcte_stdiq = cNumCteBco
							AND iq02_std IN ('FF');
					--END FOREACH;
				END IF;

				IF num_consultasfinanciera IS NULL THEN
				 LET num_consultasfinanciera =0;
				END IF;
				
				----------12 Maximo plazo en dias de cuentas en buro 
				LET cTl11 = '';
				LET iTl10 = 0;
				LET dtfechaApertura = '01/01/1900';
				LET tipoProducto = '';
				LET Saldotl22 = 0;
				LET i_plazo = 0;
				LET max_plazo = -1;
				LET producto_max_plazo = '';
				LET fecha_apertura_max = 1900-01-01;
				LET saldo_max = 0;
				LET num_maxplazodias = -1;
				LET clv_tipoproductocrediticio = '';

				FOREACH
						SELECT	tl11, tl10, tl13, tl22, tl07
							INTO cTl11, iTl10, dtfechaApertura, Saldotl22, tipoProducto
							FROM bdiburo:"informix".br_tl 
							WHERE num_cliente = cNumCteBco
							ORDER BY tl07 

						IF cTl11 = 'H' THEN
							IF(iTl10 IS NULL) THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 180 * iTl10;
							END IF;
						ELIF cTl11 = 'K' THEN
							IF(iTl10 IS NULL) THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 14 * iTl10;
							END IF;
						ELIF cTl11 = 'M' THEN 
							IF iTl10 IS NULL THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 30 * iTl10;
							END IF;
						ELIF cTl11 = 'Q' THEN
							IF iTl10 IS NULL THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 90 * iTl10;
							END IF;
						ELIF cTl11 = 'S' THEN
							IF iTl10 IS NULL THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 15 * iTl10;
							END IF;
						ELIF cTl11 = 'W'  THEN
							IF iTl10 IS NULL THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 7 * iTl10;
							END IF;
						ELIF cTl11 = 'Y' THEN
							IF iTl10 IS NULL THEN
								LET i_plazo = -1;
							ELSE
								LET i_plazo = 365 * iTl10;
							END IF;
						ELSE 
							LET i_plazo = 0;
						END IF;

					IF i_plazo = -1 THEN
						LET max_plazo = -1;
					ELSE
						IF i_plazo > max_plazo THEN
							LET max_plazo = i_plazo;
							LET producto_max_plazo = tipoProducto;
							LET fecha_apertura_max = dtfechaApertura;
							LET saldo_max = Saldotl22;

						ELIF i_plazo = max_plazo THEN
							IF dtfechaApertura > fecha_apertura_max THEN
								LET max_plazo = i_plazo;
								LET producto_max_plazo = tipoProducto;
								LET fecha_apertura_max = dtfechaApertura;
								LET saldo_max = Saldotl22;
							ELIF dtfechaApertura > fecha_apertura_max THEN
								IF Saldotl22 > saldo_max THEN
									LET max_plazo = i_plazo;
									LET producto_max_plazo = tipoProducto;
									LET fecha_apertura_max = dtfechaApertura;
									LET saldo_max = Saldotl22;
								ELIF Saldotl22 > saldo_max THEN
									IF tipoProducto = num_maxplazodias THEN
										LET max_plazo = i_plazo;
										LET producto_max_plazo = tipoProducto;
										LET fecha_apertura_max = dtfechaApertura;
										LET saldo_max = Saldotl22;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END FOREACH;

				LET num_maxplazodias = max_plazo;
				LET clv_tipoproductocrediticio = producto_max_plazo;

				-----14 Suma de saldos de cuentas revolventes sin telecomunicaciones
				LET num_sumasaldoscuentasrevolventessintelcos = 0;       
				LET pct_usocuentasrevolventessintelcos = 0;

				SELECT SUM (nvl(tl22,0))
					INTO num_sumasaldoscuentasrevolventessintelcos
					FROM bdiburo:"informix".br_tl
					WHERE num_cliente = cNumCteBco
					AND tl06 in ('R')
					AND tl02 not in ('COMUNICACIONES','COMUNICA','COMUNI','SERVICIO MEDICO','SERVICIOS','SERV.GRALES.');

				-----15 Suma de lineas de credito de cuentas revolventes sin telecomunicaciones
				LET num_sumalineascuentasrevolventessintelcos = 0;

				select sum (nvl(tl23,0))
					INTO num_sumalineascuentasrevolventessintelcos
					FROM bdiburo:"informix".br_tl
					where num_cliente = cNumCteBco
					and tl06 in ('R', 'O')
					and tl02 not in ('COMUNICACIONES','COMUNICA','COMUNI','SERVICIO MEDICO','SERVICIOS','SERV. GRALES.');
					
				IF num_sumalineascuentasrevolventessintelcos = 0 THEN
					LET pct_usocuentasrevolventessintelcos = -1;
				ELSE 
					LET pct_usocuentasrevolventessintelcos = TRUNC ((num_sumasaldoscuentasrevolventessintelcos * 100) / num_sumalineascuentasrevolventessintelcos);
				END IF;

			
				-----16 Numero de consultas de SIC cambios 120523
				--LET num_consultassic = 0;
				--LET cnumcte_stdiq_consultassic = '';

				--FOREACH
					SELECT LIMIT 1 num_cliente
						INTO cnumcte_stdiq_consultassic
						FROM bdiburo:"informix".br_iq
						WHERE num_cliente = cNumCteBco;
						-- AND iq02 IN ('SIC') --Cambio 29052023 
				--END FOREACH;

				IF cnumcte_stdiq_consultassic IS NULL THEN
				LET cnumcte_stdiq_consultassic = '';
				END IF;
				
				IF NVL(cnumcte_stdiq_consultassic,'') = '' THEN
					LET num_consultassic = -1;
				ELSE
					--FOREACH
						SELECT count (num_cliente)
							INTO num_consultassic
							FROM bdiburo:"informix".br_iq
							WHERE num_cliente = cNumCteBco
							AND iq02 IN ('SIC');
					--END FOREACH;
				END IF;
				
				IF num_consultassic IS NULL THEN
				LET num_consultassic = 0;
				END IF;


				---------------------17 Numero de tarjetas de credito 
				--FOREACH
					SELECT count (num_cliente)
						INTO num_tarjetacredito
						FROM bdiburo:"informix".br_tl 
						WHERE num_cliente = cNumCteBco
						AND tl07 = 'CC';
				--END FOREACH;

				IF num_tarjetacredito IS NULL THEN 
				LET num_tarjetacredito = 0;
				END IF;
				
				----------------------------------------------------------
				-------- REINGENIERIA despues de estandarizar ------------
				----------------------------------------------------------
			
				
				-------------18 mosSncOldestRevTLOpnd
				--LET iMesesfechaapertura_std_rev = 0;

				--FOREACH
					SELECT limit 1 mesesfechaapertura_std
						INTO iMesesfechaapertura_std_rev
						FROM bdiburo:"informix".br_tl_estand
						WHERE empresa_std = pEmpresa
						AND bandera_collection = 'F'
						AND numcte_std = cNumCteBco
						AND bandera_rev = 'T';
						--ORDER by mesesfechaapertura_std ASC
				--END FOREACH;

				IF iMesesfechaapertura_std_rev IS NULL THEN 
				LET iMesesfechaapertura_std_rev = 0;
				END IF;
				
				LET cFlagLineaComercioRevolvente = '';
				LET iMesesfechaapertura_std      = 0;
				LET iCuentasrevolventes          = 0;
				LET iCuentasrevolventesvalidas   = 0;
				LET  mosSncOldestRevTLOpnd = iMesesfechaapertura_std_rev;

				FOREACH
					SELECT bandera_rev, mesesfechaapertura_std
						INTO cFlagLineaComercioRevolvente, iMesesfechaapertura_std
						FROM bdiburo:"informix".br_tl_estand
						WHERE empresa_std = pEmpresa
						AND bandera_collection = 'F'
						AND numcte_std = cNumCteBco

					IF cFlagLineaComercioRevolvente = 'T' THEN
						LET iCuentasrevolventes = iCuentasrevolventes + 1;
						IF iMesesfechaapertura_std <> MV7 AND iMesesfechaapertura_std <> MV1 THEN
							LET iCuentasrevolventesvalidas = iCuentasrevolventesvalidas + 1;
							IF iMesesfechaapertura_std > iMesesfechaapertura_std_rev THEN
								LET mosSncOldestRevTLOpnd = iMesesfechaapertura_std;
								LET iMesesfechaapertura_std_rev = iMesesfechaapertura_std;
							END IF;
						END IF;
					END IF;
				END FOREACH;

				IF iCuentasrevolventes = 0 THEN
					LET mosSncOldestRevTLOpnd = MV0;
				ELIF iCuentasrevolventesvalidas = 0 THEN
					LET mosSncOldestRevTLOpnd =	MV1;
				END IF;
			
			
				-------19 Peor Mop Actual
				LET clv_worstcurrentmop = -2;

				SELECT
				MAX(CASE
				WHEN tl26_std = '00' THEN 0
				WHEN tl26_std = '0'  THEN 0
				WHEN tl26_std = '01' THEN 1
				WHEN tl26_std = '1'  THEN 1
				WHEN tl26_std = '02' THEN 2
				WHEN tl26_std = '2'  THEN 2
				WHEN tl26_std = '03' THEN 3
				WHEN tl26_std = '3'  THEN 3
				WHEN tl26_std = '04' THEN 4
				WHEN tl26_std = '4'  THEN 4
				WHEN tl26_std = '05' THEN 5
				WHEN tl26_std = '5'  THEN 5
				WHEN tl26_std = '06' THEN 6
				WHEN tl26_std = '6'  THEN 6
				WHEN tl26_std = '07' THEN 7
				WHEN tl26_std = '7'  THEN 7
				WHEN tl26_std = '96' THEN 8
				WHEN tl26_std = '97' THEN 8
				WHEN tl26_std = '99' THEN 9
				WHEN tl26_std = 'UR' THEN -1
				END)
				INTO clv_worstcurrentmop
				FROM bdiburo:"informix".br_tl_estand
				WHERE numcte_std = cNumCteBco;

				IF NVL(clv_worstcurrentmop,'') = '' THEN
					LET clv_worstcurrentmop = -2;
				END IF;

			-------------------------------- 20 num_lineacreditopromedio
				LET num_sumalineascredito = 0;
				LET num_cuentasvalidas = 0;
				LET num_lineacreditopromedio = -2;
				LET dLimiteCredito = -1;

				FOREACH
					SELECT tl23
						INTO dLimiteCredito
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco

					IF  dLimiteCredito <> -1 THEN
						let num_cuentasvalidas = num_cuentasvalidas + 1;
						let num_sumalineascredito = num_sumalineascredito + dLimiteCredito;
					END IF;
				
				END FOREACH;
				IF  num_cuentasvalidas = 0 THEN
					LET num_lineacreditopromedio = -1;
				ELSE
					LET num_lineacreditopromedio = TRUNC(num_sumalineascredito/num_cuentasvalidas);
				END IF;
					
				---------- 21 num_montopeoratrasohistoricomasreciente hit con experiencia
				LET dtFechaHistMorGrave_std     = DATE(1);
				LET iSaldomoromasgraveestan_std = 0;
				LET dtFecha_Consulta            = DATE(1);
				LET num_montopeoratrasohistoricomasreciente = -1;
				LET monto_atraso_mas_grave = 0;
				LET fecha_atraso_mas_grave = '01/01/1900';
		
			FOREACH 	 
					SELECT nvl(tl37_stand,'01/01/1900'), nvl(saldomoromasgraveestan_std, 0)
						INTO dtFechaHistMorGrave_std, iSaldomoromasgraveestan_std
						FROM bdiburo:"informix".br_tl_estand
						WHERE numcte_std = cNumCteBco
								
					IF dtFechaHistMorGrave_std > fecha_atraso_mas_grave THEN
						LET fecha_atraso_mas_grave = dtFechaHistMorGrave_std;
						LET monto_atraso_mas_grave = iSaldomoromasgraveestan_std;

					ELIF  dtFechaHistMorGrave_std = fecha_atraso_mas_grave  THEN
					
						IF iSaldomoromasgraveestan_std > monto_atraso_mas_grave  THEN
							LET fecha_atraso_mas_grave = dtFechaHistMorGrave_std;
							LET monto_atraso_mas_grave = iSaldomoromasgraveestan_std;

						END IF;
					END IF;
				END FOREACH;

				LET num_montopeoratrasohistoricomasreciente = monto_atraso_mas_grave;

				----------------------22 num_cuentas
				--LET num_cuentas = 0;
				--FOREACH
					SELECT count (num_cliente)
						INTO num_cuentas
						FROM bdiburo:"informix".br_tl
						WHERE num_cliente = cNumCteBco
						AND tl07 NOT IN ('FT') 
						AND tl30 NOT IN ('CL', 'PC')
						AND tl02 NOT IN ('COMPANIA DE PRES','COMPANIA DEPRES0','COMPANIADE PRES0','FACORAJE','FACTORAJE','COBRANZA','COORDINADORA REC');
				--END FOREACH;
				
				IF num_cuentas IS NULL THEN
				LET num_cuentas = 0;
				END IF;
				
				----------------------23 num_consultas90dias cambios 120523
				LET iMesesFechaConsulIq = 0;
				LET num_consultas90dias = 0;
				--LET cnumcte_stdiq_MesesFechaConsulIq	= '';


				--FOREACH
					SELECT LIMIT 1 numcte_stdiq
						INTO cnumcte_stdiq_MesesFechaConsulIq
						FROM bdiburo:"informix".br_iq_estand
						WHERE numcte_stdiq = cNumCteBco ;
				--END FOREACH;
				
				IF cnumcte_stdiq_MesesFechaConsulIq IS NULL THEN
				LET cnumcte_stdiq_MesesFechaConsulIq = '';
				END IF;

				IF NVL(cnumcte_stdiq_MesesFechaConsulIq,'') = '' THEN
					LET num_consultas90dias = -1;
				ELSE
					FOREACH
						SELECT mesesfechaconsultaiq
						INTO iMesesFechaConsulIq
						FROM bdiburo:"informix".br_iq_estand
						WHERE numcte_stdiq = cNumCteBco

						IF iMesesFechaConsulIq NOT IN(MV7,MV1) THEN
							IF iMesesFechaConsulIq <= 91 THEN
								LET num_consultas90dias = num_consultas90dias + 1;
							END IF;
						END IF;
					END FOREACH;
				END IF;


				-----------------------------24 num_antiguedadpromediocuentas12meses
				LET num_antiguedadpromediocuentas12meses = 0;
				LET iLineasValidas = 0;
				LET iLineasReport12m = 0;
				LET iTotalMesesFila = 0;
				LET iLineasConMesesFila = 0;


				FOREACH
					SELECT mesesfechareporte_std, mesesfechaapertura_std
					INTO iMesesFechaReporte_std, iMesesfechaapertura_std
					FROM bdiburo:"informix".br_tl_estand
					WHERE numcte_std = cNumCteBco
					and bandera_collection = 'F'
						
					LET iLineasValidas = iLineasValidas + 1;
					IF iMesesFechaReporte_std NOT IN (MV7, MV1) THEN
						IF iMesesFechaReporte_std <= 11 THEN
							LET iLineasReport12m = iLineasReport12m + 1;
							IF iMesesfechaapertura_std NOT IN (MV7,MV1) THEN
								LET iLineasConMesesFila = iLineasConMesesFila + 1;
								LET iTotalMesesFila = iTotalMesesFila + iMesesfechaapertura_std;
							END IF;
						END IF;
					END IF;
				END FOREACH;

				IF iLineasReport12m = 0 THEN 
					LET num_antiguedadpromediocuentas12meses = -1;
				ELIF iLineasConMesesFila = 0 THEN
					LET num_antiguedadpromediocuentas12meses = -2;
				ELIF iLineasValidas = 0 THEN
					LET num_antiguedadpromediocuentas12meses = -3;
				ELSE 
					LET num_antiguedadpromediocuentas12meses = round (iTotalMesesFila / iLineasConMesesFila); 
				END IF;

				-----------------------------25 highestUtilOnBankNatlRevTL

				LET iLineasRevolventes = 0;
				LET iLineasRevAbiertas = 0;
				LET iLineasRevValidas = 0;
				LET highestUtilOnBankNatlRevTL = -999;
				LET iSaldoActualEstan = 0;
				LET iMesesFechaCierre = 0;
				LET iMontoCredito = 0;
				LET cTipoCuenta ='';
				LET cTipoNegocio = '';
				LET cTipoContrato ='';

				FOREACH
					SELECT saldoactualestan_std, montocredito_std, tipocuenta_std, tl30_std, tipocontrato_std, tl02_std, mesesfechareporte_std, mesesfechacierre_std
						INTO iSaldoActualEstan, iMontoCredito, cTipoCuenta, cTl30_std, cTipoContrato, cTipoNegocio, iMesesFechaReporte_std, iMesesFechaCierre
						FROM bdiburo:"informix".br_tl_estand
						WHERE numcte_std = cNumCteBco

					LET FracNetaRev = 0;
					--do process CHECK FOR BANK/NATL TRADE LINE
					LET cFlagbanknatl = 'F';
					IF cTipoNegocio IN ('BA', 'BB', 'BC', 'BH', 'BM', 'BY', 'NN') THEN
						LET cFlagbanknatl = 'T';
					END IF;
					
					--do process CHECK FOR REVOLVING TRADE LINE
					LET cBanderaRev = 'F';
					IF cTipoCuenta = 'R' AND cTipoContrato IN ('CC', 'CL', 'SC', 'TE') AND cTipoNegocio NOT IN ('UT','UU') THEN
						LET cBanderaRev = 'T';
					END IF;

					IF cFlagbanknatl = 'T' THEN

						LET iLineasRevolventes = iLineasRevolventes + 1;
						--do process CHECK FOR DISPUTE TRADE LINE
						LET cFlagDisputa = 'F';
						IF cTl30_std IN ('AD', 'CO' , 'SG') THEN
							LET cFlagDisputa = 'T';
						END IF;
						--do process CHECK FOR OPEN TRADE LINE
						LET cBanderaCuentaAbierta = 'F';
							--do process CHECK FOR INSTALLMENT TRADE LINE
						LET cFlagInstallment = 'F';
						IF cTipoCuenta IN ('I', 'M') THEN 
							LET cFlagInstallment = 'T';
						END IF;

						IF iMesesFechaReporte_std NOT IN ( MV7,MV1) THEN
							IF iMesesFechaReporte_std <= 11 THEN

								IF iSaldoActualEstan NOT IN (MV18,MV21) THEN
									IF iSaldoActualEstan  > 0 THEN
										LET cBanderaCuentaAbierta = 'T';
									END IF;
								ELIF cFlaginstallment = 'T' AND iSaldoActualEstan = 0 THEN
									LET cBanderaCuentaAbierta = 'F';
								ELIF cTl30_std NOT IN ('CA', 'CC', 'CL', 'CV', 'FD', 'FN', 'LS', 'NA', 'NV', 'PC', 'RF', 'RI', 'UP', 'VR') AND iMesesFechaCierre IN (MV7,MV1) THEN
									LET cBanderaCuentaAbierta = 'T'; 
								END IF;
							END IF;
						END IF;

						IF cFlagDisputa = 'F' AND cBanderaCuentaAbierta = 'T' THEN
							LET iLineasRevAbiertas = iLineasRevAbiertas + 1;
							--SUBPROCESO: CHECK FOR UNUSUAL TRADE LINE
							LET cFlagUnusualTradeLine = 'F';
							--SUBPROCESO: CHECK FOR MORTGAGE TRADE LINE
							LET cFlagMortgageTradeLine = 'F';
							IF cTipoCuenta = 'M' OR to_char(iMontoCredito) = 'RE' OR cTipoNegocio IN ('BM', 'HG', 'QM', 'RR') THEN
								LET cFlagMortgageTradeLine = 'T';
							END IF;
							IF cFlagMortgageTradeLine = 'T' THEN
								LET cFlagUnusualTradeLine = 'T';
							END IF;

							IF cFlagUnusualTradeLine = 'F' AND iMontoCredito NOT IN (MV18,MV1,MV18) AND iSaldoActualEstan NOT IN (MV21,MV9) THEN
								IF iMontoCredito > 0 THEN
									LET iLineasRevValidas = iLineasRevValidas + 1;
									LET FracNetaRev = (iSaldoActualEstan * 100) / iMontoCredito;

									IF FracNetaRev between 0 and 1 THEN
										LET FracNetaRev = 1;
									END IF;

									IF FracNetaRev > highestUtilOnBankNatlRevTL THEN
										LET highestUtilOnBankNatlRevTL= FracNetaRev; 
									END IF;

								END IF;
							END IF;
						END IF;
					END IF;
				END FOREACH;

				IF iLineasRevolventes = 0 THEN 
					LET highestUtilOnBankNatlRevTL = MV0;
				ELIF iLineasRevAbiertas = 0 THEN
					LET highestUtilOnBankNatlRevTL = MV1;
				ELIF iLineasRevValidas = 0 THEN
					LET highestUtilOnBankNatlRevTL = MV5;
				END IF;

				-------- 26 num_cuentasMOP3 
				LET flag30evertradeline = 'F';
				LET iHistPagosMasValorCount = 0;
				LET iMesesHistContMasValorOcu = MV0;
				LET iMesesHistCont = 0;
				LET iMesesFechaMasRecienteHistPagos = 0;
				LET var_i = 0;
				LET iLineasMorosas = 0;
				LET cFlagDisputa = 'F';
				
				FOREACH
					SELECT tl27_std, mesesfechareporte_std, mesesfechamasrecientehistpagos_std, tl30_std, nvl(tl26_std,'00'), nvl(tl38_std,'0'), nvl(tl33_std,0), nvl(tl34_std,0), nvl(tl35_std,0), saldovecidoestan_std
					INTO cTl27_std, iMesesFechaReporte, iMesesFechaMasRecienteHistPagos, cTl30_std, cTl26_std, cTl38_std, iTl33_std, iTl34_std, iTl35_std, dTl24
					FROM bdiburo:"informix".br_tl_estand
					WHERE empresa_std = pEmpresa
					AND numcte_std = cNumCteBco
					AND bandera_collection = 'F'

					--do process CHECK FOR DISPUTE TRADE LINE
					LET cFlagDisputa = 'F';
					IF cTl30_std IN ('AD', 'CO' , 'SG') THEN
						LET cFlagDisputa = 'T';
					END IF;
					--------
		
					LET cTl27_std = replace(replace(replace(replace(cTl27_std,'-','0'),'X','0'),'U','0'),' ','0');
					LET iHistPagosMasValorCount = 0;
					LET iMesesHistCont = 0;            
					--do process CHECK FOR 30+ EVER TRADE LINE
					FOR var_i = 1 to LENGTH(cTl27_std)
						IF SUBSTR(cTl27_std,var_i,1)  >= 3 OR SUBSTR(cTl27_std,var_i,1) = ''   THEN
							LET iMesesHistCont = iMesesHistCont + 1;
							IF SUBSTR(cTl27_std,var_i,1) >= 3 THEN
								LET iHistPagosMasValorCount = iHistPagosMasValorCount + 1;
								IF  iMesesFechaMasRecienteHistPagos NOT IN (MV7,MV1) THEN
									LET iMesesHistContMasValorOcu =	iMesesHistCont + iMesesFechaMasRecienteHistPagos;
									IF iMesesHistContMasValorOcu < iMesesFechaReporte THEN
										LET iMesesHistContMasValorOcu = iMesesFechaReporte;
									END IF;
								END IF;
							END IF;
						END IF;
					END FOR;

					IF iHistPagosMasValorCount > 0 
					OR cTl30_std IN ('CL', 'FD', 'FP', 'FR', 'GP', 'IM', 'LC', 'LO', 'NV', 'PC', 'UP', 'VR')
					OR cTl26_std IN ('03','04','05','06','07','97','99') 
					OR cTl38_std IN ('03','04','05','06','07','97','99') OR iTl33_std > 0 
					OR iTl34_std > 0 OR iTl35_std > 0 THEN

						LET flag30evertradeline = 'T';
					ELSE
						LET flag30evertradeline = 'F';
					END IF;
					--------

					IF cFlagDisputa = 'F' AND (flag30evertradeline = 'T' OR (dTl24 NOT IN (MV18, MV21, MV9) AND dTl24 > 0)) THEN
						LET iLineasMorosas = iLineasMorosas + 1;
					END IF;

				END FOREACH;
				
				LET num_cuentasMOP3 = iLineasMorosas;

			--END IF;--VVVF

		 -------------------------------------------------------------


			BEGIN WORK;
			INSERT INTO bdisolic:"informix".ss_certif_evaluacion_cte (cSolBanco, cNumCteBco, cStatusSolicitud, iCredDigitalesAct, iCtas_StatusCV, iMaxSalVencidoBancoppel, iCred_StatusFC, 
			iCred_StatusFF_restru, iCred_StatusDif_FF, dMaxSalVencidoCRD, iCuentasStatusCVsinFF, iCtas_StatusDif_FF_6011, dtMinFechaAperturasinFF, dtMinFechaApertura, sCteLargo8, iMeses_hist_Val, 
			sFlagHuella, iSolMc, iSolMcAux, iBanderareferencia, sFlagForzarEnvioMC, sCteLargo, iFlagEmpleado, cRTipo3, cVigSolOS, sBuenPagos, cCteProspVig, fecha_insert) VALUES(
			cSolBanco, cNumCteBco, cStatusSolicitud, iCredDigitalesAct, iCtas_StatusCV, iMaxSalVencidoBancoppel, iCred_StatusFC, iCred_StatusFF_restru, iCred_StatusDif_FF, dMaxSalVencidoCRD,
			iCuentasStatusCVsinFF, iCtas_StatusDif_FF_6011, dtMinFechaAperturasinFF, dtMinFechaApertura, sCteLargo8, iMeses_hist_Val, sFlagHuella, iSolMc, iSolMcAux, iBanderareferencia, 
			sFlagForzarEnvioMC, sCteLargo, iFlagEmpleado, cRTipo3, cVigSolOS, sBuenPagos, cCteProspVig, current	);				

			INSERT INTO bdisolic:"informix".ss_certif_evaluacion_buro (cSolBanco, cNumCteBco, iMax_MOP, cInstCta_MayorMOP, dMonto_UDIS_MayorMOP, iMax_MOP_Hist_6m, cInstCta_MayorMOP_6m, dMontoUDIS_MM_6m,
			iMM_Histo_12m, cInstCta_MayorMOP_12m, dMontoUDIS_MM_12m, iNumCtasMOP_4_12m, iNumCtasMOP_5_12m, iNumCtasMOP_mayor5_12m, iMOP4_12mCon1o2, iMOP5_12mCon1o2, iMOPmayor5_12mCon1o2, dMontoUDIS_MM_Rech,
			iNumCtasMOP_4_30m, iNumCtasMOP_5_30m, iNumCtasMOP_mayor5_30m, iCtasMOP_4_30mCon1o2, iCtasMOP_5_30mCon1o2, iCtasMOP_mayor5_30mCon1o2, iMM_Histo_30m, cInstCta_MM_30m_Rech, dMotoUDIS_MM_30m_Rech, 
			iNumCtas_ClvOb, dMontoUdis, cInstitucion, cClvObser, sBc_Score, vClvExclusionMasReciente, cInstitucionClvExclusionMasReciente, iCtas_SinComServ, iCtas_SinComServ_pagar, iNumCtas_SHBr, 
			iNumCtas_SHBr_pagar, iMM_act_Bancos, iMM_hist_alto_Bancos, iMM_hist_Bancos, iCtasBancosMOP_tl26, iCtasBancosMOP_tl38, iCtasBancosMOP_tl27, iCtasBancosMOP_act_hist_alto, iCtasComServMOP_tl26, 
			iCtasComServMOP_tl38, iCtasComServMOP_tl27, iCtasCSM_act_hist_alto, iCtasComServMOP_tl26_12m, iCtasComServMOP_tl38_12m, iCtasComServMOP_tl27_12m, iCtasCSM_ActHistAlto_12m, dtFechaAux, 
			iMaxMOP_actBancos, iMaxMOP_histAltBancos, iMaxMOP_histBancos, iMaxMOP_actCtas, iMaxMOP_histAltCtas, iMaxMOP_histCtas, mPagoMinimo, sFlagBuenPago12, sFlagBuenPago30, TR0002, TR0001, 
			NumCuentaPagoMinimo, dValor_3s, fecha_insert) VALUES (cSolBanco, cNumCteBco, iMax_MOP, cInstCta_MayorMOP, dMonto_UDIS_MayorMOP, iMax_MOP_Hist_6m, cInstCta_MayorMOP_6m, dMontoUDIS_MM_6m, 
			iMM_Histo_12m, cInstCta_MayorMOP_12m, dMontoUDIS_MM_12m, iNumCtasMOP_4_12m, iNumCtasMOP_5_12m, iNumCtasMOP_mayor5_12m, iMOP4_12mCon1o2, iMOP5_12mCon1o2, iMOPmayor5_12mCon1o2,
			dMontoUDIS_MM_Rech, iNumCtasMOP_4_30m, iNumCtasMOP_5_30m, iNumCtasMOP_mayor5_30m, iCtasMOP_4_30mCon1o2, iCtasMOP_5_30mCon1o2, iCtasMOP_mayor5_30mCon1o2, iMM_Histo_30m, 
			cInstCta_MM_30m_Rech, dMotoUDIS_MM_30m_Rech, iNumCtas_ClvOb, dMontoUdis, cInstitucion, cClvObser, sBc_Score, vClvExclusionMasReciente, cInstitucionClvExclusionMasReciente, 
			iCtas_SinComServ, iCtas_SinComServ_pagar, iNumCtas_SHBr, iNumCtas_SHBr_pagar, iMM_act_Bancos, iMM_hist_alto_Bancos, iMM_hist_Bancos, iCtasBancosMOP_tl26, iCtasBancosMOP_tl38, 
			iCtasBancosMOP_tl27, iCtasBancosMOP_act_hist_alto, iCtasComServMOP_tl26, iCtasComServMOP_tl38, iCtasComServMOP_tl27, iCtasCSM_act_hist_alto, iCtasComServMOP_tl26_12m, iCtasComServMOP_tl38_12m,
			iCtasComServMOP_tl27_12m, iCtasCSM_ActHistAlto_12m, dtFechaAux, iMaxMOP_actBancos, iMaxMOP_histAltBancos, iMaxMOP_histBancos, iMaxMOP_actCtas, iMaxMOP_histAltCtas, iMaxMOP_histCtas, mPagoMinimo,
			sFlagBuenPago12, sFlagBuenPago30, TR0002, TR0001, NumCuentaPagoMinimo, dValor_3s, current);

			INSERT INTO bdisolic:"informix".ss_certif_reingenieria(cSolBanco, cNumCteBco, mosSncOldestRevTLOpnd, numInq0to2Mos, pctBankILTL, pctTL30pDaysEverColl, avgMosInFileTLRptd0To2Mos,
			highestUtilOnBankNatlRevTL, lowestRatingIL, lowestRatingRevOpen, maxDelq0To11Mos, mosSncOldestBankNatlRevOpenTLOpnd, netFrctTLOpnd0To35Mos, totBalDelqTL, numFinInq0to5Mos,
			maxDelqEver, pctInq0To2MosByInq0To11Mos, numRetTLOpnd0to5Mos, num_sumasaldoscuentasabiertas, num_sumalineascuentasabiertas, pct_usocuentasabiertas, num_antiguedadpromediocuentas12meses,
			num_consultasfinanciera, num_maxplazodias, clv_tipoproductocrediticio, num_montofechamorosamasgravemasreciente, num_totalperiodosreportados, num_porcentajecorrientepromedio,
			num_lineacreditopromedio, num_arrendamiento, num_tiendacomercial, clv_worstcurrentmop, num_direcciones, num_montopeoratrasohistoricomasreciente, num_mesespeoratrasohistoricomasreciente,
			num_sumasaldoscuentasrevolventessintelcos, num_sumalineascuentasrevolventessintelcos, pct_usocuentasrevolventessintelcos, num_tarjetacredito, num_consultas90dias, num_cuentasMOP3,
			num_cuentas, num_consultassic, fecha_insert, cestado,cmunicipio) VALUES (cSolBanco, cNumCteBco, mosSncOldestRevTLOpnd, numInq0to2Mos, pctBankILTL, pctTL30pDaysEverColl, avgMosInFileTLRptd0To2Mos,
			highestUtilOnBankNatlRevTL, lowestRatingIL, lowestRatingRevOpen, maxDelq0To11Mos, mosSncOldestBankNatlRevOpenTLOpnd, netFrctTLOpnd0To35Mos, totBalDelqTL, numFinInq0to5Mos,
			maxDelqEver, pctInq0To2MosByInq0To11Mos, numRetTLOpnd0to5Mos, num_sumasaldoscuentasabiertas, num_sumalineascuentasabiertas, pct_usocuentasabiertas, num_antiguedadpromediocuentas12meses,
			num_consultasfinanciera, num_maxplazodias, clv_tipoproductocrediticio, num_montofechamorosamasgravemasreciente, num_totalperiodosreportados, num_porcentajecorrientepromedio,
			num_lineacreditopromedio, num_arrendamiento, num_tiendacomercial, NVL(clv_worstcurrentmop,-2), num_direcciones, num_montopeoratrasohistoricomasreciente, num_mesespeoratrasohistoricomasreciente,
			num_sumasaldoscuentasrevolventessintelcos, num_sumalineascuentasrevolventessintelcos, pct_usocuentasrevolventessintelcos, num_tarjetacredito, num_consultas90dias, num_cuentasMOP3,
			num_cuentas, num_consultassic, current, cEstado, cMunicipio);
		-- PRUEBA EN MAQUETA
	
			IF iTransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
			END IF;	   
		END IF;
	END IF;

						
	RETURN  NVL(cCodRet,000000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,''), NVL(cHabita_en,'??'), nvl(cPuntualidadCoppel,''), NVL(cProfesion,''), NVL(iCredDigitalesAct,0),
			NVL(sId_actividad,0), nvl(cDescAct,''), NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), 
			NVL(sCausaSituacion,-99), nvl(cMotivoRech,''), nvl(cMotivoRechBcpl,''), nvl(cTipoRech,''), nvl(cDescMvo,''), 
			nvl(mTotalVencido,0), nvl(mAbonoTotal,0), nvl(mAbonoVencidoTotal,0), nvl(sHist_meses,0), nvl(cCteExcep,''),
			nvl(iCtas_StatusCV,0), nvl(iMaxSalVencidoBancoppel,0), nvl(dEficienciaCoppel,0), nvl(iCred_StatusFC,0),
			nvl(iCred_StatusFF_restru,0), nvl(iCredits_riesgoD,0), nvl(iCredits_riesgoE,0), nvl(iCredits_riesgoC,0), 
			nvl(iMaxMontoReserva,0), nvl(iCred_StatusDif_FF,0), nvl(dMaxSalVencidoCRD,0), nvl(iCuentasStatusCVsinFF,0), 
			nvl(iCtas_StatusDif_FF_6011,0), nvl(iCredRiesgoD_sinFF,0), nvl(iCredRiesgoE_sinFF,0), nvl(iCredRiesgoC_sinFF,0), 
			nvl(dmaxMontoReservaRiesgoC_sinFF,0), NVL(dtMinFechaAperturasinFF,'01/01/1900'), NVL(dtMinFechaApertura,'01/01/1900'), 
			nvl(cSituacion,''), NVL(dtmaxFechaAperturaDelProducto,'01/01/1900'), NVL(cProducto,""), NVL(dminProcentajeProductoMasReciente,0),
			nvl(mAbonoMuebles,0), nvl(mAbonoPrestamos,0), nvl(mAbonoRopa,0),  nvl(mAbonoAire,0), nvl(mAbonoAfiliados,0),
			nvl(mAbonoReestructura,0), nvl(mVencidoMuebles,0), nvl(mVencidoRopa,0), Nvl(mVencidoPrestamos,0), nvl(mVencidoAire,0), 
			nvl(mVencidoAfiliados,0), nvl(mVencidoReestructura,0), nvl(cFechaUltimoPago,'1900-01-01'), nvl(iReprestamos,0),
			nvl(cOrigenSol,'1'), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''),
			nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(cEjecucion,'0'), nvl(iMax_MOP,0), Nvl(cInstCta_MayorMOP,''), 
			nvl(dMonto_UDIS_MayorMOP,0), nvl(iMax_MOP_Hist_6m,0), NVL(cInstCta_MayorMOP_6m,''), NVL(dMontoUDIS_MM_6m,0), 
			NVL(iMM_Histo_12m,0), nvl(cInstCta_MayorMOP_12m,''),  nvl(dMontoUDIS_MM_12m,0), nvl(iNumCtasMOP_4_12m,0),
			nvl(iNumCtasMOP_5_12m,0), nvl(iNumCtasMOP_mayor5_12m,0), nvl(iMOP4_12mCon1o2,0), nvl(iMOP5_12mCon1o2,0),
			nvl(iMOPmayor5_12mCon1o2,0), nvl(cInstitucionMMOP_provocaRech,''), nvl(dMontoUDIS_MM_Rech,0), nvl(iNumCtasMOP_4_30m,0),
			nvl(iNumCtasMOP_5_30m,0), nvl(iNumCtasMOP_mayor5_30m,0), nvl(iCtasMOP_4_30mCon1o2,0), nvl(iCtasMOP_5_30mCon1o2,0),
			nvl(iCtasMOP_mayor5_30mCon1o2,0), nvl(iMM_Histo_30m,0), nvl(cInstCta_MM_30m_Rech,''), nvl(dMotoUDIS_MM_30m_Rech,0), 
			nvl(iNumCtas_ClvOb,0), nvl(dMontoUdis,0), nvl(cInstitucion,''), nvl(cClvObser,'0'), nvl(sBc_Score,0), 
			nvl(vClvExclusionMasReciente,'0'), nvl(cInstitucionClvExclusionMasReciente,''), nvl(iCtas_SinComServ,0),
			nvl(iCtas_SinComServ_pagar,0), nvl(iNumCtas_SHBr,0), nvl(iNumCtas_SHBr_pagar,0), nvl(BC1,-1), nvl(BC_101,0), 
			nvl(iMM_act_Bancos,0), nvl(iMM_hist_alto_Bancos,0), nvl(iMM_hist_Bancos,0), nvl(BC_117,0), nvl(iCtasBancosMOP_tl26,0),
			nvl(iCtasBancosMOP_tl38,0), nvl(iCtasBancosMOP_tl27,0), nvl(iCtasBancosMOP_act_hist_alto,0), nvl(BC_119,0), 
			nvl(iCtasComServMOP_tl26,0), nvl(iCtasComServMOP_tl38,0), nvl(iCtasComServMOP_tl27,0), nvl(iCtasCSM_act_hist_alto,0),
			nvl(BC_20,0), nvl(iCtasComServMOP_tl26_12m,0), nvl(iCtasComServMOP_tl38_12m,0), nvl(iCtasComServMOP_tl27_12m,0), 
			nvl(iCtasCSM_ActHistAlto_12m,0), nvl(BC_421,0), nVL(dtFechaAux,'01/01/1900'), nvl(BC_85,0),	NVL(iMaxMOP_actBancos,0), 
			NVL(iMaxMOP_histAltBancos,0), nvl(iMaxMOP_histBancos,0), nvl(BC_93,0), nvl(iMaxMOP_actCtas,0), nvl(iMaxMOP_histAltCtas,0),
			nvl(iMaxMOP_histCtas,0), nvl(dSituacionPagoCoppel,0), nvl(mIngreso_Mensual,0), nvl(mPagoMinimo,0), nvl(sCteLargo8,0),
			nvl(iMeses_hist_Val,0), nvl(cTipo_Alta_CteProsp,''), nvl(mLinea_tienda,0), nvl(mImporte_hip,0), nvl(dTasa,0),
			nvl(sFlagHuella,0), nvl(cResultadoOsTel,''), nvl(cTieneOstel,''), nvl(cEnvioCat,''), nvl(iSolMc,0),
			nvl(iSolMcAux,0), nvl(cCod_Ult_Identif,0), NVL(cTelCasa,""), NVL(cTelTrabajo,''), NVL(sValida_Cel,0), 
			NVL(dtUltimaCompra,'01/01/1900'), nvl(iBanderareferencia,0), NVL(dtFechaCte,'01/01/1900'), NVL(cFolioMovil,""),
			NVL(cFlagGeoMov,""), nvl(iFlagGeoSuc,0), nvl(iCanal_Sol,0), nvl(cOrigenCte,''), nvl(sFlagForzarEnvioMC,0), 
			nvl(iSecuenciaOs,0), nvl(cStatusRespOs,''), NVL(dtFecha_Respuesta, 01/01/1900), nvl(cNumSol_Os,''), nvl(cCompIngresos,''),
			nvl(dIngresoCac,0), NVL(sCompValido, 0), nvl(cTipo_movimiento,''), NVL(cSucursal,''), NVL(cTipoSolOS,''),  
			NVL(dCompromisosCac,0), NVL(sFlag_oro,0), nvl(mIngreso_Neto,0), NVL(dtFechaNac,'01/01/1900'), NVL(cSexo,''),
			nvl(cEdo_Civil,''), nvl(iTiem_Edo_Civil,-99), nvl(HR0048,-1), nvl(UT0034,-999), nvl(cOcupacion,''),	nvl(iTiem_Ocupacion, -99), 
			nvl(cEscolaridad,''), nvl(cTipoResidencia,''), nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''),
			NVL(cEntidad,''), NVL(sCteLargo,0), nvl(sScore_coppel,0), NVL(cCURP,''), NVL(iFlagEmpleado,0), NVL(dValor_3s,0),
			nvl(cStatusMovil,''), nvl(cCteProsp,''), nvl(cStatusSol_CteProsp,''), nvl(cRTipo3,''), NVL(cVigSolOS,''), nvl(sBuenPagos,''),
			nvl(dCompromisos,0), nvl(sFlagBuenPago12,0), NVL(sFlagBuenPago30,0), NVL(sEntidad_Localidad,0), nvl(cNuevoStatusOstel,''), 
			nvl(cCteProspVig,''), NVL(mCompro_banco,0), nvl(dComprobanco_TDC,0), NVL(mCompro_bancoPP,0), nvl(cGeoCte,''), nvl(iCanalV1,99), 
			nvl(HR0050,-1), nvl(TR0002,-999), nvl(TR0001,-999), nvl(IQ0002,0), NVL(iCtas_StatusFF_6011,0), NVL(dSaldo_linea_credi,0), 
			NVL(dSaldo_limit_credi,0), nvl(iTiem_Edo_Civil_meses, -99), nvl(dMontoOtorgado,0), nvl(mCapacidad_pago,0), 
			nvl(cVigenciaBancoppel,''), nvl(dLineaBanco,0), nvl(iExisteCliente,0), nvl(mSaldoRopa,0), nvl(mSaldoMuebles,0), 
			nvl(mSaldoPrestamos,0), nvl(mosSncOldestRevTLOpnd,-1), nvl(numInq0to2Mos,0), nvl(pctBankILTL,0), nvl(pctTL30pDaysEverColl,'0'), 
			nvl(avgMosInFileTLRptd0To2Mos,'0'), nvl(highestUtilOnBankNatlRevTL,-999), nvl(lowestRatingIL,0), nvl(lowestRatingRevOpen,0),
			nvl(maxDelq0To11Mos,'99'), nvl(mosSncOldestBankNatlRevOpenTLOpnd,-1), nvl(netFrctTLOpnd0To35Mos,'0'), nvl(totBalDelqTL,0), 
			nvl(numFinInq0to5Mos,0), nvl(maxDelqEver,99), nvl(pctInq0To2MosByInq0To11Mos,'0'), nvl(numRetTLOpnd0to5Mos,0),
			nvl(num_sumasaldoscuentasabiertas,0), nvl(num_sumalineascuentasabiertas,0), nvl(pct_usocuentasabiertas,0),
			nvl(num_antiguedadpromediocuentas12meses,0), nvl(num_consultasfinanciera,0), nvl(num_maxplazodias,-1), 
			nvl(clv_tipoproductocrediticio,''),	nvl(num_montofechamorosamasgravemasreciente,-1), nvl(num_totalperiodosreportados,0),
			nvl(num_porcentajecorrientepromedio,-1), nvl(num_lineacreditopromedio,-2), nvl(num_arrendamiento,0),
			nvl(num_tiendacomercial,0), nvl(clv_worstcurrentmop,-2), nvl(num_direcciones,0), nvl(num_montopeoratrasohistoricomasreciente,-1),
			nvl(num_mesespeoratrasohistoricomasreciente,-1), nvl(num_sumasaldoscuentasrevolventessintelcos,0), 	
			nvl(num_sumalineascuentasrevolventessintelcos,0), nvl(pct_usocuentasrevolventessintelcos,0),
			nvl(num_tarjetacredito,0), nvl(num_consultas90dias,0), nvl(num_cuentasMOP3,0), nvl(num_cuentas,0), nvl(num_consultassic,0), 
			nvl(vgrupoA,''), nvl(NumSolMovil,''), nvl(iFlag2credito,0), nvl(NumCuentaPagoMinimo,0),	NVL(dtFechaSolicitud, '01/01/1900'), 
			NVL(sEdadCte,0), nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(dSalariomin,0), NVL(dTasa_Ordinaria,0),
			NVL(dTasa_Moratoria,0), NVL(diva,0), NVL(dDiaspromedio,0), NVL(dTope_ingre,0), NVL(dcVeces_smb,0), NVL(dPorcpermitido,0),
			NVL(dMesespermitido,0), NVL(dMinimomesespermitido,0), NVL(cEstado,''), NVL(cMunicipio,''), NVL(cBRM_reing,'0');
END;
	
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea sp para armado de variables necesarias para motor de evaluacion',
'Modifico    : Vera Mariscal',
'Fecha       : 01/07/2022',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega armado de variables de reingenieria para TDC clasica',
'Modifico    : Vera Mariscal',
'Fecha       : 15/03/2022',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega manejo de error -535 ',
'Modifico    : Jesus Isaias Bueno Castro',
'Fecha       : 13/06/2024',
'BD          : BDICRED',
'------------------------------------------------------------------------------------',
'Autor:  Felipe Antonio Ruiz AcuÃÂ±a.',
'Modifica: Se agrega consulta a la tabla ss_nuevo_parametrico para consultar el valor de score_domicilio y asignarlo a dTope_ingre',
'Fecha: 09-07-2024.',
'Peticion: RQM 39461 ObtenciÃÂ³n del Score Telcos para input BRM TDC (SoluciÃÂ³n intermedia)',
'------------------------------------------------------------------------------------',
'FECHA: 12/09/2024',
'MODIFICACION:  Se agrega consulta y validacion para recuperar el dato del subcanal para enviarlo en la trama del BRM de coppel',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para evaluar solicitudes TDC ORO por motor (BRM)',
'Modifico    : 99805455 - Alan Castro Paredes',
'Fecha       : 30/10/2025',
'BD          : Bdisolic',
'Peticion    : RQM 09 670';

CREATE PROCEDURE "informix".sp_cobro_automatico_adn(pEmpresa 		CHAR(3),
													pNumCte 		CHAR (20),
													pNumSol 		CHAR (20),
													pCtaNom 		CHAR (20), 
													pDivisa 		CHAR(2), 
													pMonto_disp 	MONEY(14,2),
													pStatusCred 	CHAR(2),
													pIdUnidadProd 	INTEGER)
RETURNING CHAR(6)       AS codigo_retorno,       
          CHAR(125)     AS mens_ret, 		  
		  CHAR (15)     AS proceso, 
		  CHAR(16) 		AS NumeroFolio,
		  CHAR(6)		AS CodRetAux,
		  VARCHAR(80,1) AS ErrorInfo,
		  DECIMAL(18,2) AS MontoFinanciado;

--Ejecucion por hora dentro del proceso de PDN (sp_cobro_automatico_pp_6400.sql)
DEFINE cCodRet			CHAR(5);
DEFINE cCodRetAux		CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		VARCHAR(80,1);
DEFINE cMensajeRet  	CHAR(125);
DEFINE vcproceso    	CHAR(15);
DEFINE wBegin       	CHAR(1);
DEFINE g_StatusCtaCap 	CHAR(1);
DEFINE g_SdoCta	 		DECIMAL(14,2);
DEFINE g_SdoDisp	 	DECIMAL(14,2);
DEFINE g_TranRet		CHAR(4);
DEFINE g_FechaCargo		DATE;
DEFINE dtFechaHoy		DATE;
DEFINE g_MtoRet	 		DECIMAL(14,2);
DEFINE cDivisa			CHAR(2);
DEFINE cNumeroFolio 	CHAR(16);
DEFINE cNumCte   		CHAR(20);
DEFINE cCtaNom   		CHAR(20);
DEFINE cNumSol   		CHAR(20);
DEFINE dMonto_disp    	MONEY(14,2);
DEFINE iBandera			INTEGER;
DEFINE dFechaCuota		DATE;
DEFINE dCapitalStatus	CHAR(1);
DEFINE dCapitalDebe		DECIMAL(18,2);
DEFINE dMontoFinanciado	DECIMAL(18,2);
DEFINE dCodRef			INTEGER;
DEFINE dStatusCred		CHAR(2);
DEFINE cIdUnidadProd	INTEGER;

LET cCodRet				= "00000";
LET cCodRetAux			= "000000";
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';
LET cMensajeRet			= "Se realiza el pago correctamente";
LET vcproceso			= 'CobroautoADN';
LET g_StatusCtaCap		= '';
LET g_SdoCta			= 0;
LET g_SdoCta			= 0;
LET g_SdoDisp			= 0;
LET g_TranRet			= '';
LET g_FechaCargo		= DATE(1);
LET dtFechaHoy			= DATE(1);
LET g_MtoRet			= 0;
LET cDivisa				= pDivisa;
LET cNumeroFolio		= '';
LET cNumCte				= pNumCte;
LET cCtaNom				= pCtaNom;
LET cNumSol				= pNumSol;
LET dMonto_disp			= pMonto_disp;
LET  iBandera			= 0;
LET dFechaCuota			=  DATE(1);
LET dCapitalStatus		= '';
LET dCapitalDebe		= 0;
LET dCodRef				= 0;
LET dStatusCred			= pStatusCred;
LET cIdUnidadProd		= pIdUnidadProd;
LET wbegin				= 'N';
LET dMontoFinanciado	= 0;

BEGIN
	-- MANEJO DE EXCEPCIONES SQL
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet     = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;		
		END IF;
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;
	END EXCEPTION;

	ON EXCEPTION IN (-255)
		LET wBegin = "B";
	END EXCEPTION WITH RESUME;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;	

--SET DEBUG FILE TO "/tmp/sp_cobro_automatico_adn.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(NVL(pEmpresa,"")) = ""  THEN
		LET cCodRet		= "00001";
		LET cMensajeRet	= "No tiene empresa el parametro";
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;	
	END IF;

	SELECT 	fecha_hoy
	INTO 	dtFechaHoy
	FROM 	bdicred:"informix".sd_fechas
	WHERE 	empresa = pEmpresa;
	
	--INC Anticipo se corrige para que no cobre doble
	SELECT 	COUNT(*)
	INTO 	dCapitalDebe
	FROM 	"informix".sd_amortiza_credito a
	WHERE 	a.empresa     		= pEmpresa
	AND 	a.num_credito 		= cNumSol
	AND 	a.capital_status 	IN ("1", "7", "2", "6")
	AND 	(a.capital_debe - a.capital_pagado) > 0;	

	IF dCapitalDebe = 0 THEN
		LET cCodRet 	= "00002";
		LET cMensajeRet	= "No tiene Saldo Deudor";	
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;				
	END IF;
	
	-- SE OBTIENE SALDO DE LA CUENTA DE NOMINA
	CALL bdicheq:"informix".cons_saldo(cCtaNom) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

	IF (cCodRetAux <> "000") THEN
		LET cCodRet 	= "00003";
		LET cMensajeRet	= "Ocurrio un error al obtener saldo de cuenta nomina";			
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;			
	END IF;

	-- SE VALIDA EL SALDO DE LA CUENTA
	IF NVL(g_SdoCta,0) <= 0 THEN
		LET cCodRet 	= "00004";
		LET cMensajeRet	= "No tiene Saldo la cuenta de nomina";			
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;				
	END IF;
	
	LET  iBandera	= 0;

	IF g_SdoCta < dMonto_disp THEN
		LET dMonto_disp = g_SdoCta;
		LET iBandera = 1;
	END IF;

	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina('ANTICIPO') RETURNING cCodRetAux, cNumeroFolio;

	BEGIN WORK;

	-- SE REALIZA EL CARGO A LA CUENTA
	EXECUTE PROCEDURE  bdicheq:"informix".cargo_ref('001', '9290', 'informix', '0398', "0000", cNumeroFolio, cCtaNom, 0, dMonto_disp, cDivisa, "", "0", '')
	INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;

	IF cCodRetAux <> "000" THEN
		LET cCodRet 	= "00005";
		LET cMensajeRet = "Ocurrio un error al realizar el cargo a la cuenta de nomina";
		IF wbegin = 'S' THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;	
	END IF;

	-- SE CONSULTA FECHA CUOTA, STATUS Y CAPITAL DEBE DE LA AMORTIZACION
	FOREACH WITH HOLD
		SELECT 	a.fecha_cuota, a.capital_status,  a.capital_debe - a.capital_pagado
		INTO 	dFechaCuota, dCapitalStatus, dCapitalDebe
		FROM 	"informix".sd_amortiza_credito a
		WHERE 	a.empresa     		= pEmpresa
		AND 	a.num_credito 		= cNumSol
		AND 	a.capital_status 	IN ("1", "7", "2", "6")
		ORDER BY a.num_credito, a.fecha_cuota			

		IF g_SdoCta < dCapitalDebe THEN
			LET dCapitalDebe = g_SdoCta;
			LET iBandera = 1;
		END IF;
			
		--se realiza el pago al credito de nomina

		IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN
			IF dCapitalStatus = "1" THEN
				LET dCodRef = 10;
			ELIF dCapitalStatus = "7" THEN
				LET dCodRef = 7;
			ELIF dCapitalStatus = "2" THEN 
				LET dCodRef = 8;
			END IF;
		ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN
			IF dCapitalStatus = "1" THEN
				LET dCodRef = 1120; --PAGO NO EXGIBLE E1
			ELIF dCapitalStatus = "7" THEN
				LET dCodRef = 1121;  --PAGO EXGIBLE E1
			ELIF dCapitalStatus = "6" THEN 
				LET dCodRef = 1122;  --PAGO EXGIBLE E3
			END IF;
		END IF;
					
		IF dCapitalDebe > 0 THEN

			IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

				UPDATE 	"informix".sd_maesdos
				SET 	sdo_cap_insoluto	= sdo_cap_insoluto - dCapitalDebe,
						sdo_capital			= (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
						monto_vencido		= (CASE WHEN dCapitalStatus = "7" THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
						mto_venc_trasp		= (CASE WHEN dCapitalStatus = "2" THEN (mto_venc_trasp - dCapitalDebe) ELSE mto_venc_trasp END),
						monto_financiado	= monto_financiado - dCapitalDebe
				WHERE 	empresa			= pEmpresa 
				AND 	num_credito		= cNumSol;

			ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN

				UPDATE 	"informix".sd_maesdos
				SET 	sdo_cap_insoluto	= sdo_cap_insoluto - dCapitalDebe,
						sdo_capital			= (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
						monto_vencido		= (CASE WHEN dCapitalStatus IN ("7","6") THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
						monto_financiado	= monto_financiado - dCapitalDebe
				WHERE 	empresa		= pEmpresa 
				AND 	num_credito	= cNumSol;

			END IF;

			UPDATE "informix".sd_amortiza_credito
			SET		capital_pagado     = capital_pagado + dCapitalDebe,
					capital_fecha_pago = dtFechaHoy,
					capital_status_ant = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN capital_status ELSE capital_status_ant END),
					capital_status     = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN "5" ELSE capital_status END)
			WHERE	empresa		= pEmpresa
			AND		num_credito	= cNumSol
			AND		fecha_cuota	= dFechaCuota;

			-- Total del Pago
			CALL "informix".GenMov(pEmpresa , cNumSol, '7800', 1, '074', dtFechaHoy, dCapitalDebe, cNumeroFolio, '9290', cDivisa, '8175') 		RETURNING cCodRet, cErrorInfo;

			CALL "informix".genmov(pEmpresa, cNumSol, '7800', dCodRef, '074', dtFechaHoy, dCapitalDebe,cNumeroFolio,'9290', cDivisa, '8175')	RETURNING cCodRet, cErrorInfo;

			if cCodRet = '00000' then
				-- ACTUALIZAR sd_indicador_cred
				UPDATE 	"informix".sd_indicador_cred
				SET 	fecha_ultimo_pago = dtFechaHoy,
						monto_ultimo_pago = dCapitalDebe
				WHERE 	empresa = pEmpresa
				AND 	num_credito = cNumSol;

				--- ACTUALIZAR sd_maecredanexo   
				UPDATE 	"informix".sd_maecredanexo
				SET 	fecha_ult_pago = dtFechaHoy
				WHERE 	empresa 	= pEmpresa
				AND 	num_credito = cNumSol;

			END IF;
							
		END IF;
					
	END FOREACH;
				 
				 
	IF iBandera =  1 THEN
	
		UPDATE 	bdisolic:"informix".ss_adn_solicitudcuenta
		SET 	activacion_cobrada 	= '2' , -- 2 SE COBRO PERO NO TOTALMENTE
				monto_disp			= monto_disp - dMonto_disp
		WHERE 	numcte 			= cNumCte
		AND 	num_solicitud	= cNumSol;
	
	ELSE

		UPDATE	bdisolic:"informix".ss_adn_solicitudcuenta
		SET		activacion_cobrada	= '1',
				fecha_ult_disp		= '',
				monto_disp			= monto_disp - dMonto_disp
		WHERE 	numcte			= cNumCte
		AND 	num_solicitud	= cNumSol;

		--- Actualizar sd_maecredanexo   
		UPDATE 	"informix".sd_maecredanexo
		SET 	fecha_vencto	= null
		WHERE 	empresa 	= pEmpresa
		AND	 	num_credito	= cNumSol;

		UPDATE 	"informix".sd_maesdos
		SET 	act = 0
		WHERE 	empresa 	= pEmpresa
		AND 	num_credito = cNumSol;

		IF (cIdUnidadProd != 3) THEN
			LET cIdUnidadProd = NULL;
		END IF;

		IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

			UPDATE 	bdicred:"informix".sd_maecred
			SET 	id_unidad_prod	= cIdUnidadProd, 
					Cod_caract_2	= '', 
					status_cred		='AA'
			WHERE 	empresa 	= '001'
			AND 	num_credito = cNumSol;

		ELIF (dStatusCred ='E1' OR dStatusCred ='E2' OR dStatusCred ='E3') THEN

			UPDATE 	bdicred:"informix".sd_maecred
			SET 	id_unidad_prod	= cIdUnidadProd,
					Cod_caract_2	= '',
					status_cred		= 'E1'
			WHERE 	empresa 	= '001'
			AND 	num_credito = cNumSol;

			UPDATE	bdicred:"informix".sd_indicador_cred
			SET		dias_atraso = '0'
			WHERE	empresa 	= '001'
			AND		num_credito = cNumSol;

		END IF;

	END IF;

	-- SE OBTIENE NUEVO MONTO FINANCIADO
	SELECT 	monto_financiado INTO dMontoFinanciado
	FROM 	"informix".sd_maesdos  
	WHERE 	empresa 	= pEmpresa
	AND 	num_credito = cNumSol;			
		
    IF wbegin = 'S' THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;		
		
	RETURN cCodRet, cMensajeRet, vcproceso, cNumeroFolio, cCodRetAux, cErrorInfo, dMontoFinanciado;
	
END
END PROCEDURE
DOCUMENT
'=======================================================',
'Proyecto	: RQM 09 704',
'Descripcion: Procedimiento para realizar el cobro con cargo a cuenta por credito del producto de Anticipo de Nomina',
'Desarrollo	: Juan Olivares Martinez/Maria Elena Angulo',
'Fecha		: 13/Marzo/2025',
'=======================================================';

CREATE PROCEDURE "informix".sp_genera_rpt_cobranza_automatica()
RETURNING 	CHAR(5) as cCodRet, 
			CHAR(150) as cMensajeRet;
	
	
	--Variables de retorno del SP 
	DEFINE cCodRet				CHAR(5);
	DEFINE cMensajeRet			CHAR(150);
	--Variables para el manejo de excepciones
	DEFINE iSQLError            INTEGER;
	DEFINE iISAMError           INTEGER;
	--Variables para la generacion de los reportes
	DEFINE dFechaAnt			DATE;
	DEFINE cNombreArchivoAN		CHAR(40);
	DEFINE cNombreArchivoPDN	CHAR(40);
	DEFINE cEncabezadoArchivo	CHAR(150);
	DEFINE cRutaArchivo			CHAR(100);
	DEFINE cSystem				CHAR(400);
	DEFINE cDia					CHAR(2);
	DEFINE cMes                 CHAR(2);
	DEFINE cAnio                CHAR(4);
	--Variables para la obtencion de datos para el archivo
	DEFINE dFechaOperacion		DATE;
	DEFINE cFechaFormato		CHAR(10);
	DEFINE cCuentaCredito       CHAR(20);
	DEFINE cCuentaEje           CHAR(20);
	DEFINE mMontoPorCobrar      DECIMAL(18,2);
	DEFINE mMontoCobrado        DECIMAL(18,2);
	DEFINE mMontoPendiente      DECIMAL(18,2);
	DEFINE iRecuperacion        INTEGER;
	--Variables de utileria
	DEFINE iContadorAND			INTEGER;
	DEFINE iContadorPDN			INTEGER;
	
	
	--Declaracion de archivo de debuggeo
	--SET DEBUG FILE TO "/home/c90314833/sp_genera_rpt_cobranza_automatica.out";
    --TRACE ON;	
	
	--Asignacion de variables
	LET cCodRet					= '00000';
	LET cMensajeRet				= 'Reportes generados correctamente';
								  
	LET iSQLError				= 0;
	LET iISAMError				= 0;
	
	LET dFechaAnt				= TODAY;
	LET cNombreArchivoAN		= 'COBRANZA_AN_AAAAMMDD.txt';
	LET cNombreArchivoPDN		= 'COBRANZA_PDN_AAAAMMDD.txt';
	LET cEncabezadoArchivo		= '| FechaOperacion | CuentaCredito | CuentaEje | MontoPorCobrar | Cobrado | PendientePorCobrar | % Recuperacion |';
	LET cRutaArchivo			= '/RESPALDOSNEW/';
	LET cSystem 				= '';
	LET cDia					= '';
	LET cMes                    = '';
	LET cAnio                   = '';
	
	LET dFechaOperacion			= TODAY;
	LET cFechaFormato			= '';
	LET cCuentaCredito  		= ''; 
	LET cCuentaEje      		= ''; 
	LET mMontoPorCobrar 		= 0.00; 
	LET mMontoCobrado   		= 0.00; 
	LET mMontoPendiente 		= 0.00; 
	LET iRecuperacion   		= 0; 
								  
	LET iContadorAND			= 0;
	LET iContadorPDN			= 0;
	
	BEGIN
		--Manejo de excepciones
		ON EXCEPTION SET iSQLError, iISAMError, cMensajeRet
			IF iSQLError <> 0 THEN
				LET cCodRet = iSQLError;
			END IF;
			RETURN cCodRet,cMensajeRet;
			
		END EXCEPTION;
		
		--Directivas de lectura y espera
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		--Obtencion de la fecha del dia anterior
		SELECT fecha_ant 
		INTO dFechaAnt
		FROM bdicred:sd_fechas;
		
		--Obtencion de datos sobre la fecha para sustitucion en el nombre
		LET cDia   = LPAD(DAY(dFechaAnt::DATE), 2, '0');
		LET cMes   = LPAD(MONTH(dFechaAnt::DATE), 2, '0');
		LET cAnio = YEAR(dFechaAnt ::DATE);
		
		--Generacion del nombre del archivo y la ruta para la escritura del reporte.
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'AAAA',cAnio);
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'MM',cMes);
		LET cNombreArchivoAN  = REPLACE(cNombreArchivoAN,'DD',cDia);
		LET cRutaArchivo = TRIM(cRutaArchivo) || TRIM(cNombreArchivoAN);
		
		--Armado de encabezado del archivo de anticipo de nomina
		LET cSystem = 'echo "'|| TRIM(cEncabezadoArchivo) ||'" > ' ||TRIM(cRutaArchivo);
		SYSTEM cSystem;
		
		--Ciclo para la alimentacion del archivo de Anticipo de Nomina
		FOREACH WITH HOLD
		SELECT fch.fecha_ant as fecha_operacion, mae.num_credito as Cuenta_credito,adn.cuenta_nomina as Cuenta_eje,sdo.mto_reser_int as montoxcobrar,
			NVL(SUM(mov.monto),0) as mto_cobrado,  sdo.monto_reservado as Pendientexcobrar, 
			CASE WHEN sdo.mto_reser_int > 0 THEN ROUND((NVL(SUM(mov.monto),0)/sdo.mto_reser_int)*100,2) ELSE 0 END as Recuperacion
		INTO dFechaOperacion,cCuentaCredito,cCuentaEje,mMontoPorCobrar,mMontoCobrado,mMontoPendiente,iRecuperacion
		FROM bdicred:sd_maesdos sdo
		 INNER JOIN bdicred:sd_maecred mae ON (sdo.num_credito = mae.num_credito AND mae.status_cred IN ('E1','E2','E3') AND mae.num_producto ='7800')
		 INNER JOIN bdisolic: ss_adn_solicitudcuenta adn ON (mae.num_credito=adn.num_solicitud) 
		 INNER JOIN bdicred:sd_fechas fch ON (mae.empresa = fch.empresa)
		 LEFT JOIN bdicred:sd_movhis mov ON (mae.num_credito = mov.num_credito AND mov.fecha_mov >= fch.fecha_ant 
												AND mov.codigo_fun IN(select cod_fun from bdicred:sd_conceptospagomanual) AND codigo_ref ='1')
			WHERE sdo.mto_reser_int > 0
			group by fch.fecha_ant , mae.num_credito,adn.cuenta_nomina,sdo.mto_reser_int,sdo.monto_reservado
		
			IF cCuentaCredito != '' THEN
				LET iContadorAND = iContadorAND + 1;
			END IF;			
		
			LET cFechaFormato = LPAD(DAY(dFechaOperacion::DATE), 2, '0') || '/' || LPAD(MONTH(dFechaOperacion::DATE), 2, '0') || '/' || YEAR(dFechaOperacion ::DATE) ;
			
			LET cSystem = 'echo " | ' || cFechaFormato || ' | ' ||TRIM(cCuentaCredito)|| ' | ' ||TRIM(cCuentaEje)|| ' | ' ||mMontoPorCobrar|| ' | ' ||mMontoCobrado|| ' | ' ||mMontoPendiente|| ' | ' ||iRecuperacion|| '% |" >> '||TRIM(cRutaArchivo);
			SYSTEM cSystem;
			
		END FOREACH;		
		
		--Generacion del nombre del archivo y la ruta para la escritura del reporte.
		LET cRutaArchivo = '/RESPALDOSNEW/';
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'AAAA',cAnio);
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'MM',cMes);
		LET cNombreArchivoPDN  = REPLACE(cNombreArchivoPDN,'DD',cDia);
		LET cRutaArchivo = TRIM(cRutaArchivo) || TRIM(cNombreArchivoPDN);
		
		--Armado de encabezado del archivo de prestamo directo de nomina
		LET cSystem = 'echo "'|| TRIM(cEncabezadoArchivo) ||'" > ' ||TRIM(cRutaArchivo);
		SYSTEM cSystem;
		
		--Reinicio de variables para evitar sobreescritura.
		LET dFechaOperacion			=TODAY;	
		LET cFechaFormato 			='';
		LET cCuentaCredito  		=''; 
		LET cCuentaEje      		=''; 
		LET mMontoPorCobrar 		=0.00; 
		LET mMontoCobrado   		=0.00; 
		LET mMontoPendiente 		=0.00; 
		LET iRecuperacion   		=0; 
		
		--Ciclo para la alimentacion del archivo de Prestamo Directo de Nomina
		FOREACH WITH HOLD
		SELECT fch.fecha_ant as fecha_operacion, mae.num_credito as Cuenta_credito,  cta.num_cta as Cuenta_eje,sdo.mto_reser_int as montoxcobrar,
			NVL(SUM(mov.monto),0) as mto_cobrado,  sdo.monto_reservado as Pendientexcobrar, 
			CASE WHEN sdo.mto_reser_int > 0 THEN ROUND((NVL(SUM(mov.monto),0)/sdo.mto_reser_int)*100,2) ELSE 0 END as Recuperacion
			INTO dFechaOperacion,cCuentaCredito,cCuentaEje,mMontoPorCobrar,mMontoCobrado,mMontoPendiente,iRecuperacion
				FROM bdicred:sd_maesdoscrd sdo
				INNER JOIN bdicred:sd_maecredcrd mae ON (sdo.num_credito = mae.num_credito AND mae.status_cred IN ('E1','E2','E3') AND mae.num_producto ='6400')
				INNER JOIN bdicred:sd_ctascarg cta ON (mae.num_credito=cta.num_credito) 
				INNER JOIN bdicred:sd_fechas fch ON (mae.empresa = fch.empresa)
				LEFT JOIN bdicred:sd_movhiscrd mov ON (mae.num_credito = mov.num_credito AND mov.fecha_mov >= fch.fecha_ant 
						AND mov.codigo_fun IN(select cod_fun from bdicred:sd_conceptospagomanualcrd) AND codigo_ref ='1')
						WHERE sdo.mto_reser_int > 0
						GROUP BY fch.fecha_ant , mae.num_credito,cta.num_cta,sdo.mto_reser_int,sdo.monto_reservado
			
			IF cCuentaCredito != '' THEN
				LET iContadorPDN = iContadorPDN + 1;
			END IF;			
						
			LET cFechaFormato = LPAD(DAY(dFechaOperacion::DATE), 2, '0') || '/' || LPAD(MONTH(dFechaOperacion::DATE), 2, '0') || '/' || YEAR(dFechaOperacion ::DATE) ;
						
			LET cSystem = 'echo " | ' || cFechaFormato || ' | ' ||TRIM(cCuentaCredito)|| ' | ' ||TRIM(cCuentaEje)|| ' | ' ||mMontoPorCobrar|| ' | ' ||mMontoCobrado|| ' | ' ||mMontoPendiente|| ' | ' ||iRecuperacion|| '% |" >> '||TRIM(cRutaArchivo);	
			SYSTEM cSystem;
			
		END FOREACH;
		
		IF iContadorAND > 0 AND iContadorPDN > 0 THEN
			
			RETURN cCodRet,cMensajeRet;
		
		END IF; 
		
		IF iContadorAND = 0 AND iContadorPDN = 0 THEN
			
			LET cCodRet = '00001';
			LET cMensajeRet = 'Los reportes generados no contienen datos';
			RETURN cCodRet,cMensajeRet;
		
		ELSE		
			LET cCodRet = '00002';
			LET cMensajeRet = 'Al menos uno de los reportes se genero sin datos';
			RETURN cCodRet,cMensajeRet;
			
		END IF;
	
	END
END PROCEDURE
DOCUMENT
'AUTOR :        Daniel Hernandez Garcia',
'FECHA :        01-10-2025',
'DESCRIPCION :  Este SPL tiene la finalidad de generar los reporte de las cuentas de PDN(Prestamo Directo de Nomina) y de ADN (Anticipo de Nomina)',
'               considerando como terminarion al finar el dia anterior, mostrando solo las cuentas que cuentan con una exigencia de pago',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicred',
'VERSION :      1.0.0';

CREATE PROCEDURE "informix".apercred1_tc(
			 P_EMPRESA       VARCHAR(3),
             P_SOLICITUD     VARCHAR(20),
		 	 P_EJECUTIVO     CHAR(8))

RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la busqueda de tabla si_ingresos
--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE V_SECUENCIA_MAX       INTEGER;
DEFINE V_EQ_DIAS             INTEGER;
DEFINE V_EXISTE_REG          INTEGER;
DEFINE P_ERROR               VARCHAR(8);
DEFINE cCodRetTDif			 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE P_MENSAJE             VARCHAR(80);
DEFINE V_DIF_INT             INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO DATE;
DEFINE V_INSERT              INTEGER;
DEFINE V_E_CODTRASP          INTEGER;
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA         CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
define v_num_credito         char(20);
define vdigverif             char(1);
DEFINE SQL_ERR               INTEGER;
DEFINE ISAM_ERR              INTEGER;
DEFINE ERROR_INFO            VARCHAR(80);
define vcodret               char(5);
DEFINE vNumCte               CHAR(20);
DEFINE vTpCte                CHAR(1);
DEFINE vIngreso              DECIMAL(14,2);
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vMensaje              CHAR(200);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte             SMALLINT;
DEFINE i		     SMALLINT;
DEFINE V_CATIVA		     DECIMAL(9,6);
DEFINE V_MERCADEO            CHAR(1);
DEFINE iSecIngreso SMALLINT;
---I---RQM 10 960 TDC GC
DEFINE vPtosTasaPref		DECIMAL(9,6);
DEFINE vIdTasaFref			CHAR(1);
DEFINE v_cont				INTEGER;
---F---RQM 10 960 TDC GC
--RQM 10 679 AAME
DEFINE cCodRetOro	 CHAR(6);
DEFINE cMenRet VARCHAR(100,1);
DEFINE dLinea		  DECIMAL(18,2)	;
DEFINE cSolOro		  CHAR(20) ;
DEFINE iConfirmaOro		SMALLINT ;
DEFINE cTelCel		CHAR(10) ;
DEFINE cCodRet		CHAR(6) ;

DEFINE dFechaT              DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE iFrecuencia      	INTEGER;

DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);			  
DEFINE mMntoComApert    DECIMAL(18,2);      
DEFINE dComisiones      DECIMAL(18,2);
DEFINE mMntoComAnual    DECIMAL(18,2);      -- FIN RQM 10 993 CAT
DEFINE dComs_GastCob	DECIMAL(18,2);		-- RQM 10 1253
DEFINE cGrupo_sol		CHAR(1);			-- INI RQM 10 1224
DEFINE cEvalua_cc_sol	CHAR(1);
DEFINE dMax_fecha_tasa	DATE;				-- FIN RQM 10 1224

--- Cuenta Clabe RQM 06 683
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE gpo              CHAR(1); --RQM 10 1225
DEFINE evalcc           CHAR(1); --RQM 10 1225
DEFINE v_idi            CHAR(1); --RQM 10 1225
DEFINE vDispEfec        CHAR(1); --RQM 10 1225
DEFINE v_indde          SMALLINT; --RQM 10 1225
DEFINE cIFRS			CHAR(1);
DEFINE cStatus_cred 	CHAR(2);
DEFINE iAtr_Act_ifrs	INTEGER;

--RQM 09 616
DEFINE cCanal           CHAR(1);
DEFINE cStatuSol        CHAR(2);

-- Bloqueo por apertura en horario de cierre
DEFINE dFechaIntegral   DATE;
DEFINE dFechaCierreCred   DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cStatusCierreCred  CHAR(1);
DEFINE cIndCierreCheq   CHAR(1);
DEFINE cCodRet2 			  CHAR(5);
DEFINE cCuentaSolDif    INT;
-- Bloqueo por apertura en horario de cierre

-- SET DEBUG FILE TO "/home/c90271846/apercred1_tc.out";
-- TRACE ON;

LET V_TASA_MORA = 0;
LET V_TASA_INTERES = 0;
LET V_MERCADEO = "";

---I---RQM 10 960 TDC GC
LET vPtosTasaPref = 0;
LET vIdTasaFref = "";
LET v_cont = 0;
---F---RQM 10 960 TDC GC

--RQM 10 679 AAME
LET  cCodRetOro	= "";
LET  cMenRet = "";
LET  dLinea	 = 0;
LET  cSolOro = "";
LET  iConfirmaOro = 0;

LET cTelCel = "";
LET dFechaT = DATE(1);
LET iDiaPago = 0;
LET iFrecuencia = 0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal =0;
LET dPagoReq =0;

LET cCobro_Apertu    = '';          -- INI RQM 10 993 CAT
LET cCodComis_Apert  = '';
LET cCobrComisAnual  = '';
LET dClvComAnualTit  = '';
LET dClvComAnualAdi  = '';
LET cCat_adicional   = '';
LET dMtoComAnualTit  = 0;
LET dMtoComAnualAdi  = 0;
LET mMntoComApert    = 0;
LET mMntoComAnual    = 0;
LET dComisiones      = 0;           -- FIN RQM 10 993 CAT
LET dComs_GastCob	 = 0;			-- RQM 10 1253
LET V_SOBRETASA      = 0;
LET V_SOBRETASA_MORA = 0;
LET V_FACTOR		 = '';
LET V_FACTOR_MORA	 = '';
LET cGrupo_sol		 = ''; 
LET cEvalua_cc_sol	 = ''; 
LET dMax_fecha_tasa	 = DATE(1);
LET cCodRetTDif		 = '';

--- Cuenta Clabe RQM 06 683
LET vcod_ret			= '000';
LET cta_Clabe			= '';
LET gpo              =''; --RQM 10 1225
LET evalcc           =''; --RQM 10 1225
LET v_idi            =''; --RQM 10 1225
LET vDispEfec        =''; --RQM 10 1225
LET v_indde          = 0; --RQM 10 1225
LET cIFRS			 = '';
LET cStatus_cred 	 = '';
LET iAtr_Act_ifrs	 = 0;

--RQM 09 616
LET cCanal           = '';
LET cStatuSol        = '';

-- Bloqueo por apertura en horario de cierre
LET dFechaIntegral   = DATE(1);
LET dFechaCierreCred   = DATE(1);
LET dFechaHabilAnt   = DATE(1);
LET cStatusCierreCred  = '1';
LET cIndCierreCheq   = '1';
LET cCodRet2			   = '00000';
LET cCuentaSolDif    = 0;
-- Bloqueo por apertura en horario de cierre

--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
SELECT valor INTO V_CATIVA
FROM   sd_param
WHERE  cod_param = '034';

IF V_CATIVA IS NULL THEN
   LET V_CATIVA = 0;
END IF

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_ERROR    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		DELETE FROM SD_MAESDOS
		WHERE EMPRESA = P_EMPRESA
		AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MOVDIA
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MAECREDANEXO
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

        UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AT"
        WHERE empresa = P_EMPRESA
        AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:ss_autorizacion
        WHERE empresa = P_EMPRESA
        AND num_solicitud = P_SOLICITUD
	    AND status_solicitud = "AP";

		DELETE FROM bdicred:sd_amortiza_credito
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_MAECRED
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

		DELETE FROM SD_INDICADOR_CRED
		WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;
		
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END EXCEPTION;

	--***********************
    --INICIALIZA VARIABLE
    --***********************
	LET V_EXISTE_REG = 0;
    LET P_ERROR      = '00000';
    LET P_MENSAJE    = 'PROCESO EXITOSO';
    LET V_EQ_DIAS    = 0;
    LET V_DIF_INT    = 0;
    LET V_FECHA_FIN_PRORRATEO = NULL;
    LET v_num_credito = "";
    LET i = 0;

    -- ******************
    -- Determina Fechas *
    -- ******************

	SELECT fecha_hoy
	INTO V_FECHA_APERT
	FROM sd_fechas
	WHERE empresa = P_EMPRESA;
	
    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
    SELECT max(fecha) INTO dFechaCierreCred FROM "informix".sd_contproc WHERE empresa = '001' AND proceso = "CierreCred";
    SELECT status_proc INTO cStatusCierreCred FROM "informix".sd_contproc WHERE proceso = "CierreCred" AND fecha = dFechaCierreCred;
    SELECT ind_cierre INTO cIndCierreCheq FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';

    EXECUTE PROCEDURE "informix".sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet2, dFechaHabilAnt;

    IF cIndCierreCheq = '0' OR dFechaCierreCred <> dFechaHabilAnt OR UPPER(cStatusCierreCred) <> 'F' THEN	
		-- 00014, Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde
        SELECT cod_return, mensaje
        INTO P_ERROR, cMenRet
        FROM bdisolic:"informix".ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_14';
        
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
    
	-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    --  Obtiene datos de comisiones de Apertura y Anualidad para calculo del CAT	
	SELECT a.num_producto, a.divisa, b.monto_solicitado, b.sucursal, nvl(a.cobro_comis_apertura,'0'), nvl(a.cod_comision_apertura,''), 
    a.cobro_comision_anual, substr(a.cod_comision_anualidad,1,4), substr(a.cod_comision_anualidad,5,4), a.cat_comi_anual_adicional, b.canal_sol, 
    b.numcte, b.status_solicitud
    INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cCobro_Apertu, cCodComis_Apert, cCobrComisAnual, dClvComAnualTit, dClvComAnualAdi, cCat_adicional, cCanal, 
    vNumCte, cStatuSol
    FROM bdisolic:ss_solicitudes b, sd_definicion a
    WHERE b.empresa = P_EMPRESA
    AND b.num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto;

    -- ******************
    --RQM 09 616
    -- Si tiene un estatus diferente a AT no avanzar
    IF NVL(cStatuSol,'') != 'AT' THEN
		LET P_ERROR = '00001';
        RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
    -- ******************

    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    IF (V_PRODUCTO = '7800') THEN
		SELECT    COUNT(*) INTO cCuentaSolDif
        FROM      bdisolic:"informix".ss_solicitudes
        WHERE     empresa = P_EMPRESA
        AND       numcte = vNumCte
        AND       num_producto = '7800'
        AND       status_solicitud IN ('AT','RT') -- SE ELIMINA EL STATUS AP
        AND       num_solicitud <> P_SOLICITUD;

        IF (cCuentaSolDif > 0 AND cCanal = '8') THEN
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';

			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		ELIF (cCuentaSolDif > 0 AND cCanal <> '8') THEN
			LET P_ERROR = '00412'; -- EL CREDITO YA TIENE UNA SOLICITUD EN TRAMITE
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
        END IF;
		
		-- CAX Mar 2026 se agrega validacion para rechazar la apertura con dia de corte nulo o vacio
		--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
		INTO cCodRet,dFechaT,iDiaPago;
		
		IF (cCodRet <> "000" AND cCanal = '8') THEN
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';
			
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		ELIF (cCodRet <> "000" AND cCanal <> '8') THEN
			LET P_ERROR = '00001';
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		END IF;
		
		IF (dFechaT is null or dFechaT = '') AND cCanal = '8' THEN 
			-- 00015, Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta
			SELECT cod_return, mensaje
			INTO P_ERROR, cMenRet
			FROM bdisolic:"informix".ss_catalogo_mensajes
			WHERE empresa = '001'
			AND cod_msj = 'ADN_15';
			
			RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
		END IF;
	END IF;
    -- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina

	--	SELECT fecha_hoy, fecha_hoy + 12 units month

	let  V_FECHA_VENC=date(0);

    call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;
	 
    -- Valida si se encuentra activa funcionalidad de IFRS		
	SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;
	 
	---AAME RQM 10 679 Se lee si la solicitud es candidato a oro y confirmo que si la quiere en la pantalla de asignacion
	SELECT  confirma_oro	
	INTO iConfirmaOro
	FROM  bdisolic:"informix".ss_solicitudes_tdcoro 
	WHERE numero_solicitud_oro = P_SOLICITUD;
	 
	IF  NVL(iConfirmaOro,0) = 1 THEN --AAME RQM 10 679 Clientes que se les apertura la solicitud de oro
		SELECT valor INTO V_CATIVA
		FROM   "informix".sd_param
		WHERE  cod_param = '093';
	END IF;
	
	-- ****************************
    -- Determina Tasas de Interes *
    -- ****************************
	/*--INTERES ORDINARIO 
    SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.ind_disp_efec
	INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte, vIdTasaFref, vPtosTasaPref, vDispEfec
	FROM sd_definicion a, bdisolic:ss_solicitudes b,
	bdinteg:si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
	WHERE r.empresa = P_EMPRESA
	AND r.tasa = a.cod_tasa_base);
	*/			--	RQM 10 1224
	
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(P_EMPRESA, P_SOLICITUD, '') INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
	IF cCodRetTDif <> '000000' THEN
		LET P_ERROR = cCodRetTDif;
		RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;	
	   
	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.fact_sobret_mora, a.sobretasa_mora, a.ind_disp_efec
	INTO V_FACTOR,           V_SOBRETASA, vDiaCorte,   vIdTasaFref,    vPtosTasaPref,      V_FACTOR_MORA,      V_SOBRETASA_MORA, vDispEfec
	FROM bdicred:sd_definicion a JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND a.empresa = P_EMPRESA AND b.num_solicitud = P_SOLICITUD);
	
	IF v_factor = "+" THEN
		LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
	ELIF v_factor = "-" THEN
		LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
	ELIF v_factor = "*" THEN
		LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
	ELSE
		LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
	END IF
	
	---I---RQM 10 960 TDC GC
	---- VALIDACION PARA CALCULO DE TASA PREFERENCIAL
	IF vIdTasaFref = '1' THEN
	
		SELECT COUNT (*) 
		INTO v_cont
		FROM bdicred:"informix".sd_ctascarg
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
	
		IF v_cont <> 0 THEN
			LET V_TASA_INTERES = V_TASA_INTERES - vPtosTasaPref;
		END IF
		
		IF V_TASA_INTERES < 0 THEN
			LET V_TASA_INTERES = 0;
		END IF

	END IF
	---F---RQM 10 960 TDC GC
	--INTERES MORATORIO
    /*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
    INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
    FROM sd_definicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_mora
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_mora);
	*/													--	RQM 10 1224
    
	IF V_FACTOR_MORA = "+" THEN
		LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
	ELIF V_FACTOR_MORA = "-" THEN
		LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
	ELIF V_FACTOR_MORA = "*" THEN
		LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
	ELSE
		LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
	END IF
    
	--INTERES A FAVOR DEL CLIENTE
    SELECT c.valor, a.factor_sobretasa, a.sobretasa
    INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
    FROM sd_anexodefinicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_base
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_base);

	IF V_FACTOR_FAV = "+" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
	ELIF V_FACTOR_FAV = "-" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
	ELIF V_FACTOR_FAV = "*" THEN
		LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
	ELSE
		LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
	END IF

	--- Genera cuenta Clabe 
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,V_PRODUCTO)
	INTO vcod_ret, cta_Clabe;
	
	--***** ACTUALIZA SD_MAECRED
	INSERT INTO bdicred:sd_maecred
               (EMPRESA                ,NUM_CREDITO
               ,NUM_PRODUCTO           ,EJECUTIVO
               ,NUMCTE                 ,DIVISA
               ,SUCURSAL               ,ID_ORIGEN
               ,ORIGEN                 ,COD_TIPO_LINEA
               ,COD_LINEA              ,PORC_REC_PROP
               ,STATUS_CRED            ,BANDERA_RENOVAC
               ,BANDERA_PRORROGA       ,PERIODO_PLAZO
               ,PLAZO                  ,FECHA_APERTURA
               ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
               ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
               ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
               ,COD_TASA_BASE          ,FACTOR_SOBRETASA
               ,SOBRETASA              ,TASA_INTERES
               ,COD_TASA_MORA          ,SOBRETASA_MORA
               ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
               ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
               ,ES_FISICA              ,BANDERA_FI_FO
               ,CODIGO_PRO             ,SUPERFICIE
               ,ACTIVIDAD              ,CAL_EDOS_FIN
               ,TIPO_CALCULO           ,ADMITE_TLP
               ,REL_GARCRED            ,ID_UNIDAD_PROD
               ,NUM_APER_ANT           ,REV_TASA_VAR_PER
               ,DIA_PARA_REVISAR       ,COD_PROD
               ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
               ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
               ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
               ,CAMPO_TRAB1            ,CAMPO_TRAB2
               ,CAMPO_TRAB3            ,CAMPO_TRAB4
               ,CALIFICACION_RIESGO    ,COD_AGRICOLA
               ,TASA_BASE_PISO         ,SOBRETASA_PISO
               ,FACTOR_PISO            ,TASA_PISO
               ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
               ,FACTOR_TECHO           ,TASA_TECHO
			   ,cuenta_clabe
               )
    SELECT SOL.EMPRESA                ,P_SOLICITUD
               ,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
               ,SOL.NUMCTE                 ,DEF.DIVISA
               ,SOL.SUCURSAL               ,''
               ,''                         ,''
               ,''                         ,100
               --IFRS ,'AA'                       ,'N'
			   ,cStatus_cred               ,'N'
               ,'N'                        ,DEF.PERIODO_PLAZO
               ,0                          ,V_FECHA_APERT
               ,V_FECHA_VENC               ,"3"
               ,"2"                        ,CTR.DIAS_TRAS_CAP
               ,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
               ,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
               ,DEF.SOBRETASA              ,V_TASA_INTERES
               ,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
               ,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA
               ,''                         ,''
               ,TIP.ES_FISICA              ,''
               ,DEF.COD_PROD               ,0
               ,''                         ,''
               ,DEF.TIPO_CALCULO           ,''
               ,0                          ,''
               ,''                         ,DEF.REV_TASA_VAR_PER
               ,DEF.DIA_PARA_REVISAR       ,''
               ,'M'                        ,''
               ,''                         ,0
               ,0                          ,V_FECHA_APERT
               ,0                          ,0
               ,''                         ,CASE WHEN (DEF.NUM_PRODUCTO='8100') THEN '1' ELSE '' END
               ,'A'                        ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
               ,''                         ,''
			   ,cta_Clabe
	FROM   BDISOLIC:SS_SOLICITUDES SOL
    , BDISOLIC:SS_ANEXOSOL    ANX
    , BDINTEG:SI_CLIENTE      CLI
    , BDINTEG:SI_TIPPER       TIP
    , SD_CODTRASP             CTR
    , SD_DEFINICION           DEF
    WHERE  DEF.EMPRESA         = SOL.EMPRESA
    AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
    AND    CTR.PERIOD_PAG_INT  = "2"
    AND    CTR.PERIOD_PAGO_CAP = "3"
    AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
    AND    CTR.EMPRESA         = DEF.EMPRESA
    AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
    AND    CLI.NUMCTE          = SOL.NUMCTE
    AND    CLI.EMPRESA         = SOL.EMPRESA
    AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
    AND    ANX.EMPRESA         = SOL.EMPRESA
    AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
    AND    SOL.EMPRESA         = P_EMPRESA;
    --END;

    --LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
    --IF V_INSERT = 0 THEN
    --LET P_ERROR = '00001';
    --LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACION DEL CREDITO';
    --RETURN P_ERROR, P_MENSAJE,v_num_credito;
    --END IF;

	--***** ACTUALIZA SD_MAESDOS
	INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
								,ACT
                                )
	SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,TODAY                  ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO   ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
								,iAtr_Act_ifrs
	FROM   BDISOLIC:SS_SOLICITUDES SOL
	WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
	AND    SOL.EMPRESA   = P_EMPRESA;

	SELECT USER
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
    INTO VV_FOLIO
    FROM sd_fechas where empresa = '001';

	EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_SOLICITUD,
	                        V_PRODUCTO        , 1,
							"001"             , V_FECHA_APERT,
                            V_MONTO           , VV_FOLIO,
                            VV_SUCURSAL       ,VV_DIVISA,
                            "0000")
	INTO P_ERROR, P_MENSAJE;

    -- *********************************************************
    -- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
    -- *********************************************************
	IF V_PRODUCTO  <> "7800" THEN
		LET vFechaT = MONTH(V_FECHA_APERT) || "/" || vDiaCorte || "/" ||
		    YEAR(V_FECHA_APERT);
		IF DAY(V_FECHA_APERT) > vDiaCorte THEN
			CALL sp_calcula_fecha ("001" ,1 ,"M" ,vFechaT ,"01" ,"01")
			RETURNING P_ERROR, P_MENSAJE, vFechaT;
		END IF

        FOR i = 1 TO 12
			INSERT INTO sd_amortiza_credito values
			(P_EMPRESA,P_SOLICITUD,vFechaT,"3",0,0,0,"1","0","",
            0,0,"1","0","",
            0,0,"1","0","",
            0,0,0,0,0,0,0,"1",
            0,0,"1","",
            i,0,0,"","");

            EXECUTE PROCEDURE sp_calcula_fecha
            (P_EMPRESA ,1 ,"M" ,vFechaT ,"01" ,"01")
            INTO P_ERROR, P_MENSAJE, vFechaT;
        END FOR
	END IF
    
	-- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- **************************************
    UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AP"
	WHERE empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD;

    SELECT nombre INTO vMensaje
    FROM bdinteg:si_ejecut
    WHERE ejecutivo = P_EJECUTIVO
    AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:ss_autorizacion
    (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
    comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
    VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	V_FECHA_APERT, V_FECHA_APERT, USER, TODAY);

    INSERT INTO bdicred:"informix".sd_indicador_cred
	(empresa,num_credito, fecha_alta)
    VALUES(P_EMPRESA,P_SOLICITUD,V_FECHA_APERT );
    
	-- ******************************
    -- Actualiza Datos del Cliente  *
    -- ******************************

    SELECT tipo_cliente, NVL(ingreso_mensual,0)
    INTO vTpCte, vIngreso
    FROM bdinteg:si_cliente a, bdisolic:ss_solicitudes b,
	bdisolic:ss_resum_scor_fin c
    WHERE a.numcte = b.numcte
    AND b.empresa = P_EMPRESA
    AND b.num_solicitud = P_SOLICITUD
    AND c.empresa = b.empresa
    AND c.num_solicitud = b.num_solicitud;

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO V_MERCADEO 
    FROM   bdinteg:si_ctepf 
    WHERE  numcte = vNumCte;
       
	IF  V_PRODUCTO   =  "7800" THEN
		--Se actualiza la solicitud de credito ligada a la cuenta y movil	
		SELECT  movil_cuenta ,frecuencia_pgo
		INTO cTelCel ,iFrecuencia
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta		
		WHERE numcte = vNumCte
		AND num_solicitud  = P_SOLICITUD;
		
		--se obtiene la fecha de la proxima cuota.
		--EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
		--INTO cCodRet,dFechaT,iDiaPago;

		INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		dia_corte,             dias_gracia_mora,
		tp_dias_calc_mora,     dias_fecha_max_pago,
		tp_dias_fecha_pago,    cod_tasa_base_cte,
		factor_sobretasa_cte,  sobretasa_cte,
		tasa_interes_cte,      fecha_proceso,prox_fecha_pago )
		SELECT P_EMPRESA,               P_SOLICITUD,
	    DAY(dFechaT),           def.gracia_calc_mora,
	    def.pago_adic_sig_cuo,   def.tipo_cliente,
	    iFrecuencia,        def.cod_tasa_base,
	    def.factor_sobretasa,    def.sobretasa,
	    V_TASA_FAVOR,            V_FECHA_APERT ,dFechaT
		FROM sd_definicion def, sd_anexodefinicion b,
	    bdisolic:ss_solicitudes c
		WHERE c.empresa = P_EMPRESA
		AND c.num_solicitud = P_SOLICITUD
		AND def.empresa = c.empresa
		AND def.num_producto = c.num_producto
		AND b.empresa = def.empresa
		AND b.num_producto = c.num_producto
		AND b.cod_prod = def.cod_tipcred;

		-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
		/*INSERT INTO "informix".sd_amortiza_credito
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
		VALUES
		(
			P_EMPRESA,			P_SOLICITUD,
			dFechaT,			"3",
			0,					0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);*/

	ELSE
		INSERT INTO sd_maecredanexo
		(empresa,               num_credito,
		dia_corte,             dias_gracia_mora,
		tp_dias_calc_mora,     dias_fecha_max_pago,
		tp_dias_fecha_pago,    cod_tasa_base_cte,
		factor_sobretasa_cte,  sobretasa_cte,
		tasa_interes_cte,      fecha_proceso )
		SELECT P_EMPRESA,               P_SOLICITUD,
	    def.dia_cuota,           def.gracia_calc_mora,
	    def.pago_adic_sig_cuo,   def.tipo_cliente,
	    def.maneja_linea,        def.cod_tasa_base,
	    def.factor_sobretasa,    def.sobretasa,
	    V_TASA_FAVOR,            V_FECHA_APERT
		FROM sd_definicion def, sd_anexodefinicion b,
	    bdisolic:ss_solicitudes c
		WHERE c.empresa = P_EMPRESA
		AND c.num_solicitud = P_SOLICITUD
		AND def.empresa = c.empresa
		AND def.num_producto = c.num_producto
		AND b.empresa = def.empresa
		AND b.num_producto = c.num_producto
		AND b.cod_prod = def.cod_tipcred;
	END IF
	
    IF vTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO iSecIngreso FROM bdinteg:si_ingresos WHERE empresa = P_EMPRESA
		AND numcte = vNumCte AND tipo_ingreso = 'T';
		
		UPDATE bdinteg:si_ingresos
		SET ingreso_mensual = vIngreso
		WHERE empresa = P_EMPRESA
		AND numcte = vNumCte
		AND tipo_ingreso = "T"
		AND sec_ingreso = iSecIngreso;
    ELSE
		UPDATE bdinteg:si_cliente
		SET tipo_cliente = "1"
		WHERE numcte = vNumCte;
		
		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO iSecIngreso
		FROM bdinteg:si_ingresos 
		WHERE empresa = P_EMPRESA 
		AND numcte = vNumCte 
		AND tipo_ingreso = "T";

		INSERT INTO bdinteg:si_ingresos
		(empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES
		(P_EMPRESA, vNumCte, iSecIngreso, "T", vIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;
    IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET V_TASA_MORA = V_TASA_MORA * -1;
    END IF
	
	IF V_PRODUCTO  = "7800" THEN
        IF cCanal IN ('1','3','5') THEN
            --Mandar el registra evento para el envio de mensajes
            --insertar en la tabla para enviar sms	 Â¡Felicidades! Tu Anticipo de Nomina ha sido autorizado, puedes disponer de hasta $#,### cuando lo necesites.	
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_1' , '000000000','', '','1', V_MONTO, '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
            --insertar en la tabla para enviar sms	Solicita tu Anticipo de Nomina enviando un SMS al ###### con la palabra Anticipo + monto que deseas sin signo de pesos?	
            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_2' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	
        END IF;
    ELSE
		LET dPagoReq = V_MONTO * (V_TASA_INTERES /100) / 360 * 30;
        IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura.
            SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
            LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
        END IF;
		-- AAME 16072019 INI Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
        IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
			SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
			SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
			LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
			LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);	
			
            IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
            LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
		ELSE
			LET mMntoComAnual = 0;
		END IF;  				
		-- Para 6001 solo cobra apertura, para <> 6001 no cobra apertura, cobra anualidad
		LET dComisiones = dComisiones + mMntoComApert;		
        --LET dComisiones = NVL(mMntoComApert,0) + NVL(mMntoComAnual,0);

		--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36,50) 
        --EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36, dComisiones) 
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, V_TASA_INTERES) 
		into cCodRet,cMensajeRet,vCatFinal;
		IF cCodRet::INTEGER =0 AND  vCatFinal <> 0 THEN
			LET V_CATIVA = vCatFinal;
		END IF;
		-- AAME 16072019 FIN Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253	
		UPDATE bdisolic:ss_revision_determinacion SET cat = V_CATIVA 	WHERE empresa = P_EMPRESA 	AND num_solicitud = P_SOLICITUD;
	END IF;
	
	--***** ACTUALIZA SD_BITACORA_DISPEFEC RQM 10 1225
	IF vDispEfec  = '1' THEN
		SELECT b.grupo,b.evalua_cc  
		INTO  gpo,evalcc
		FROM  bdisolic:ss_revision_determinacion b 
		WHERE b.EMPRESA = P_EMPRESA
		AND   b.num_solicitud = P_SOLICITUD;
		
		IF gpo = '1' AND evalcc IN ('0','X')  THEN --A+ -> HIT / NO HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND evalcc IN ('0')  THEN -- NO A+ -> HIT
		   LET v_idi = '2';
		ELIF gpo <> '1' AND nvl(evalcc,'X') = 'X' THEN-- NO A+ -> NO HIT
		   LET v_idi = '1';
		ELSE 
		   LET v_idi = '0';
		END IF;
		
		--INSERCION EN TABLA BITACORA DISPOSICION EN EFECTIVO
		INSERT INTO bdicred:sd_bitacora_dispefec
			(EMPRESA                ,NUM_CREDITO
			,FECHA_STATUS           ,IND_DISP_INI
			,IND_DISP_ACT           ,GRUPO
			,EVALUA_CC              ,FECHA_INSERT)
		VALUES(P_EMPRESA,P_SOLICITUD,null,v_idi,null,gpo,evalcc,TODAY);
			 
		--SE ACTUALIZA TABLA SD_MAECRED CON EL VALOR DEL PERIODO_POR_EVALUAR REUSANDO EL CAMPO DIFERIMIENTO_INT
		LET v_indde = v_idi::INTEGER;
		UPDATE bdicred:"informix".sd_maecred SET diferimiento_int = v_indde
		WHERE empresa = P_EMPRESA AND num_credito = p_solicitud;
        		
	END IF;
    ---------------------------- 
    RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
END;
END PROCEDURE;