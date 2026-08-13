CREATE PROCEDURE "informix".ugenera_layoutedocuentacrdpp_mx(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql       CHAR(5000);
DEFINE v_sql1      CHAR(1000);
DEFINE v_sql2      CHAR(1000);
DEFINE v_sql3      CHAR(1000);
DEFINE v_sql4      CHAR(1000);
DEFINE v_sql5      CHAR(1000);
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

SET DEBUG FILE TO "/tmp/trace_ugenera_layoutedocuentacrd.txt";
TRACE ON;

-- Autor: Leonardo HernÃÂÃÂ¡ndez Moreno
-- Fecha: 2009/07/24
-- ModificaciÃÂÃÂ³n: Se realiza modificaciÃÂÃÂ³n para obtener
--               la ruta donde se almacenarÃÂÃÂ¡n los archivos
--               generados para crÃÂÃÂ©ditos reestructurados
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

	--AAME 20150430 RQM 10 550 Se modifica query para contemplar los nuevos numeros de prestamo personal(7600,7700) y se contemplen encabezados para estos prestamos al archivo descarga 
	-----------------SE INSERTA EL ENCABEZADO UNO---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_cta_efec, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_numero, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				  ' replace ( replace ( replace( nombre_producto, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' )'||
                  ' FROM sd_encabezado_edoctacrd ';
     LET v_sql5=  ' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y')|| ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y')|| 
                  ''' AND num_credito = ''6300100'' and num_producto in(''6300'',''7600'',''7700'',''6800'') order by fecha_emision,num_credito" > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	 SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " || trim(v_ruta||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	--AAME 20150430 RQM 10 550 Se modifica query para contemplar los nuevos numeros de prestamo personal(7600,7700) y se con su respectivos encabezados estos prestamos al archivo descarga 
	-----------------SE INSERTAN LOS CREDITOS DEL ENCABEZADO UNO---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_cta_efec, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_numero, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				  ' replace ( replace ( replace( nombre_producto, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' )'||
                  ' FROM sd_encabezado_edoctacrd ';
     LET v_sql5=  ' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y') || ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y')
                    ||''' AND num_credito <> ''6300100'' AND num_producto in(''6300'',''7600'',''7700'',''6800'') order by fecha_emision,num_credito" > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	 SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> " || trim(v_ruta||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
     SYSTEM v_sql;

     LET v_sql = '';
	 LET v_sql = " compress " || v_ruta||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	 
------------------------------------------------------------------------------------------------------------------------------------------------	 
	 --- ARCHIVO 100 DE CFDI con la atenciÃÂÃÂ³n del RQI 12 379 InclusiÃÂÃÂ³n de Correo ElectrÃÂÃÂ³nico en Archivos de TDC PIQV
	 
	  LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaB.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_cta_efec, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_numero, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), '||
				  ' nvl ((SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
				  ' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
                  ' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' '||
				  ' AND b.numcte not in (select c.numcte from bdinteg:"informix".si_altaserv_edoctamov c where c.empresa = ''001'' and c.numcte = b.numcte)),'' '') ,'||
				  ' nvl ( replace ( replace( confirmacion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )';
     LET v_sql5=  ' FROM sd_encabezado_edoctacrd a '|| 
				  ' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y') || ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y') 
                    ||''' AND num_credito <> ''6300100'' AND num_producto in(''6300'',''7600'',''7700'',''6800'') order by fecha_emision,num_credito" > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
	 SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaB.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

	 LET v_sql = '';
	 LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
                  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||             
                                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2B.unl'||
                              '" >>'||'eliminaespeciales.sh ';
                  SYSTEM v_sql;


                  LET v_sql = '';
                  LET v_sql = "./"||'eliminaespeciales.sh ';
                  SYSTEM v_sql;
	 
     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2B.unl'||" >> " || trim(v_ruta||'Archivo63100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
     SYSTEM v_sql;


     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descargaB.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga2B.unl';
     SYSTEM v_sql;
	 
	 
     --- ARCHIVO 100 DE CFDI con la atenciÃÂÃÂ³n del RQI 12 379 InclusiÃÂÃÂ³n de Correo ElectrÃÂÃÂ³nico en Archivos de TDC PIQV

	-----------------SE INSERTAN EL CABECERO DEL ENCABEZADO DOS---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( capital_tc,0),'||
                  ' nvl ( interes_tc,0),'||
                  ' nvl ( iva_interes_tc,0),'||
                  ' nvl ( replace ( replace( numero_pago_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( monto_pago,0),'||
                  ' nvl ( capital_ven_tc,0),'||
                  ' nvl ( interes_ven_tc,0),'||
	              ' nvl ( iva_interes_ven_tc,0),'||
                  ' nvl ( moratorios_tc,0),'||
                  ' nvl ( iva_moratorios_tc,0),'||
                  ' nvl ( pago_total_tc,0),'||
                  ' nvl ( fecha_limite_tc,date(1)),'||
                  ' nvl ( periodo_tc_ini,date(1)),'||
                  ' nvl ( periodo_tc_fin,date(1)),'||
                  ' nvl ( fecha_corte_tc,date(1)),'||
                  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( monto_credito_tc,0),'||
                  ' nvl ( fecha_otorgamiento_tc,date(1)), ';
     LET v_sql3 = ' nvl ( comisiones_efec_cargadas,0),'||
                  ' nvl ( intereses_efec_pag,0)'||
                  ' FROM sd_encabezado2_edoctacrd WHERE fecha_emision >'''||pperiodo1|| ''' AND fecha_emision <= '''||pperiodo2|| 
                   ''' and num_credito =''6300200'' ORDER BY fecha_emision,num_credito"'||
            	  ' > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> " ||v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

-----------------SE INSERTAN CREDITOS DEL ENCABEZADO DOS-------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)),'||
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
     LET v_sql3 = ' nvl ( a.comisiones_efec_cargadas,0),'||
                  ' nvl ( a.intereses_efec_pag,0) '||
                  ' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2||
                  ''' and a.fecha_emision = b.fecha_emision and a.num_credito <> ''6300200'' and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'') ORDER BY a.fecha_emision,a.num_credito"'||	  
            	  ' > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga_ab.unl';
     LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( a.capital_tc,0),'||
                  ' nvl ( a.interes_tc,0),'||
                  ' nvl ( a.iva_interes_tc,0),'||
                  ' nvl ( replace ( replace( a.numero_pago_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( a.monto_pago,0),'||
                  ' nvl ( a.capital_ven_tc,0),'||
                  ' nvl ( a.interes_ven_tc,0),'||
	              ' nvl ( a.iva_interes_ven_tc,0),'||
                  ' nvl ( a.comisiones,0),'||
                  ' nvl ( a.iva_comisiones,0),'||
                  ' nvl ( a.pago_total_tc,0),'||
                  ' nvl ( a.fecha_limite_tc,date(1)),'||
                  ' nvl ( a.periodo_tc_ini,date(1)),'||
                  ' nvl ( a.periodo_tc_fin,date(1)),'||
                  ' nvl ( a.fecha_corte_tc,date(1)),'||
                  ' nvl ( replace ( replace( a.dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( a.monto_credito_tc,0),'||
                  ' nvl ( a.fecha_otorgamiento_tc,date(1)),';
     LET v_sql3 = ' nvl ( a.comisiones_efec_cargadas,0),'||
                  ' nvl ( a.intereses_efec_pag,0) '||
                  ' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2||
                  ''' and a.fecha_emision = b.fecha_emision and a.num_credito <> ''6300200'' and a.num_credito = b.num_credito and b.num_producto =''6800'' ORDER BY a.fecha_emision,a.num_credito"'||	  
            	  ' > query2.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query2.sql";
	 SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

	 LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga_ab.unl'||" >"||v_ruta||'descarga_ab1.unl';
     SYSTEM v_sql;
 
     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga_ab.unl';
     SYSTEM v_sql;	 
	 
	 LET v_sql = '';
     LET v_sql = "cat "||v_ruta||'descarga1.unl'||" " ||v_ruta||'descarga_ab1.unl'||" > " ||v_ruta||'descarga1u.unl';
     SYSTEM v_sql;	 
	 
     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1u.unl'||" >> " ||v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
	 LET v_sql = " compress " || v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga_ab1.unl';
     SYSTEM v_sql;

	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1u.unl';
     SYSTEM v_sql;
	 
	----------------------------------------------------------------------------------------------------------------------------------------
	------------ CFDI 3.3 Se agrega campo "descuento" para el Archivo 200 de acuerdo al RQI 12 297 ----
		-----------------SE INSERTAN EL CABECERO DEL ENCABEZADO DOS CFDI 3.3 ---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( capital_tc,0),'||
                  ' nvl ( interes_tc,0),'||
                  ' nvl ( iva_interes_tc,0),'||
                  ' nvl ( replace ( replace( numero_pago_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( monto_pago,0),'||
                  ' nvl ( capital_ven_tc,0),'||
                  ' nvl ( interes_ven_tc,0),'||
	              ' nvl ( iva_interes_ven_tc,0),'||
                  ' nvl ( moratorios_tc,0),'||
                  ' nvl ( iva_moratorios_tc,0),'||
                  ' nvl ( pago_total_tc,0),'||
                  ' nvl ( fecha_limite_tc,date(1)),'||
                  ' nvl ( periodo_tc_ini,date(1)),'||
                  ' nvl ( periodo_tc_fin,date(1)),'||
                  ' nvl ( fecha_corte_tc,date(1)),'||
                  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( monto_credito_tc,0),'||
                  ' nvl ( fecha_otorgamiento_tc,date(1)), ';
     LET v_sql3 = ' nvl ( comisiones_efec_cargadas,0),'||
                  ' nvl ( intereses_efec_pag,0),'||
				  ' nvl ( descuento,0), '||
				  ' nvl ( subtotal,0), '||
				  ' nvl ( total,0) '||
                  ' FROM sd_encabezado2_edoctacrd WHERE fecha_emision >'''||pperiodo1|| ''' AND fecha_emision <= '''||pperiodo2|| 
                   ''' and num_credito =''6300200'' ORDER BY fecha_emision,num_credito"'||
            	  ' > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> " ||v_ruta||'Archivo63200B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	
-----------------SE INSERTAN CREDITOS DEL ENCABEZADO DOS CFDI 3.3 -------------------------------	
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)),'||
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
     LET v_sql3 = ' nvl ( a.comisiones_efec_cargadas,0),'||
                  ' nvl ( a.intereses_efec_pag,0),'||
				  ' nvl ( a.descuento,0), '||
				  ' nvl ( a.subtotal,0), '||
				  ' nvl ( a.total,0) '||
                  ' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
                  ''' and a.fecha_emision = b.fecha_emision and a.num_credito <> ''6300200'' and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'') ORDER BY a.fecha_emision,a.num_credito"'||		  
            	  ' > query.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga_ab.unl';
     LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( a.capital_tc,0),'||
                  ' nvl ( a.interes_tc,0),'||
                  ' nvl ( a.iva_interes_tc,0),'||
                  ' nvl ( replace ( replace( a.numero_pago_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( a.monto_pago,0),'||
                  ' nvl ( a.capital_ven_tc,0),'||
                  ' nvl ( a.interes_ven_tc,0),'||
	              ' nvl ( a.iva_interes_ven_tc,0),'||
                  ' nvl ( a.comisiones,0),'||
                  ' nvl ( a.iva_comisiones,0),'||
                  ' nvl ( a.pago_total_tc,0),'||
                  ' nvl ( a.fecha_limite_tc,date(1)),'||
                  ' nvl ( a.periodo_tc_ini,date(1)),'||
                  ' nvl ( a.periodo_tc_fin,date(1)),'||
                  ' nvl ( a.fecha_corte_tc,date(1)),'||
                  ' nvl ( replace ( replace( a.dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( a.monto_credito_tc,0),'||
                  ' nvl ( a.fecha_otorgamiento_tc,date(1)),';
     LET v_sql3 = ' nvl ( a.comisiones_efec_cargadas,0),'||
                  ' nvl ( a.intereses_efec_pag,0),'||
				  ' nvl ( a.descuento,0), '||
				  ' nvl ( a.subtotal,0), '||
				  ' nvl ( a.total,0) '||
                  ' FROM sd_encabezado2_edoctacrd a, sd_encabezado_edoctacrd b WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
                  ''' and a.fecha_emision = b.fecha_emision and a.num_credito <> ''6300200'' and a.num_credito = b.num_credito and b.num_producto =''6800'' ORDER BY a.fecha_emision,a.num_credito"'||		  
            	  ' > query2.sql';
	 LET v_sql = v_sql1||v_sql2||v_sql3;
     SYSTEM v_sql;
	 
     LET v_sql = "dbaccess bdicred query2.sql";
	 SYSTEM v_sql;
	 	 
     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

	 LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga_ab.unl'||" >"||v_ruta||'descarga_ab1.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga_ab.unl';
     SYSTEM v_sql;
	 
	 LET v_sql = '';
     LET v_sql = "cat "||v_ruta||'descarga1.unl'||" " ||v_ruta||'descarga_ab1.unl'||" > " ||v_ruta||'descarga1u.unl';
     SYSTEM v_sql;	 


     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1u.unl'||" >> " ||v_ruta||'Archivo63200B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
		
     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga_ab1.unl';
     SYSTEM v_sql;
		
	 LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1u.unl';
     SYSTEM v_sql;	
	--- FIN RQI 12 297 ----
	----------------------------------------------------------------------------------------------------------------------------------------
	 
	-----------------SE INSERTA CABECERO DEL DETALLE ---------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( fecha_mov,date(1)),'||
            ' nvl ( concepto,0),'||
            ' nvl ( cargos,0),'||
            ' nvl ( abonos,0)'||
            ' FROM sd_detalle_edoctacrd '||
            ' WHERE fecha_emision >'''||pperiodo1|| ''' AND fecha_emision <= '''||pperiodo2|| 
            ''' and num_credito =''6300300'' "'||               
            ' > query.sql';
	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

    
	-----------------SE INSERTAN LOS CREDITOS DEL DEL DETALLE ---------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( a.fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( a.secuencia,0),'||
            ' nvl ( a.nlinea,0),'||
            ' nvl ( a.fecha_mov,date(1)),'||
            ' nvl ( a.concepto,0),'||
            ' nvl ( a.cargos,0),'||
            ' nvl ( a.abonos,0)'||
            ' FROM sd_detalle_edoctacrd a, sd_encabezado_edoctacrd b '||
            ' WHERE a.fecha_emision >'''||pperiodo1
            || ''' AND a.fecha_emision <= '''||pperiodo2 
            ||''' and a.fecha_emision = b.fecha_emision  and a.num_credito <> ''6300300'' and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'',''6800'') ORDER BY a.fecha_emision,a.num_credito,a.secuencia,nlinea"'||
            ' > querys.sql';
	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred querys.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> " ||v_ruta||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

    LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;




	-----------------ACLARACIONES---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( fecha_aclara,date(1)),'||
            ' nvl ( replace ( replace( folio_suc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( fecha_mov,date(1)),'||
            ' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( importe,0) FROM sd_aclaraciones_edoctacrd '||
            ' WHERE fecha_emision >'''||pperiodo1||
            ''' AND fecha_emision <= '''||pperiodo2|| ''' and num_credito = ''6300400'' "'||
            ' > query.sql';
	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

    LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;



	-----------------SE INSERTA EL ENCABEZADO DEL MENSAJE ---------------------------------------------

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( si_paga,0),'||
            ' nvl ( replace ( replace( mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd '||
            ' WHERE fecha_emision >'''||pperiodo1|| ''' AND fecha_emision <= '''||pperiodo2|| 
            ''' AND num_credito =  ''6300500'' ORDER BY fecha_emision,num_credito,secuencia,nlinea"'||
            ' > query.sql';

	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";

	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;


	-----------------SE INSERTAN LOS MENSAJES DE LOS CREDITOS 500 CARTERAS---------------------------------------------

	--AAME 20150430 RQM 10 550 Se contemplaran los mismos mensajes que se muestran para el 6300
    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga_5.unl';
    LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' nvl ( b.secuencia,0),'||
        ' nvl ( b.nlinea,0),'||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        ' nvl ( replace ( replace( b.mensaje, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd a ';
     LET v_sql3 =   ' LEFT OUTER JOIN bdicred:sd_mensajes_mensual_edoctacrd b on a.fecha_emision = b.fecha_emision'||
        ' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
        ''' AND a.secuencia = 1 AND a.nlinea = 1 and num_credito not in(''6300500'',''7600500'',''7700500'',''6800500'') and a.num_producto in(''6300'',''7600'',''7700'',''6800'') '||
		' AND a.num_producto = b.num_producto'||
        ' UNION ALL ';
      LET v_sql4 =  ' SELECT fecha_emision, num_credito, secuencia, nlinea, NVL(si_paga,'' ''), mensajes FROM bdicred:sd_mensajes_edoctacrd a'||
        ' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
        '''  and num_credito not in(''6300500'',''7600500'',''7700500'',''6800500'') and a.num_producto in(''6300'',''7600'',''7700'',''6800'') ORDER BY 2,3,4"'||
		' > query_5.sql';

	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query_5.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga_5.unl'||" >"||v_ruta||'descarga1A.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga_5.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1A.unl'||" >> "||v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

    LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

    LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'descarga1A.unl';
    SYSTEM v_sql;
	
	 -----------------SE INSERTA EL ENCABEZADO DEL MENSAJE 500B CFDI ---------------------------------------------

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( si_paga,0),'||
            ' nvl ( replace ( replace( mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd '||
            ' WHERE fecha_emision >'''||pperiodo1|| ''' AND fecha_emision <= '''||pperiodo2|| 
            ''' AND num_credito =  ''6300500'' ORDER BY fecha_emision,num_credito,secuencia,nlinea"'||
            ' > query.sql';

	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";

	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;
	 -----------------SE INSERTAN LOS MENSAJES DE LOS CREDITOS 500B CFDI---------------------------------------------

	--GJEV RQM 10 619
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' (clave + 1 -200)::integer,'||
        ' ''1'','||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        ' nvl ( replace ( replace( b.mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd a '||
		' left join   bdicred:sd_config_mensaje_edocta b on b.num_producto = a.num_producto '||
		' where a.num_credito =a.num_credito and a.secuencia= ''1'' '||
		' and a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| ''' '||
        ' and a.num_credito not in(''6300500'',''7600500'',''7700500'',''6800500'')  and a.num_producto in(''6300'',''7600'',''7700'',''6800'')'||
		' order by a.num_credito,b.clave "'||
		' > query5_B.sql';

	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query5_B.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1z.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1z.unl'||" >> "||v_ruta||'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

   /* LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;*/

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1z.unl';
     SYSTEM v_sql;


	-----------------ENCABEZADO DE PIE DE PAGINA---------------------------------------------------

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( a.tasa_anual,0),'||
            ' nvl ( a.tasa_mensual,0),'||
            ' nvl ( a.tasa_mora_anual,0),'||
            ' nvl ( a.tasa_mora_mensual,0),'||
            ' nvl ( round(a.cat,1),0),'||
            ' nvl ( a.saldo_insoluto,0 ) FROM sd_pie_edoctacrd a'||
            ' WHERE a.fecha_emision > '''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
            ''' and a.num_credito = ''6300600'' ORDER BY a.fecha_emision"'||
            ' > query.sql';
	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;


	-----------------DATOS DEL PIE DE PAGINA---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( a.tasa_anual,0),'||
            ' nvl ( a.tasa_mensual,0),'||
            ' nvl ( a.tasa_mora_anual,0),'||
            ' nvl ( a.tasa_mora_mensual,0),'||
            ' nvl ( round(a.cat,1),0),'||
            ' nvl ( a.saldo_insoluto,0 ) FROM sd_pie_edoctacrd a, sd_encabezado_edoctacrd b'||
            ' WHERE a.fecha_emision > '''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
            ''' and a.fecha_emision = b.fecha_emision and a.num_credito = b.num_credito and b.num_producto in(''6300'',''7600'',''7700'',''6800'') ORDER BY a.fecha_emision"'||
            ' > query.sql';
	 LET v_sql = v_sql1||v_sql2;
     SYSTEM v_sql;

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> " ||v_ruta||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

    LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

/*
     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'querys.sql';
     SYSTEM v_sql;


     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'query.sql';
     SYSTEM v_sql;
*/
---------  COPIA ARCHIVOS CREADOS A LA DE CFD -------------------

		  --LET v_sql = '';
		  --LET v_sql = "cp " || v_ruta|| 'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   --trim(v_ruta_cfd) ||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  --SYSTEM v_sql;

		  --LET v_sql = '';
		  --LET v_sql = "cp " || v_ruta|| 'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   --trim(v_ruta_cfd) ||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  --SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "mv " || v_ruta|| 'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
							   trim(v_ruta_cfd) ||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "mv " || v_ruta|| 'Archivo63100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
							   trim(v_ruta_cfd) ||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "mv " || v_ruta|| 'Archivo63200B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
							   trim(v_ruta_cfd) ||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;
		  
		  --COMPRIMIR YA QUE AL PASAR SE PASA SIN COMPRIMIR PARA DEJAR EL MISMO NOMBRE
		  LET v_sql = '';
		  LET v_sql = " compress " || trim(v_ruta_cfd)||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = " compress " || trim(v_ruta_cfd)||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = " compress " || trim(v_ruta_cfd)||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;
		  

	  --FIN DE COPIAR A LA RUTA DE CFD.


  END;
  RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Se realiza procedimiento para generar los archivos',
'de cada una de las tablas que componen el estado de',
'cuenta para crÃÂÃÂ©ditos reestructurados',
'AUTOR : Bernardo Baez',
'FECHA : 23/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carga_clientes_camp_mx() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCod_Ret CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cDatosCtesCamp CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vejecutivo CHAR (9);
DEFINE vconsec SMALLINT;
DEFINE vtarjeta CHAR (20);
DEFINE vplazo SMALLINT;
DEFINE vtasa SMALLINT;
DEFINE vmonto_actual DECIMAL(18,2);
DEFINE vnombrepromo CHAR(50);
DEFINE vnum_cte CHAR (20);
DEFINE vnum_promo INTEGER;
DEFINE vtipo_tar CHAR (3);
DEFINE vnombre CHAR (106);
DEFINE vnombre_emb CHAR (21);
DEFINE vnum_prod CHAR (4);
DEFINE cmiembro CHAR (2);
DEFINE dtCampAct DATETIME YEAR TO SECOND;
DEFINE dtCampIni DATETIME YEAR TO SECOND;
DEFINE dtCampFin DATETIME YEAR TO SECOND;
DEFINE dFechaIniCred DATETIME YEAR TO SECOND;
DEFINE vsucursal CHAR(4);
DEFINE vfolio_movto CHAR(16);
DEFINE vfolio_suc CHAR(16);
    

DEFINE wBegin                CHAR(1);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);
DEFINE dtFechaHoy			DATE;

-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_consulta_proyecta_credisol
DEFINE c_CodigoRet_pp           CHAR(6);
DEFINE i_Periodo_pp             INTEGER;
DEFINE d_FechaCouta_pp          DATE;
DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
DEFINE dd_Mensualidad_aux_pp    DECIMAL(18,2);
DEFINE dd_Intereses_pp          DECIMAL(18,2);
DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
DEFINE dd_Capital_pp            DECIMAL(18,2);
DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
DEFINE s_DiasPeriodo_pp         SMALLINT;
DEFINE d_FechaAper_pp           DATE;
DEFINE c_NumMesesPago_pp        CHAR(3);
DEFINE i_Cont                   SMALLINT;
DEFINE cMensajeRet 				CHAR(50);
DEFINE dPagoMensual				DECIMAL(18,2);
DEFINE dInterIvaPlazoMax		DECIMAL(18,2);
DEFINE dPagoPorPlazo			DECIMAL(18,2);
DEFINE dTotalPagar				DECIMAL(18,2);
DEFINE cCodRetGF				CHAR(6);
DEFINE cFolioSucGF				CHAR(16);
DEFINE iDatosCorrectos			INTEGER; -- JHQS 20190628 INC 27 127
DEFINE iExiste					INTEGER; -- JHQS 20190628 INC 27 127

LET iSqlErr 					= 0;
LET cCodRet 					= '000001';
LET cCod_Ret 					= '000000';
LET cCadena 					= '';
LET cRuta 						= '';
LET cDatosCtesCamp 				= '';
LET cBitCamp 					= '';
LET vnum_cred 					= '';
LET vejecutivo 					= '';
LET vconsec 					= 0;
LET vtarjeta 					= '';
LET vplazo 						= 0;
LET vtasa 						= 0;
LET vmonto_actual 				= 0.00;
LET vnombrepromo  				='';
LET vnum_cte 					= '';
LET vnum_promo 					= 0;
LET vtipo_tar 					= '';
LET vnombre 					= '';
LET vnombre_emb 				= '';
LET vnum_prod 					= '';
LET cmiembro 					= '';
LET wBegin 						= '';
LET dtCampAct 					= CURRENT;
LET cArchivo_dbld    			= "f_datosctes.com";
LET cArchivo_log     			= "f_datosctes.log";
LET vsucursal 					= '';
LET vfolio_movto 				= '';
LET vfolio_suc 					= '';

-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_consulta_proyecta_credisol
LET c_CodigoRet_pp              = '';
LET i_Periodo_pp                = 0;
LET d_FechaCouta_pp             = MDY(1,1,1900);
LET dd_SaldoInicial_pp          = 0.0;
LET dd_Mensualidad_pp           = 0.0;
LET dd_Mensualidad_aux_pp       = 0.0;
LET dd_Intereses_pp             = 0.0;
LET dd_IvaInteres_pp            = 0.0;
LET dd_Capital_pp               = 0.0;
LET dd_SaldoFinal_pp            = 0.0;
LET dd_SaldoFinal_aux_pp        = 0.0;
LET s_DiasPeriodo_pp            = 0;
LET d_FechaAper_pp              = MDY(1,1,1900);
LET c_NumMesesPago_pp           = '';
LET i_Cont                      = 0;
LET dtFechaHoy					= DATE(1);
LET cMensajeRet 				= '';
LET dPagoMensual				= 0.0;
LET dInterIvaPlazoMax			= 0.0;
LET dPagoPorPlazo				= 0.0;
LET dTotalPagar					= 0.0;
LET cCodRetGF					= '000000';
LET cFolioSucGF					= '';
LET iDatosCorrectos 			= 0; -- JHQS 20190628 INC 27 127
LET iExiste						= 0; -- JHQS 20190628 INC 27 127

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

  SET DEBUG FILE TO '/tmp/sp_carga_clientes_camp.out';
  TRACE ON;

    LET cDatosCtesCamp="clientescamp";
    LET cBitCamp="bitacoractescamp";
    LET cRuta="/resplogifx/archivoscredito/";  
    --LET cPromocionCred="promocioncredito";
	--LET cBitPromo="bitacorapromocred";
    --LET cRuta="/informix/resplogifx/archivoscredito/";                                              
 
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy INTO dtFechaHoy
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	IF NVL(cRuta,'') <> '' THEN
		IF NVL(cDatosCtesCamp,'') <> '' THEN
			LET dtCampAct = CURRENT;
		--	LET cDatosCtesCamp = TRIM(cDatosCtesCamp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.txt';      
			LET cDatosCtesCamp = TRIM(cDatosCtesCamp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.unl';                
			LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.txt'; 

			TRUNCATE TABLE "informix".sd_credpaso;
						   
		   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosCtesCamp) ||' DELIMITER '|| "'" || '|' || "'" || ' 14;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
		   system ' echo "INSERT INTO sd_credpaso;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
		   system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

		   system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datosctes.sh';
		   system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datosctes.sh'; 
		   system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';
		   system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';             
		   system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';          
		   system ' echo "update statistics medium for table sd_credpaso; ' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';           
		   system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datosctes.sh';           
		   system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datosctes.sh';
		   system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datosctes.sh';  

		   -- AAME 20190822 INC 27 131 Se valida si no encontro el archivo ó no fue posible cargarlo
			SELECT COUNT(*) INTO iExiste
			  FROM sd_credpaso;	   
			
			IF iExiste > 0 THEN			
				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002'; 
				LET cCadena = '';
				LET cCadena = '/usr/bin/echo " EL ARCHIVO SE ENCUENTRA VACÍO, CON ERROR DE ESTRUCTURA Ó INEXISTENTE " > ' || TRIM(cRuta) || TRIM(cBitCamp);
				SYSTEM cCadena;						
			END IF;
		END IF;
		
					
		IF cCodRet = '000000' THEN 

			--DELETE FROM "informix".sd_credpaso a
			--WHERE a.num_credito IN(SELECT num_credito FROM "informix".sd_maecred WHERE num_cte <>a.num_cte);
			
			FOREACH WITH HOLD
				SELECT num_credito, num_cte , num_promo , ejecutivo , num_tarjeta, plazo , tasa , monto_actual , nombre_promo, sucursal , folio_movto
				  INTO vnum_cred  , vnum_cte, vnum_promo, vejecutivo, vtarjeta   , vplazo, vtasa, vmonto_actual, vnombrepromo, vsucursal, vfolio_movto
				  FROM sd_credpaso
				 WHERE activo = 1
				
				-- JHQS 20190628 INC 27 127 {
				LET vnum_cred = TRIM(vnum_cred);
				LET vnum_cte = TRIM(vnum_cte);
				LET vejecutivo = TRIM(vejecutivo);
				LET vtarjeta = TRIM(vtarjeta);
				LET vnombrepromo = TRIM(vnombrepromo);
				LET vsucursal = TRIM(vsucursal);
				LET vfolio_movto = TRIM(vfolio_movto);
				
				SELECT COUNT(*) INTO iDatosCorrectos
				  FROM "informix".sd_maecred mc
				  JOIN "informix".sd_tarjeta t 
				    ON t.empresa = mc.empresa
				   AND t.num_credito = mc.num_credito
				   AND t.num_tarjeta = vtarjeta
				 WHERE mc.empresa = '001'
				   AND mc.num_credito = vnum_cred
				   AND mc.sucursal = vsucursal;							

				IF iDatosCorrectos = 0 THEN
					UPDATE "informix".sd_credpaso SET cod_ret = '000003', descripcion = 'Credito, Cliente, Tarjeta y/o Sucursal Incorrecto(s) ', activo = 0 WHERE num_credito = vnum_cred AND num_cte = vnum_cte AND num_promo = vnum_promo AND folio_movto = vfolio_movto;
					LET cCodRet = '000003';	
				ELSE -- AAME 20190822 INC 27 131 Se valida si los datos son correctos para continuar
				-- } JHQS 20190628 INC 27 127						
				--IF vnum_promo in(1,2,4,5,7,8) AND vfolio_movto='' THEN
								
					IF vmonto_actual<=0 OR vfolio_movto='' THEN
						UPDATE "informix".sd_credpaso SET cod_ret = '000004', descripcion = 'Falta folio o monto de movimiento ', activo = 0 WHERE num_credito = vnum_cred AND num_cte = vnum_cte AND num_promo = vnum_promo;
						LET cCodRet = '000004';	
						--CONTINUE FOREACH;
					ELSE					
						IF vnum_promo IN(1,2,4,5,7,8) THEN
							-- JHQS 20190628 INC 27 127 {
							SELECT COUNT(*) INTO iExiste
							  FROM "informix".sd_promocion_credito  
							 WHERE num_credito = vnum_cred
							   AND num_cte = vnum_cte
							   AND num_promo = vnum_promo
							   AND folio_movto = vfolio_movto
							   AND status IN(0,2);
								
							IF iExiste > 0 THEN
								UPDATE "informix".sd_credpaso SET cod_ret = '000005', descripcion = 'Ya existe credisolucion para este cliente, credito y promocion' WHERE num_credito = vnum_cred AND num_cte = vnum_cte AND num_promo = vnum_promo and folio_movto = vfolio_movto;
								LET cCodRet = '000005';	
							ELSE
								LET cCodRet = '000000';	
							END IF;
							-- } JHQS 20190628 INC 27 127
						ELSE
							-- JHQS 20190628 INC 27 127 {
							SELECT COUNT(*)
							  INTO iExiste
							  FROM "informix".sd_promocion_credito  
							 WHERE empresa = '001'
							   AND num_credito = vnum_cred
							   AND num_cte = vnum_cte
							   AND num_promo = vnum_promo
							   AND status IN(0,2);
							
							IF iExiste > 0 THEN
								UPDATE "informix".sd_credpaso SET cod_ret = '000005', descripcion = 'Ya existe credisolucion para este cliente, credito y promocion' WHERE num_credito = vnum_cred AND num_cte = vnum_cte AND num_promo = vnum_promo;
								LET cCodRet = '000005';	
							ELSE
								LET cCodRet = '000000';
							END IF;
							-- } JHQS 20190628 INC 27 127
						END IF;							
					
						IF cCodRet = '000000' THEN 						
							--IF NOT EXISTS(SELECT num_credito FROM "informix".sd_promocion_credito  
							--	WHERE num_credito = vnum_cred and num_cte = vnum_cte and num_promo=vnum_promo 
							--	and folio_movto=vfolio_movto and status in(0,2)) THEN
							LET i_Cont = 0;
							LET dd_Mensualidad_pp=0;
							LET dd_SaldoFinal_pp=0;
							LET vconsec=vconsec+1;

							FOREACH                 
								EXECUTE PROCEDURE bdicred:"informix".sp_consulta_proyecta_credisol(vmonto_actual,vplazo::INTEGER,0,'6900',vsucursal,1,0,vnum_cred,null,1,vnum_promo::INTEGER, vfolio_movto) INTO
								c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
								dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

								IF c_CodigoRet_pp != '000000' THEN
									LET cMensajeRet = 'ERROR AL EJECUTAR sp_consulta_proyecta_credisol';
									RETURN c_CodigoRet_pp;
								END IF;

								LET i_Cont = i_Cont + 1;
								IF i_Cont = 1 THEN
									LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
								END IF;
								LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;                                
							END FOREACH;

							IF vnum_promo IN(1,4,7) THEN
								LET dPagoMensual = dd_Mensualidad_pp;
								LET dInterIvaPlazoMax = dd_SaldoFinal_pp - vmonto_actual;
							ELIF vnum_promo IN(1,5,8) THEN
								LET dPagoMensual = dd_Mensualidad_pp;
								LET dPagoPorPlazo = dd_SaldoFinal_pp;
								LET dInterIvaPlazoMax = dPagoPorPlazo - vmonto_actual;
								LET dTotalPagar = dd_SaldoFinal_pp;
							ELSE 
								LET dPagoMensual = dd_Mensualidad_pp;
								LET dPagoPorPlazo = dd_SaldoFinal_pp;
								LET dInterIvaPlazoMax = dPagoPorPlazo - vmonto_actual;
								LET dTotalPagar = dd_SaldoFinal_pp;							
							END IF;

							--- PROCESO GENERICO PARA GENERAR UN FOLIO_SUC PARA LA PROMOCION
							--EXECUTE PROCEDURE bdicred:"informix".sp_generafoliocredi(vejecutivo, vconsec)
							--INTO cCodRetGF,cFolioSucGF;							
							-- AAME 20190822 INC 27 131 Se agrega validacion para que si el folio generado ya existe genere otro
							LET iExiste = 1;	
							
							WHILE iExiste > 0 
								EXECUTE PROCEDURE bdicred:"informix".sp_generafoliocredi(vejecutivo, vconsec)
								INTO cCodRetGF,cFolioSucGF;

								SELECT COUNT(*) INTO iExiste
								  FROM "informix".sd_promocion_credito  
								 WHERE folio_suc = cFolioSucGF;	
							END WHILE;

							IF cCodRetGF::INTEGER <> 0 THEN
								LET cCodRet = '000447';
								LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
								RETURN cCodRet; 
							ELSE
								LET vFolio_suc = cFolioSucGF;
								-- DA DE ALTA LA PROMOCION PARA EL CREDITO
								IF vnum_promo IN(1,4,7) THEN								
									INSERT INTO "informix".sd_promocion_credito
									(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
									VALUES ('001','06',vnum_promo,dtFechaHoy,vejecutivo,vnum_cte, vnum_cred,nvl(vtarjeta,''),vplazo,vFolio_suc,vmonto_actual,dInterIvaPlazoMax,dPagoMensual,0,vnombrepromo,vsucursal,'','6900',vfolio_movto);
									UPDATE "informix".sd_credpaso SET cod_ret='000000', descripcion='Credisolucion Pendiente Exitosa' WHERE num_credito=vnum_cred AND num_cte= vnum_cte AND num_promo=vnum_promo AND folio_movto=vfolio_movto;									
								ELIF vnum_promo IN(2,5,8) THEN
									INSERT INTO "informix".sd_promocion_credito
									(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
									VALUES ('001','06',vnum_promo,dtFechaHoy,vejecutivo,vnum_cte, vnum_cred,nvl(vtarjeta,''),vplazo,vFolio_suc,vmonto_actual,dInterIvaPlazoMax,dPagoMensual,0,vnombrepromo,vsucursal,'','6900',vfolio_movto);
									UPDATE "informix".sd_credpaso SET cod_ret='000000', descripcion='Credisolucion Pendiente Exitosa' WHERE num_credito=vnum_cred AND num_cte= vnum_cte AND num_promo=vnum_promo AND folio_movto=vfolio_movto;
								ELSE
									INSERT INTO "informix".sd_promocion_credito
									(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
									VALUES ('001','06',vnum_promo,dtFechaHoy,vejecutivo,vnum_cte,vnum_cred,nvl(vtarjeta,''),vplazo,vFolio_suc,vmonto_actual,dInterIvaPlazoMax,dPagoMensual,0,vnombrepromo,vsucursal,'','6900',vFolio_suc);		
									UPDATE "informix".sd_credpaso SET cod_ret='000000', descripcion='Credisolucion Pendiente Exitosa' WHERE num_credito=vnum_cred AND num_cte= vnum_cte AND num_promo=vnum_promo;
								END IF;	                           
							END IF;
							--END IF;
						END IF;
					END IF;
				END IF;
			END FOREACH 				  

			LET cCadena = '';
			LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter ''|'' SELECT num_credito,num_cte,num_promo,ejecutivo,num_tarjeta,plazo,tasa,monto_actual,nombre_promo,sucursal,folio_movto,cod_ret,descripcion FROM bdicred:"informix".sd_credpaso" >'||TRIM(cRuta)||'bit_camp.sql';
			SYSTEM cCadena;				
			LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
			System cCadena;				
			let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
			System cCadena;				
			LET cCadena = '' ;
			LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
			SYSTEM cCadena;
			-- AAME 20190822 INC 27 131 Finalizar con exito el archivo procesado para no alarmar el JOB
			IF cCodRet <> '000000' THEN
				LET cCodRet = '000000';
			END IF;	
			
		END IF; 
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 27/ene/2018',
'BD    : BDICRED',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'MODIFICACIÓN',
'RQ         : INC 27 127 Corrección de error en credisoluciones',
'FECHA      : 28 de Junio de 2019',
'DESCRIPCIÓN: Se agregó la validación de la sucursal de apertura del crédito tarjeta y número de cliente para evitar credisoluciones con error por captura o lectura incorrecta',
'MODIFICO   : Jorge Humberto Quintana Santiesteban',
'CC         : 33906',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cancel_reportes_ctanunca_24m(pEmpresa CHAR(3)) 
RETURNING CHAR(6) AS cCodRet;

---DECLARACION DE VARIABLES
DEFINE iSqlErr 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info 		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cProceso         CHAR(4);

DEFINE cNombre1			CHAR(50);
DEFINE cNombre2			CHAR(50);
DEFINE cNom_Archivo		CHAR(50);
DEFINE cNom_Archivo_aux	CHAR(50);
DEFINE cRuta            CHAR(100);
DEFINE cCod_retBit      CHAR(6);
DEFINE v_Mensaje		CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(6204);
DEFINE cSQL2            CHAR(6204);
DEFINE cSQL3            CHAR(100);
DEFINE dFechaHoy		DATE;


--SET DEBUG FILE TO "/informix/mahr/sp_cancel_reportes_ctanunca_24m.out";
--TRACE ON;


---INICIALIZACION DE VARIABLES
LET iSqlErr 			= 0;
LET isam_err 			= 0;
LET error_info 			= '';
LET cCodRet  			= '000000';
LET cProceso			= '0105';

LET cNombre1			= '';
LET cNombre2			= '';
LET cNom_Archivo		= '';
LET cNom_Archivo_aux	= '';
LET cRuta				= '';
LET cCod_retBit			= '000000';
LET v_Mensaje			= '';
LET cSQL            	= '';
LET cSQL1            	= '';
LET cSQL2            	= '';
LET cSQL3            	= '';
LET dFechaHoy			= date(1);


BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Error-"||isam_err||"-"||trim(error_info), '02') Returning cCod_retBit;
	
	RETURN cCodRet;
END EXCEPTION;

	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Lectura de parametros	
	SELECT valor INTO cNombre1 FROM bdicred:sd_param WHERE cod_param = '38';			-- Nombre reporte de creditios cancelados 
	SELECT valor INTO cNombre2 FROM bdicred:sd_param WHERE cod_param = '39';			-- Nombre reporte de sms enviados previa reduccion.
	SELECT valor INTO cRuta FROM bdicred:sd_param WHERE cod_param = '080';				-- Ruta reportes generados
	
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas;
	
    IF NVL(cRuta,'') = '' OR NVL(cNombre1,'') = '' OR NVL(cNombre2,'') = '' THEN				-- No existe la ruta o nombre de archivos
        LET cCodRet = '000001';
        RETURN cCodRet;
    END IF;
	
	-- Registra inicio en bitacora
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Inicio genera reportes cancelacion creditos nunca 24 meses.", '02') Returning cCod_retBit;

	
	---------------------------------------------------------
	-- Genera archivo con informacion de creditos cancelados.	
    LET cNom_Archivo_aux =  TRIM(cNombre1)||'Aux'||to_char(dFechaHoy,'%d%m%Y')||'.txt';
    LET cNom_Archivo =  TRIM(cNombre1)||to_char(dFechaHoy,'%d%m%Y')||'.txt';	
	
	LET cSQL = '';
	LET cSQL = 'echo "fecha_reporte'||'|'||'num_credito'||'|'||'fecha_cancelacion'||'|'||'fecha_apertura'||'|'||'linea_originacion'||'|'||'linea_cancelacion'||'|'||'meses_inactividad'||'|'
					 ||'saldo_cancelacion'||'|'||'grupo_originacion'||'|'||'modelo'|| ' " >' || TRIM(cRuta) || cNom_Archivo;
	System cSQL;	
	
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNom_Archivo_aux); 

	LET cSQL2 = " SELECT today, nun.num_credito, nun.fecha_mes_2_cancela, crd.fecha_apertura, det.linea_final, nun.monto_linea_cancelacion, "
				|| " nun.meses_inactividad_cancela, nun.saldo_credito_cancelacion, "
				|| " det.grupo, case when nvl(det.evalua_cc,'X') = 'X' then 'NO-HIT' else 'HIT' end "
				|| " FROM bdicred:sd_cancela_creds_nunca nun "
				|| " JOIN bdicred:sd_maecred crd ON (nun.num_credito = crd.num_credito)"
				|| " LEFT OUTER JOIN bdisolic:ss_revision_determinacion det ON (nun.num_credito = det.num_solicitud) "
				|| " WHERE nvl(fecha_mes_2_cancela, date(1)) != date(1); ";
				
		
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_rep_canc_nun24m.sql';

	LET cSQL = trim(cSQL1) || rtrim(cSQL2) || trim(cSQL3);
	SYSTEM cSQL;

	LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_rep_canc_nun24m.sql';
	SYSTEM cSQL;

	LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_rep_canc_nun24m.sql';
	SYSTEM cSQL;

	LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cNom_Archivo_aux || " >> " || TRIM(cRuta) || cNom_Archivo;
	SYSTEM cSql;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_rep_canc_nun24m.sql';
	SYSTEM cSQL;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cRuta) || cNom_Archivo_aux;
	SYSTEM cSQL;	
				
    LET cSQL='chmod 777 '|| TRIM(cRuta) || cNom_Archivo;
    System cSQL;				


	--------------------------------------------------
	-- Genera archivo con informacion de sms enviados.
	
	LET cSQL  = "";		LET cSQL1 = "";		LET cSQL2 = "";		LET cSQL3 = "";		LET cNom_Archivo_aux = "";	LET cNom_Archivo = "";
	
	
	LET cNom_Archivo_aux =  trim(cNombre2)||'Aux'||to_char(dFechaHoy,'%d%m%Y')||'.txt';
    LET cNom_Archivo =  trim(cNombre2)||to_char(dFechaHoy,'%d%m%Y')||'.txt';	
	
	LET cSQL='';
	LET cSQL = 'echo "fecha_reporte'||'|'||'num_credito'||'|'||'fecha_envio_sms'||'|'||'meses_inactividad'||'|'||'estatus_envio_sms'||'|'||'linea_credito'||'|'
					 ||'grupo_originacion'||'|'||'modelo'|| ' " > ' || TRIM(cRuta) || cNom_Archivo;
	System cSQL;	
		
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNom_Archivo_aux); 

	LET cSQL2 = " SELECT today, nun.num_credito, fecha_mes_1_sms, meses_inactividad_sms, case when nvl(status_sms_mes_1,'') = '' then 'No Enviado' "
			 || " when nvl(status_sms_mes_1,'') = '0' then 'No Enviado' when nvl(status_sms_mes_1,'') = '1' then 'Enviado' else 'En Error' end, "
			 || " dos.monto_otorgado, det.grupo, case when nvl(det.evalua_cc,'X') = 'X' then 'NO-HIT' else 'HIT' end "
			 || " FROM bdicred:sd_cancela_creds_nunca nun "
			 || " JOIN bdicred:sd_maesdos dos on (nun.num_credito = dos.num_credito) "
			 || " LEFT OUTER JOIN bdisolic:ss_revision_determinacion det on (nun.num_credito = det.num_solicitud) "
			 || " WHERE nvl(fecha_mes_1_sms, date(1)) != date(1); ";

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_rep_sms_nun24m.sql';

	LET cSQL = trim(cSQL1) || rtrim(cSQL2) || trim(cSQL3);
	SYSTEM cSQL;

	LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_rep_sms_nun24m.sql';
	SYSTEM cSQL;

	LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_rep_sms_nun24m.sql';
	SYSTEM cSQL;

	LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cNom_Archivo_aux || " >> " || TRIM(cRuta) || cNom_Archivo;
	SYSTEM cSql;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_rep_sms_nun24m.sql';
	SYSTEM cSQL;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cRuta) || cNom_Archivo_aux;
	SYSTEM cSQL;	
				
    LET cSQL='chmod 777 '|| TRIM(cRuta) || cNom_Archivo;
    System cSQL;				  
					  
				 			
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Finaliza creacion de reportes cancelacion creditos nunca 24 meses.", '02') Returning cCod_retBit;
	
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Procedimiento para generar los reportes de la cancelacion de creditos nunca con 24 meses sin realizar movimientos desde su fecha de apertura',
'Fecha: Febrero 2020';

CREATE PROCEDURE "informix".sp_cac_consultasolincrelincred(pEmpresa     CHAR(3),
                                                      pStatus      CHAR(2),
													  pFechaIni    CHAR (10),
													  pFechaFin    CHAR (10),
													  pNomCte1     VARCHAR(26,1),        
													  pNomCte2     VARCHAR(26,1),
													  pApellPat    VARCHAR(26,1),
													  pApellMat    VARCHAR(26,1),    
													  pFechaNac    CHAR (10),
													  pOrigen      CHAR(1),
													  pNumCte      VARCHAR(20,1),
													  pNumCred     VARCHAR(20,1),
													  pNumTarjeta  VARCHAR(20,1),
													  pEjecutivo   CHAR(8),
													  pNumPag           INTEGER,
                                                      pDesplazar        INTEGER)
													  
													  
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret,
          VARCHAR(20,1)     AS num_cred,
          VARCHAR(20,1)     AS num_cte,
		  VARCHAR(107,1)    AS nombre_cte,
		  CHAR(2)           AS status,
		  CHAR(10)          AS origen,
		  CHAR(4)           AS sucursal,
		  DATE              AS fecha,
		  DECIMAL(18,2)     AS lincred_actual,
		  DECIMAL(18,2)     AS lincred_sugerida,
		  INTEGER           AS iRevisionCac,
		  VARCHAR(107,1)    AS usuario_trabajando,
		  SMALLINT			AS Continua,         -- Indica si existen más registros por consultar
		  INTEGER           AS pagina,
		  INTEGER as totalReg,
		  DATE as fechaSolicitud,
		  CHAR(3) as ClaveRT_CM;

DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        VARCHAR(255,1);
DEFINE cCodRet           CHAR(6);
DEFINE cMensajeRet       VARCHAR(100,1);													  
DEFINE cNumCred          VARCHAR(20,1);
DEFINE cNumCte           VARCHAR(20,1);
DEFINE cStatus           CHAR(2);
DEFINE cOrigen           CHAR(10);
DEFINE cSucursal         CHAR(4);
DEFINE dtFechaInsert     DATE;
DEFINE dtFechaStatus 	 DATE;
DEFINE dtFechaIni        DATE;
DEFINE dtFechaFin        DATE;
DEFINE dtFechaNac        DATE;
DEFINE dLincredActual    DECIMAL(18,2);
DEFINE dLincredSugerida  DECIMAL(18,2);
DEFINE cNomCte           VARCHAR(107,1);
DEFINE iNumReg           INTEGER;
DEFINE iNumReg2           INTEGER;
DEFINE iRevisionCac      INTEGER;
DEFINE cNombreUsuario    VARCHAR(107,1);
DEFINE dMontoIncremento  DECIMAL(18,2);
DEFINE cRevisionCacAzul  CHAR(2);
DEFINE iContador         INTEGER;
DEFINE iContadorSol      INTEGER;
DEFINE iNumPag           INTEGER;
DEFINE sSiguiente        SMALLINT;
DEFINE iTotalReg        INTEGER;
DEFINE cCausa 	    CHAR(3);
DEFINE iNivel           INTEGER;
DEFINE pChkRevision	    CHAR(3);

LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "CONSULTA EXITOSA";
LET cNumCred             = "";
LET cNumCte              = "";
LET cStatus              = "";
LET cOrigen              = "";
LET cSucursal            = "";
LET dtFechaInsert        = DATE(1);
LET dtFechaStatus		 = DATE(1);
LET dtFechaIni           = DATE(1);
LET dtFechaFin           = DATE(1);
LET dtFechaNac           = DATE(1);
LET dLincredActual       = 0;
LET dLincredSugerida     = 0;
LET cNomCte              = "";
LET iNumReg              = 0;
LET iNumReg2              = 0;
LET iRevisionCac         = 0;
LET cNombreUsuario       = "";
LET iContador            = 0;
LET iContadorSol         = 0;
LET iNumPag              = 1;
LET sSiguiente           = 0;
LET cRevisionCacAzul     = "";
LET dMontoIncremento     = 0;
LET iTotalReg            = 0;
LET cCausa              = '';
LET iNivel              = 0;
LET pChkRevision        = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg, dtFechaInsert, cCausa ;	    		 
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/ifxsif01/gpe/sp_cac_consultasolincrelincred.out';
--TRACE ON;

IF pEmpresa IS NULL THEN 
   LET cCodRet     = "000001";
   LET cMensajeRet = "LA EMPRESA INDICADA NO ES VALIDA";
   RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg, dtFechaInsert, cCausa ;
END IF;

SELECT valor 
  INTO iNumReg
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '044'
   AND empresa = pEmpresa ;


IF NVL(iNumReg,"") = "" THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "NO SE ENCUENTRA EL PARÁMETRO PARA LA PAGINACIÓN DE CONSULTA.";
          RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
		    dtFechaStatus, dLincredActual, dLincredSugerida,iRevisionCac,cNombreUsuario,0,iNumPag,iTotalReg,dtFechaInsert, cCausa;
END IF;

IF pStatus IS NULL THEN 
 LET pStatus = "";
END IF;

IF pFechaIni IS NULL OR pFechaIni = "" THEN 
  LET dtFechaIni = DATE(1);
ELSE
	LET dtFechaIni = pFechaIni;
END IF;

IF pFechaFin IS NULL OR pFechaFin = "" THEN 
  LET dtFechaFin = CURRENT;
ELSE
	LET dtFechaFin = pFechaFin;
END IF;

IF pNomCte1 IS NULL THEN
  LET pNomCte1 = "";
END IF;

IF pNomCte2 IS NULL THEN
  LET pNomCte2 = "";
END IF;

IF pApellPat IS NULL THEN
  LET pApellPat = "";
END IF;

IF pApellMat IS NULL THEN
  LET pApellMat = "";
END IF;

IF pFechaNac IS NULL OR pFechaNac = "" THEN
  LET dtFechaNac = DATE(1);  
ELSE
	LET dtFechaNac = pFechaNac;  
END IF;

IF pOrigen IS NULL THEN
  LET pOrigen = "";
END IF;

IF pNumCte IS NULL THEN
  LET pNumCte = "";
END IF;

IF pNumCred IS NULL THEN
  LET pNumCred = "";
END IF;

IF pNumTarjeta IS NULL THEN
  LET pNumTarjeta = "";
END IF;

SELECT LIMIT 1 nivel INTO iNivel
 FROM "informix".sd_perfiles_cac_aumlincred
 WHERE ejecutivo = pEjecutivo;

--LET iNumReg2 = iNumReg * 2; 
IF NVL(pDesplazar,0) IN (0,2,3) THEN -- Consulta inicial (0), pagina siguiente(2), consulta general sin paginación (3).

	IF NVL(pDesplazar,0) = 0 THEN
		DELETE FROM bdicred:"informix".sd_paginacion_cac_aumlincred WHERE ejecutivo = pEjecutivo;	

		FOREACH WITH HOLD
			SELECT num_cred INTO cNumCred FROM bdicred:"informix".tme_bitacora_aumlincred_orden WHERE ejecutivo = pEjecutivo
				DELETE FROM bdicred:"informix".tme_bitacora_aumlincred_orden WHERE ejecutivo = pEjecutivo; --AND num_cred = cNumCred ; 			
		END FOREACH;
		
		
	ELIF NVL(pDesplazar,0) = 2 THEN 	-- Avanzar hacia la siguiente página
		SELECT MAX(pagina) + 1
		  INTO iNumPag
		  FROM bdicred:"informix".sd_paginacion_cac_aumlincred
		 WHERE ejecutivo = pEjecutivo; 		 
	END IF;
  
		IF NVL(pNumTarjeta,'') <> '' THEN
			SELECT num_credito
				INTO pNumCred
			FROM bdicred:"informix".sd_tarjeta 	
			WHERE empresa = '001'
			AND status_tar = "A"
			AND tipo_tarjeta = "T"			
			AND num_tarjeta   = pNumTarjeta;
			
			IF NVL(pNumCred,'') ='' THEN
				LET cCodRet     = "000003";
				LET cMensajeRet = "NO EXISTE INFORMACION,VERIFIQUE";
				RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
				  NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') ;
			END IF;
		END IF;
		
		--Obtener el número total de registros
		IF NVL(pDesplazar,0) = 0 THEN
			FOREACH WITH HOLD
				SELECT  {+MULTI_INDEX(sd_bitacora_aumlincred)} a.num_solicitud, 
					   a.numcte,
					   a.status,
					   a.origen, --DECODE(a.origen,"C","CENTRAL","S","SUCURSAL"),
					   a.sucursal,
					   a.fecha_insert,
					   a.fecha_status, 
					   a.lincred_actual,
					   a.lincred_sugerida,
					   a.causa_status					   
				  INTO cNumCred,
					   cNumCte,
					   cStatus,
					   cOrigen,
					   cSucursal,
					   dtFechaInsert,
					   dtFechaStatus, 
					   dLincredActual,
					   dLincredSugerida,
					   cCausa					   
				  FROM "informix".sd_bitacora_aumlincred a			         			   		   
				 WHERE  a.empresa       = pEmpresa
				   AND a.numcte        = a.numcte
				   AND a.num_solicitud = (CASE WHEN pNumCred  = "" THEN a.num_solicitud ELSE pNumCred END)
				   AND a.numcte        = (CASE WHEN pNumCte   = "" THEN a.numcte ELSE pNumCte END)
				   AND a.status        = (CASE WHEN pStatus   = "" THEN a.status ELSE pStatus END)
				   AND a.fecha_insert  BETWEEN dtFechaIni AND dtFechaFin
				   AND a.origen        = (CASE WHEN pOrigen   = "" THEN a.origen ELSE pOrigen END)			  
				  -- AND a.num_solicitud NOT IN (SELECT num_cred  FROM bdicred:"informix".sd_paginacion_cac_aumlincred WHERE ejecutivo = pEjecutivo AND NVL(pDesplazar,0) <> 3)
				   ORDER BY fecha_insert
				   				 
				   IF cStatus = "AC" THEN		   
					   /*SELECT revision_cac
						INTO iRevisionCac
					   FROM bdicred:"informix".sd_autorizacion_aumlincred
					   WHERE num_solicitud =cNumCred
					   AND status = 'AC'
					   AND fecha_insert = dtFechaStatus; */
					   SELECT limit 1 revision_cac
						INTO iRevisionCac
						FROM bdicred:"informix".sd_autorizacion_aumlincred
						WHERE  num_solicitud = cNumCred
						AND status = 'AC'
						 AND fecha_status = (SELECT MAX(fecha_status)	
											FROM bdicred:"informix".sd_autorizacion_aumlincred
											WHERE  num_solicitud = cNumCred
											AND status = 'AC' );
				   ELSE
						LET iRevisionCac=0;
				   END IF;
				
				IF iRevisionCac = 3 THEN  
				    LET dMontoIncremento =dLincredSugerida-dLincredActual;
					   
					SELECT rango_autorizacion
					INTO cRevisionCacAzul
					FROM bdicred:"informix".sd_autorizaciones_cac_aumlincred
					WHERE dMontoIncremento BETWEEN monto_minimo AND monto_maximo;
									
					IF cRevisionCacAzul = "03" THEN
						LET iRevisionCac = 5;
					END IF;				
				
				END IF;
				
				LET iContadorSol = iContadorSol + 1;
					
								   
			INSERT INTO 'informix'.tme_bitacora_aumlincred_orden(
					   orden,	secuencia,ejecutivo,num_cred,numcte,status_sol,origen,sucursal,fecha_sol,
					   lincred_actual,lincred_sugerida,revision_cac,pagina, fecha_insert, causa_status)
					VALUES( ( --case when pStatus <> "AC" then iContadorSol  --> Si es por "AC" hacer el ordenamiento pot orden de insertcion
						--else
							case when iRevisionCac = 4 then 5 
							else
								case when iRevisionCac = 5 then 4
								else 
									case when iRevisionCac = 3 then 3
									else 
										case when iRevisionCac = 2 then 2
										else
											case when iRevisionCac = 1 then 1
											else
												case when iRevisionCac = 0 then 0
												else
													case when iRevisionCac IS NULL then 0
													end
												end
											end
										end
									end
								end
							--end
						end),
						iContadorSol,pEjecutivo,cNumCred, cNumCte, cStatus, cOrigen, cSucursal,dtFechaStatus, 
						dLincredActual, dLincredSugerida, iRevisionCac, iNumPag, dtFechaInsert, cCausa); 
			
					
			END FOREACH;				
		END IF;
		
		LET iContadorSol         = 0;
		LET iContadorSol =(iNumPag - 1) * 100;
		--Determinar si es analista de crédito para que solo le aparescan solitudes en blanco
		--SELECT LIMIT 1 nivel INTO iNivel FROM "informix".sd_perfiles_cac_aumlincred WHERE ejecutivo = pEjecutivo;

		IF iNivel = 1 THEN
		 LET pChkRevision = '1'; --Trae nomas las revisiones en 0 (Solicitudes en blanco)
		 
		ELSE 
			IF iNivel in (2,3,4) THEN
				LET pChkRevision = '0';  --Trae todas la revisiones
			END IF;
		END IF;
		
		
		--Si se consulta por estatus distinto a ac ordenamiento por fecha_insert
		IF pStatus != 'AC' THEN
		
			UPDATE "informix".tme_bitacora_aumlincred_orden
			SET orden = 0 
			WHERE ejecutivo = pEjecutivo;
			--Que busque por todas las revisiones
			LET pChkRevision = '0';
		END IF;
		
		
		--Total de registros total deacuerdo a la revisión
		SELECT COUNT(a.num_cred) INTO iTotalReg FROM tme_bitacora_aumlincred_orden a 
		WHERE (NVL(a.revision_cac,0) <= (CASE WHEN (pChkRevision = '1') THEN 1 ELSE a.revision_cac END) OR (a.revision_cac IS NULL) )
		AND a.ejecutivo = pEjecutivo ; -- Trae todas las solictudes en blanco cuando el ejecutivo tenga nivel 1 (Analista) ;
		
		FOREACH WITH HOLD			   
			   
			SELECT a.num_cred, 
				   a.numcte,
				   a.status_sol,
				   DECODE(a.origen,"C","CENTRAL","S","SUCURSAL"),
				   a.sucursal,
				   a.fecha_insert,
				   a.fecha_sol, 
				   a.lincred_actual,
				   a.lincred_sugerida,
				   a.causa_status,a.revision_cac
			  INTO cNumCred,
				   cNumCte,
				   cStatus,
				   cOrigen,
				   cSucursal,
				   dtFechaInsert,
				   dtFechaStatus, 
				   dLincredActual,
				   dLincredSugerida,
				   cCausa,iRevisionCac
			  FROM "informix".tme_bitacora_aumlincred_orden a			         			   		   
			 WHERE  a.ejecutivo = pEjecutivo
			   AND (NVL(a.revision_cac,0) <= (CASE WHEN (pChkRevision = '1') THEN  1 ELSE a.revision_cac END) OR (a.revision_cac IS NULL) ) -- Trae todas las solictudes en blanco cuando el ejecutivo tenga nivel 1 (Analista) 
			   AND  a.numcte = a.numcte
			   ORDER BY orden DESC, fecha_insert			   
			  
					LET iContador = iContador + 1;		 
					LET iContadorSol = iContadorSol + 1;
					LET cNombreUsuario = "";
				IF (iContador > (iNumPag-1) * iNumReg) THEN
					   SELECT TRIM(NVL(apell_paterno," ")) || " " ||
						   TRIM(NVL(apell_materno," ")) || " " ||
						   TRIM(NVL(nombre1," ")) || " " ||
						   TRIM(NVL(nombre2," "))
						INTO cNomCte
					   FROM bdinteg:"informix".si_cliente
					   WHERE empresa ='001'
					   AND numcte =cNumCte; 
					   
					IF pStatus != 'AC' THEN   
						IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_sol_procesando_aumlincred WHERE num_credito = cNumCred) THEN	
							SELECT  b.nombre 
								INTO cNombreUsuario
							FROM bdicred:"informix".sd_sol_procesando_aumlincred a
							INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.usuario)
							WHERE num_credito = pNumCred;			
					
							LET cNombreUsuario = "SOLICITUD ESTÁ SIENDO ATENDIDA POR "|| TRIM(cNombreUsuario);
						END IF;				  
					END IF;
								
				
					IF  pDesplazar <> 3 AND  (pDesplazar <> 0 AND iNumPag <> 0)  THEN				
						IF ((iContador ) <=  (iNumPag) * iNumReg) OR ((iNumPag - 1) =0 AND iContador<=iNumReg)  THEN
								INSERT INTO bdicred:"informix".sd_paginacion_cac_aumlincred 
									(secuencia,ejecutivo,num_cred,numcte,nombrecte,status_sol,origen,sucursal,fecha_sol,lincred_actual,lincred_sugerida,revision_cac,nombre_usuario, fecha_apertura, causa, pagina)
								VALUES (iContadorSol,pEjecutivo,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, dtFechaInsert, cCausa, iNumPag);
						ELIF (iContador ) = (((iNumPag ) *iNumReg ) + 1) OR  ((iNumPag - 1) =0 AND iContador=iNumReg +1)   THEN
							LET sSiguiente = 1;
						ELSE
							EXIT FOREACH;		
						END IF;	       
					END IF;
				
					RETURN cCodRet,cMensajeRet,cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal,
					dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, sSiguiente,iNumPag,iTotalReg, dtFechaInsert, cCausa WITH RESUME;
		    END IF
		END FOREACH;
ELIF NVL(pDesplazar,0) = 1 THEN -- Pagina anterior

    DELETE FROM bdicred:"informix".sd_paginacion_cac_aumlincred
          WHERE ejecutivo = pEjecutivo
			AND pagina = pNumPag + 1;

    FOREACH
        SELECT num_cred,numcte,nombrecte,status_sol,	origen,sucursal,fecha_sol,lincred_actual,lincred_sugerida,revision_cac,nombre_usuario, fecha_apertura, causa, pagina
          INTO cNumCred, cNumCte,cNomCte, cStatus, cOrigen, cSucursal, dtFechaStatus, dLincredActual, dLincredSugerida, iRevisionCac,cNombreUsuario, dtFechaInsert,cCausa, iNumPag
          FROM bdicred:"informix".sd_paginacion_cac_aumlincred
         WHERE ejecutivo = pEjecutivo
           AND pagina = pNumPag 
		   ORDER BY secuencia
          
       RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
				    NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') WITH RESUME;
    END FOREACH;
ELSE
		LET cCodRet     = "000002";
		LET cMensajeRet = "PARAMETRO INCORRECTO EN EL VALOR DE PAGINACION,VERIFIQUE";
		RETURN cCodRet,cMensajeRet,NVL(cNumCred,""), NVL(cNumCte,""),NVL(cNomCte,""), NVL(cStatus,""), NVL(cOrigen,""), NVL(cSucursal,""),
		  NVL(dtFechaStatus,DATE(1)), NVL(dLincredActual,0), NVL(dLincredSugerida,0), NVL(iRevisionCac,0),cNombreUsuario,1,NVL(iNumPag,0),NVL(iTotalReg,0), NVL(dtFechaInsert, 0), NVL(cCausa, '') WITH RESUME;
END IF;


END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para',
'la generación de la información para la',
'consulta de incrementos',
'AUTOR : Paul Ivan Quintero Varela,Jesús Manuel Aguilar Heredia',
'FECHA : 07/SEPT/2011',
'BD: BDICRED',
'VERSION:20110907.0838',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Jesús Manuel Aguilar Heredia',
'Modificación: Se realiza optimizacion',
'Fecha de modificación: 23/Enero/2013',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Juan Daniel Lazalde Centeno',
'Modificación: Se agrega el numero total de registros, se agrega código para traer los datos sin paginación, ordenamiento de la solicitudes por nivel del ejecutivo',
'Fecha de modificación: 28/Enero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".reversion_td(pSucursal   CHAR(4),
                                     pUsuario    CHAR(8),
                                     pFolioOrig  CHAR(16),
                                     pNumCredito CHAR(20),
                                     pTransacc   CHAR(4),
                                     pImpOrig    MONEY(16,2),
                                     pImpRev     MONEY(16,2),
                                     pFolio      CHAR(16),
                                     pTranSuc    CHAR(4),
                                     pDivisa     CHAR(2))
   RETURNING CHAR(5), DATE;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   DEFINE wBegin              CHAR(1);
   DEFINE wEmpresa            CHAR(3);
   DEFINE FechaMov            DATE;
   DEFINE HoraMov             DATETIME HOUR TO FRACTION(3);
   DEFINE wSecuencia          INTEGER;
   DEFINE wMonto              MONEY(16,2);
   DEFINE CodigoFun           CHAR(3);
   DEFINE CodigoRef           SMALLINT;
   DEFINE wReversado          CHAR(1);
   DEFINE NumProducto         CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE wMtoReversa         MONEY(16,2);
   DEFINE FecAplic            DATE;
   DEFINE vNaturaleza         CHAR(1);
   DEFINE vTpTran	      CHAR(2);
   DEFINE cStatus	      CHAR(2);
   DEFINE vcod_ret  		CHAR(5);
   DEFINE vmontocs            MONEY(16,2);
   DEFINE vsucursal           CHAR(4); --INC 25 019
   DEFINE sdpromtot           SMALLINT; --INC 25 019
   DEFINE limefec			  CHAR(1); --RQM 10 1225
   DEFINE transuc             CHAR(4); --RQM 10 1225
   DEFINE cIndDispEfec        INTEGER; --RQM 10 1225
   DEFINE vNumProd            CHAR(4); --RQM 10 1225

   
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "ReversaLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET FecAplic  = NULL;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, FecAplic;
   END EXCEPTION;



   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  
   LET wBegin = "N";
   LET FecAplic = NULL;



   BEGIN WORK;
   LET cod_ret = "000";
   LET vmontocs = 0;
   LET cStatus = "";

   LET wEmpresa = pTransacc;
   LET vsucursal = ''; --INC 25 019
   LET sdpromtot = 0; --INC 25 019
   LET limefec	    = ''; --RQM 10 1225
   LET cIndDispEfec = 0; -- RQM 10 1225
   LET transuc      = ''; --RQM 10 1225
   LET vNumProd     = ''; --RQM 10 1225
   
 
FOREACH

   SELECT a.empresa, a.num_credito, a.fecha_mov, a.hora_mov,
	  a.secuencia, a.monto, a.codigo_fun, a.codigo_ref, a.reversado,
	  b.naturaleza, tipo_tran, a.sucursal,	  --INC 25 019
	  a.transacc_suc --RQM 10 1225
     INTO wEmpresa, pNumCredito, FechaMov, HoraMov,
	  wSecuencia, wMonto, CodigoFun, CodigoRef, wReversado,
	  vNaturaleza, vTpTran,vsucursal, -- INC 25 019
	  transuc --RQM 10 1225
     FROM sd_movdia a, bdinteg:si_transacc b
    WHERE a.empresa = wEmpresa
      AND a.folio_suc = pFolioOrig
      AND a.folio_suc = (case when codigo_fun = '002' and codigo_ref = 45 THEN '0' ELSE a.folio_suc END)
      AND b.empresa = a.empresa
      AND b.sistema = "06"
      AND b.numero = a.transacc_suc
	  
 
	 SELECT status_cred, diferimiento_int,num_producto --RQM 10 1225
      INTO cStatus, cIndDispEfec, vNumProd
     FROM bdicred:sd_maecred 
    WHERE empresa = wEmpresa
      AND num_credito = pNumCredito;	  
    
    SELECT limite_efectivo    --RQM 10 1225
	INTO limefec
	FROM bdicred:sd_conceptoscargoscredito
	WHERE transacc =  transuc;















   LET FecAplic = FechaMov;
   IF (wReversado = "S") THEN
      LET cod_ret = "000";
      RETURN cod_ret, FecAplic;
   END IF;

   IF vNaturaleza = "C" THEN
            
			SELECT count(*) INTO sdpromtot FROM bdicred:sd_promocion_credito 
			WHERE empresa = wEmpresa 
			AND num_credito = pNumCredito AND folio_movto = pFolioOrig AND status = 0;
			
            IF sdpromtot > 0 THEN
                  SELECT limit 1 nvl(monto_int_iva,0)
                    INTO vmontocs 
                    FROM sd_promocion_credito  
                   WHERE empresa = wEmpresa
                     AND folio_movto = pFolioOrig
                     AND status = 0;
                 
                   UPDATE sd_maesdos
                      SET sdo_retenido = sdo_retenido - vmontocs
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa;

                   UPDATE sd_promocion_credito
                      SET status = 5
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa
                      AND folio_movto = pFolioOrig
                      AND status = 0;

                   UPDATE sd_maeretenido
                      SET estatus = 'S'
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa
                      AND folio_suc = pFolioOrig
                      AND estatus = 'R';

                   UPDATE sd_movdia
                      SET reversado = 'S'
                    WHERE empresa = wEmpresa
                      AND num_credito = pNumCredito
                      AND folio_suc = pFolioOrig
                      AND codigo_fun = '002' AND codigo_ref = 45;

            END IF;              
                
               UPDATE sd_maesdos
                  SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital - wMonto END,--JMAH
                --  SET sdo_capital = sdo_capital - wMonto,
                  sdo_cap_insoluto = sdo_cap_insoluto - wMonto,
                  mto_ministra_cap = mto_ministra_cap - wMonto,
                  cargos_mes_cap = cargos_mes_cap - wMonto,
				  cap_tras_no_venci = CASE WHEN  cStatus = "BT" THEN  cap_tras_no_venci - wMonto ELSE cap_tras_no_venci END --JMAH 
		       WHERE num_credito = pNumCredito
                  AND empresa = wEmpresa;
               
			   --INC 25 019	   
               UPDATE sd_movdia
                  SET reversado = "S"
                WHERE empresa = wEmpresa
                  AND num_credito = pNumCredito
                  AND folio_suc = pFolioOrig
                  --AND sucursal = pSucursal 
				  AND sucursal = vsucursal --INC 25 019
                  AND secuencia = wSecuencia;

                   IF vTpTran IN ("01","02") THEN
                    UPDATE sd_detcomi
                       SET estado_com = "C"
                     WHERE num_credito = pNumCredito
                       AND num_solicitud = pFolioOrig
                       AND monto_com = wMonto;	   
			   END IF
			   			
			IF cIndDispEfec = 1 or cIndDispEfec = 2 THEN --RQM 10 1225-2	
				IF NVL(limefec,'0') = '1' THEN --DISPOSICIONES EN EFECTIVO A NIVEL TRANSACCION
					UPDATE sd_maesdos SET sdo_acum_vencido =  sdo_acum_vencido - wMonto
					WHERE empresa = wEmpresa AND num_credito = pNumCredito;					
			    END IF;
			END IF;
			   






				   IF (CodigoFun = '339' AND  CodigoRef = 96)  THEN
						DELETE  FROM sd_comision_x_apertura_contable  WHERE empresa = wEmpresa	AND num_credito = pNumCredito;

						UPDATE "informix".sd_maecred
						SET campo_trab4 ='' --se actualiza para indicar que ya se realizo el cobro de la comision por apertura
						WHERE empresa =wEmpresa
						AND num_credito = pNumCredito;
				   END IF;

     
   ELIF vNaturaleza = "A" THEN
	IF CodigoFun = "033" OR CodigoFun = "335" OR CodigoFun = "336" THEN
		IF CodigoRef = 2 THEN

		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		END IF
	   UPDATE sd_movdia
	   SET reversado = "S"
	   WHERE empresa = wEmpresa
	   AND num_credito = pNumCredito
	   AND folio_suc = pFolioOrig;

	ELIF CodigoFun = "650" THEN

	END IF
	IF (vTpTran IN ("00") and vNaturaleza = "C" ) or (vNaturaleza = "A") THEN
           EXECUTE PROCEDURE sp_graba_indicador(wEmpresa, pNumCredito,wMonto, pTranSuc,CodigoFun, CodigoRef, FechaMov,pFolio,0,0,3)
           INTO vcod_ret;
	END IF;	   
   END IF

END FOREACH

      COMMIT WORK;
   IF (wBegin = "S") THEN
     BEGIN WORK;
   END IF;
   RETURN cod_ret, FecAplic;
END PROCEDURE
DOCUMENT
'Esta funcion realiza la reversion de un movimiento ATM ',
'en el producto Insta - Cash, si los importes son iguales y es fecha de hoy',
'Se reversa el movimiento total, marcando en movdia y regresando saldos',
'mediante comparacion entre los saldos del movimiento y las fechas actual y',
'del movimiento, se decide si es una reversion retroactiva, o actual y ',
'si es parcial o total',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'BD : bdicred ',
'CLIENTE : CACSI';

CREATE PROCEDURE "informix".sp_administra_tarjetas_ppass(pEmpresa VARCHAR(3), pNumcte VARCHAR(20), pNumCredito VARCHAR(20),
														pNumTarjeta VARCHAR(20), pProducto VARCHAR(4), pEstatus VARCHAR(3),
														pOpcion SMALLINT, pSecuencia INTEGER, pNumEmpleado VARCHAR(8) DEFAULT "",
														pMotivoCancelacion VARCHAR(1) DEFAULT "")
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(20) 	AS cNumCte,
				CHAR(104)	AS cNombre,
				CHAR(13) 	AS cRFC,
				CHAR(13) 	AS cTelefono,
				CHAR(20) 	AS cNumCredito,
				CHAR(2) 	AS cEstatusCred,
				CHAR(20) 	AS cNumTarjetaPlat,
				CHAR(1) 	AS cEstatusTarPlat,
				CHAR(1) 	AS cEstatusTarPlatTit,
				CHAR(4) 	AS cProductoPlat,
				CHAR(1) 	AS cTipoTarjetaPlat,				
				CHAR(45) 	AS cDescripconPlat,
				CHAR(20)	AS cNumTarjetaPPass,
				CHAR(20)	AS cFechaVencimientoPPass,
				CHAR(1) 	AS cEstatusTarPPass,
				CHAR(16) 	AS cFolioCancelacion,
				CHAR(2) 	AS cCancelacionSecuencia;

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cNumCte CHAR(20);
DEFINE cNumCteAnt CHAR(20);
DEFINE cNombre CHAR(104);
DEFINE cRFC CHAR(13);
DEFINE cTelefono CHAR(13);
DEFINE cNumCredito CHAR(20);
DEFINE cNumCreditoAnt CHAR(20);
DEFINE cNumTarjetaPlat CHAR(20);
DEFINE cEstatusTarPlat CHAR(1);
DEFINE cEstatusTarPlatTit CHAR(1);
DEFINE cTipoTarjetaPlat CHAR(1);
DEFINE cProductoPlat CHAR(4);
DEFINE cDescripconPlat CHAR(45);
DEFINE cNumTarjetaPPass CHAR(20);
DEFINE cFechaVencimientoPPass CHAR(20);
DEFINE cEstatusTarPPass CHAR(1);
DEFINE cEstatusCred CHAR(2);
DEFINE cFolioCancelacion CHAR(16);
DEFINE iCancelacionSecuencia INTEGER;								 
DEFINE cCancelacionSecuencia CHAR(2);

LET sql_err = 0;
LET cCodRet = "000000";
LET cNumCte = "";
LET cNumCteAnt = "";
LET cNombre = "";
LET cRFC = "";
LET cTelefono = "";
LET cNumCredito = "";
LET cNumCreditoAnt = "";
LET cNumTarjetaPlat = "";
LET cProductoPlat = "";
LET cDescripconPlat = "";
LET cEstatusTarPlat = "";
LET cEstatusTarPlatTit = "";
LET cTipoTarjetaPlat = "";
LET cNumTarjetaPPass = "";
LET cFechaVencimientoPPass = "";
LET cEstatusTarPPass = "";
LET cEstatusCred = "";
LET cFolioCancelacion = "";
LET iCancelacionSecuencia = 0;
LET cCancelacionSecuencia = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet, ''), NVL(cNumCte, ''), NVL(cNombre, ''), NVL(cRFC, ''),NVL(cTelefono, ''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass, ''), NVL(cFechaVencimientoPPass, ''), NVL(cEstatusTarPPass, ''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_administra_tarjetas_ppass.out";
	--TRACE ON;

	IF pOpcion = 1 AND TRIM(pEmpresa) <> "" AND TRIM(pNumcte) <> "" AND TRIM(pProducto) <> "" THEN
		FOREACH
			SELECT
					tarjeta_plat.num_credito, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta, maecred.status_cred
				INTO
					cNumCredito, cEstatusTarPlat, cTipoTarjetaPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
				AND maecred.empresa = pEmpresa
				AND tarjeta_plat.numcte = pNumcte
				AND tarjeta_plat.prodtarjeta = pProducto
				ORDER BY tarjeta_plat.num_credito ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC,
				maecred.status_cred ASC
				
			LET cCancelacionSecuencia = "0";
			LET cEstatusTarPlatTit = "";
			LET cEstatusTarPPass = "";
			
			IF TRIM(cNumCredito) <> TRIM(cNumCreditoAnt) THEN
			
				FOREACH
					SELECT
							status_tar
						INTO
							cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = pNumcte
					AND num_credito = cNumCredito
					ORDER BY status_tar ASC, secuencia DESC
				END FOREACH;
			
				IF TRIM(cTipoTarjetaPlat) = "T" THEN
					LET cEstatusTarPlatTit = cEstatusTarPlat;
				ELSE
					FOREACH
						SELECT 
								LIMIT 1 status_tar
							INTO
								cEstatusTarPlatTit
						FROM "informix".sd_tarjeta
						WHERE prodtarjeta = pProducto
						AND num_credito = cNumCredito
						AND tipo_tarjeta = 'T'
						ORDER BY status_tar ASC, secuencia DESC
					END FOREACH;
				END IF;
				
				SELECT COUNT(*) INTO cCancelacionSecuencia
					FROM (SELECT numcte, num_credito 
							FROM "informix".sd_tarjeta_ppass
								WHERE num_credito = cNumCredito
								AND status_tar IN ('A','C','R','S')
								GROUP BY numcte, num_credito);
					
				RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
					NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
					NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
			END IF;
				
			LET cNumCreditoAnt = cNumCredito;
		END FOREACH;
	ELIF pOpcion = 2 AND TRIM(pNumCredito) <> "" THEN
		FOREACH
			SELECT 
					tarjeta_plat.numcte, tarjeta_plat.num_credito, tarjeta_plat.num_tarjeta, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta,
					tarjeta_plat.prodtarjeta, maecred.status_cred
				INTO
					cNumCte, cNumCredito, cNumTarjetaPlat, cEstatusTarPlat, cTipoTarjetaPlat,
					cProductoPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
			AND maecred.empresa = pEmpresa
			AND tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.prodtarjeta = pProducto
			ORDER BY tarjeta_plat.tipo_tarjeta DESC, tarjeta_plat.numcte ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC
							
			LET cCodRet = "000000";
			LET cDescripconPlat = "";
			LET cNombre = "";
			LET cRFC = "";			
			LET cTelefono = "";
			LET cNumTarjetaPPass = "";
			LET cFechaVencimientoPPass = "";
			LET cEstatusTarPPass = "";
			LET cEstatusTarPlatTit = "";
			
			IF TRIM(cNumCteAnt) <> TRIM(cNumCte) THEN
			
				FOREACH
					SELECT 
							numtarjeta_ppass, CAST(expiracion AS CHAR(10)), status_tar
						INTO
							cNumTarjetaPPass, cFechaVencimientoPPass, cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = cNumCte
					AND num_credito = pNumCredito
					ORDER BY status_tar ASC
				END FOREACH;
			
				IF TRIM(cEstatusTarPlatTit) = "" THEN
					IF TRIM(cTipoTarjetaPlat) = "T" THEN
						LET cEstatusTarPlatTit = cEstatusTarPlat;
					ELSE
						FOREACH
							SELECT 
									LIMIT 1 status_tar
								INTO
									cEstatusTarPlatTit
							FROM "informix".sd_tarjeta
							WHERE prodtarjeta = pProducto
							AND num_credito = cNumCredito
							AND tipo_tarjeta = 'T'
							ORDER BY status_tar ASC, secuencia DESC
						END FOREACH;
					END IF;
				END IF;
			
				SELECT num_producto || ' ' || nombre_prod INTO cDescripconPlat
				FROM "informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cProductoPlat;

				SELECT
						REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
					INTO
						cNombre, cRFC
				FROM bdinteg: "informix".si_cliente WHERE numcte = cNumCte;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = "000003";
				ELSE				
					SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = cNumCte AND tipo_tel = '1' AND secuencia = (
						SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
							WHERE NUMCTE = cNumCte
							AND tipo_tel = '1');
							
						RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
						NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
						NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
				END IF;
				
				LET cNumCteAnt = cNumCte;
			END IF;

		END FOREACH;
	ELIF pOpcion = 3 AND TRIM(pEmpresa) <> "" THEN
		IF TRIM(pNumTarjeta) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			END IF;	
			
		ELIF TRIM(pNumCredito) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_credito = pNumCredito
				AND tipo_tarjeta = 'T'
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000003";
			END IF;	
		END IF;			
		
	ELIF pOpcion = 4 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" THEN
		UPDATE "informix".sd_tarjeta_ppass 
		SET status_tar = pEstatus 
		WHERE numtarjeta_ppass = pNumTarjeta;
		
	ELIF pOpcion = 5 AND TRIM(pNumTarjeta) <> "" THEN
		SELECT {+INDEX(bdicred: sd_tarjeta_ppass idx_sd_tarjeta_ppass)} status_tar INTO cEstatusTarPPass 
		FROM "informix".sd_tarjeta_ppass 
			WHERE num_credito IS NOT NULL AND num_tarjeta IS NOT NULL AND numtarjeta_ppass = pNumTarjeta AND secuencia IS NOT NULL;
			
	ELIF pOpcion = 6 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" AND TRIM(pNumEmpleado) <> "" THEN 
			LET cFolioCancelacion = TRIM(pNumEmpleado) || TRIM(TO_CHAR(TODAY,'%d%m%y'));
			
			SELECT COUNT(*) INTO iCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE SUBSTR(folio_canc, 1,14) = cFolioCancelacion;

			LET iCancelacionSecuencia = iCancelacionSecuencia + 1;
			LET cFolioCancelacion = TRIM(cFolioCancelacion) || LPAD(iCancelacionSecuencia, 2, '0');
			
			UPDATE "informix".sd_tarjeta_ppass 
			SET status_tar = pEstatus, folio_canc = cFolioCancelacion, motivo_canc = pMotivoCancelacion
			WHERE numtarjeta_ppass = pNumTarjeta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			ELSE
				UPDATE "informix".sd_inven_tarppass 
				SET status_tar = pEstatus, desc_status = "CANCELADA", fecha_modif = CURRENT
				WHERE numtarjeta_ppass = pNumTarjeta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					UPDATE "informix".sd_tarjeta_ppass 
					SET status_tar = 'A', folio_canc = '', motivo_canc = ''
					WHERE numtarjeta_ppass = pNumTarjeta;
				END IF;
				
			END IF;
	ELIF pOpcion = 7 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		IF pSecuencia = 1 THEN		
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass tarjeta_ppass
			INNER JOIN "informix".sd_tarjeta tarjeta_plat
				ON tarjeta_ppass.numcte = tarjeta_plat.numcte
					AND tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				WHERE tarjeta_ppass.num_credito = pNumCredito
				AND tarjeta_ppass.status_tar IN ('A','C','R','S')
				AND tarjeta_plat.status_tar = 'A';
		ELSE
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE num_credito = pNumCredito
				AND status_tar = 'A';
		END IF;				
	ELIF pOpcion = 8 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		SELECT COUNT(*) INTO cCancelacionSecuencia
		FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_tarjeta_ppass tarjeta_ppass
			ON tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				AND tarjeta_ppass.numcte = tarjeta_plat.numcte
			WHERE tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.tipo_tarjeta <> 'T'
			AND tarjeta_plat.numcte = pNumcte
			AND tarjeta_ppass.tipo_tarjeta <> 'T'
			AND tarjeta_ppass.status_tar IN ('A','C','R','S');
			
	ELIF pOpcion = 9 THEN
		FOREACH
			SELECT
					LIMIT 1 numtarjeta_ppass
				INTO
					cNumTarjetaPPass
			FROM "informix".sd_inven_tarppass
				WHERE status_tar = 'S'
				ORDER BY id_tar_ppass ASC
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			ELSE
				IF pSecuencia = 1 THEN
					UPDATE "informix".sd_inven_tarppass 
					SET status_tar = 'A', desc_status = 'ACTIVA', fecha_modif = CURRENT
					WHERE numtarjeta_ppass = cNumTarjetaPPass;
				END IF;
			END IF;
		END FOREACH;
	ELIF pOpcion = 10 THEN
		UPDATE "informix".sd_inven_tarppass 
			SET status_tar = 'S', desc_status = 'SIN ASIGNAR', fecha_modif = CURRENT
			WHERE numtarjeta_ppass = pNumTarjeta;
	ELIF pOpcion = 11 AND TRIM(pNumcte) <> "" THEN
	
		SELECT
				REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
			INTO
				cNombre, cRFC
		FROM bdinteg: "informix".si_cliente WHERE numcte = pNumcte;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "000003";
		ELSE				
			SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = pNumcte AND tipo_tel = '1' AND secuencia = (
				SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
					WHERE NUMCTE = pNumcte
					AND tipo_tel = '1');
					
				RETURN NVL(cCodRet,''), NVL(pNumcte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND pOpcion <> 3 THEN
		LET cCodRet = "000002";
	END IF;

	IF ((pOpcion = 1 OR pOpcion = 2) AND cCodRet != "000000") OR pOpcion > 2 THEN
		RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
			NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
			NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrián Eduardo Lizárraga Cázares',
'BD: bdicred',
'Fecha: 2019-11-06',
'Descripción: Se genera procedimiento para administrar las tarjetas Priority Pass',
'Solicitó: Rodolfo Gomez Hernandez',
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrián Eduardo Lizárraga Cázares',
'BD: bdicred',
'Fecha: 2020-01-27',
'Descripción: Se modifica procedimiento almacenado para extraer los datos generales del Cliente desde el aplicativo pl004064.exe',
'Solicitó: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_consulta_accesos_ppass(pNumTarjeta VARCHAR(20), pMesAcceso VARCHAR(7), pSecuencia INTEGER)
	
	RETURNING CHAR(6)  AS cCodRet,
			  CHAR(10) AS cFechaVisita,
			  CHAR(20) AS cNumTarjetaPPas,
			  CHAR(69) AS cPaisSalon,
			  CHAR(11) AS cTotalVisistasTi,
		      CHAR(11) AS cTotalVisitasAdic,
			  CHAR(11) AS cTotalvisitas,
			  CHAR(11) AS cNumVisitasSCost,
			  CHAR(11) AS cNumVisFact,
			  CHAR(25) AS dTotalAPagar;
	
	DEFINE sql_err 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cCategoria 			CHAR(1);
	DEFINE iAccGratis 			INTEGER;
	DEFINE cFechaVisita 		CHAR(10);
	DEFINE cNumTarjetaPPass 	CHAR(20);
	DEFINE cPaisSalon 			CHAR(69);
	DEFINE cTotalVisistasTi 	CHAR(11);
	DEFINE cTotalVisitasAdic	CHAR(11);
	DEFINE cTotalvisitas		CHAR(11);
	DEFINE cNumVisitasSCost 	CHAR(11);
	DEFINE cNumVisFact 			CHAR(11);
	DEFINE dTotalAPagar 		DECIMAL(18,4);
	DEFINE cCostoAcceso 		CHAR(3);

	LET sql_err				= 0;
	LET cCodRet 			= '000000';
	LET cCategoria 			= '';
	LET iAccGratis 			= 0;
	LET cFechaVisita 		= '';
	LET cNumTarjetaPPass 	= '';
	LET cPaisSalon 			= '';
	LET cTotalVisistasTi 	= '';
	LET cTotalVisitasAdic 	= '';
	LET cTotalvisitas 		= '';
	LET cNumVisitasSCost 	= '';
	LET cNumVisFact 		= '';
	LET dTotalAPagar 		= 0.0;
	LET cCostoAcceso 		= '';


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Jesus/sp_consulta_movimientos_ppass.out';
		--TRACE ON;
		
		SELECT FIRST 1 categoria 
		INTO cCategoria
		FROM "informix".sd_tarjeta_ppass
		WHERE numtarjeta_ppass = pNumTarjeta; 	

		SELECT acceso_gratis 
		INTO iAccGratis
		FROM "informix".catcategoriappass
		WHERE id_categoria = cCategoria;		
		
		IF  dbinfo("sqlca.sqlerrd2") = 0 THEN			
			LET cCodRet = '000003';
		ELSE
		
			SELECT valor 
			INTO cCostoAcceso
			FROM "informix".sd_param 
			WHERE cod_param = '074';
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN				
				LET cCodRet = '000004';				
			END IF;
		END IF;
		
		IF TRIM(pNumTarjeta) <> "" AND TRIM(pMesAcceso) <> "" THEN
			
				FOREACH
						SELECT SKIP pSecuencia
						TO_CHAR(A.fecha_visita, '%d/%m/%Y') AS fecha_visita,
						TO_CHAR(numtarjeta_ppass) AS num_tarjeta,
						TO_CHAR(id_pais_visita || '  ' || nombre_lounge) AS pais_salon, 
						TO_CHAR(A.totalpp_deslizada) AS vis_titular,
						TO_CHAR(A.total_invitados) AS vis_Adic,
						TO_CHAR(A.total_visitas) AS vis_total, 
						TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE iAccGratis END)) AS vi_sinc,
						TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END)) AS vi_fact, 
						TO_CHAR(((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END) * 
						NVL((SELECT precio_venta FROM bdinteg: "informix".si_histdiv WHERE fecha_tc = A.fecha_visita AND divisa = '02' 
						AND hora_tc = (SELECT MAX(hora_tc) FROM bdinteg: "informix".si_histdiv 
						WHERE fecha_tc = A.fecha_visita AND divisa = '02')), 0) * cCostoAcceso )) AS total_facturable
						
						INTO cFechaVisita, cNumTarjetaPPass, cPaisSalon, cTotalVisistasTi, cTotalVisitasAdic,
						cTotalvisitas, cNumVisitasSCost, cNumVisFact, dTotalAPagar
						
						FROM "informix".sd_movmes_ppass AS A 
						WHERE A.numtarjeta_ppass = pNumTarjeta 
						AND MONTH(A.fecha_visita) = SUBSTRB(pMesAcceso, 1, 2) AND YEAR(A.fecha_visita) = SUBSTRB(pMesAcceso, 4, 4)
						ORDER BY A.fecha_visita ASC
					
					RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
					NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'') WITH RESUME;

				END FOREACH;

		ELSE 
			LET cCodRet = '000001';
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
			LET cCodRet = "000002";
		END IF;

		IF TRIM(cCodRet) <> "000000" THEN
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
		END IF;


	END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar las visitas que el Cliente ha realizado con su tarjeta Priority Pass en un plazo',
'			  no mayor a 12 meses y con un rango de bÃºsqueda de 32 dÃ­as',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_catcausapp(pSecuencia INTEGER)
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(11)	AS cID,
	            CHAR(1)		AS cCausa,
	            CHAR(25)	AS cDescripcion;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE cID					CHAR(11);
DEFINE cCausa 				CHAR(1);
DEFINE cDescripcion 		CHAR(25);

LET sql_err					= 0;
LET cCodRet 				= "000000";
LET cID						= "";
LET cCausa 					= "";
LET cDescripcion 			= "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_catcausapp.out";
	--TRACE ON;


	FOREACH 
		SELECT SKIP pSecuencia 
				id_causa, causa, descripcion
			INTO
				cID, cCausa, cDescripcion
		FROM "informix".catcausapp
		ORDER BY id_causa ASC
		
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'') WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000002";
	END IF;

	IF cCodRet <> "000000" THEN
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-26',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar los motivos de cancelaciÃ³n para las tarjetas Priority Pass',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_info_layout_ppass(pEmpresa VARCHAR(3), pNumTarPPassAnt VARCHAR(20), pNumTarPPassNue VARCHAR(20), pNumTarPlat VARCHAR(20), pNumCredito VARCHAR(20),
												 pNumCte VARCHAR(20), pSucursal VARCHAR(4), pEstatusLayout VARCHAR(1), pDestino VARCHAR(1), pBusquedaSuc VARCHAR(20),
												 pOpcion INTEGER, pSecuencia INTEGER)
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(4)		AS cNumeroSucursal,
	            CHAR(40)	AS cNombreSucursal,
	            CHAR(40)	AS cDireccionSucursal,
	            CHAR(40)	AS cColoniaSucursal,
	            CHAR(30)	AS cEstadoSucursal;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE cNumeroSucursal		CHAR(4);
DEFINE cNombreSucursal		CHAR(40);
DEFINE cDireccionSucursal	CHAR(40);
DEFINE cColoniaSucursal		CHAR(40);
DEFINE cEstadoSucursal		CHAR(30);
DEFINE iId_Reg				INTEGER;
DEFINE dFechaAperturaCred	DATE;
DEFINE cNombreTarjeta		CHAR(50);
DEFINE cNombre				CHAR(25);
DEFINE cApellidoPat			CHAR(25);
DEFINE dFechaExp			DATE;
DEFINE cDireccion1			CHAR(40);
DEFINE cDireccion2			CHAR(40);
DEFINE cNumCiudad			CHAR(3);
DEFINE cCiudad				CHAR(3);
DEFINE cNumEstado			CHAR(2);
DEFINE cCalle				CHAR(40);
DEFINE cColonia				CHAR(60);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE cDireccionRecepcion  CHAR(150);
DEFINE cNombreEstado 		CHAR(30);
DEFINE cNombreCiudad 		CHAR(60);
DEFINE cBusquedaSuc 		CHAR(22);
DEFINE iNumCalle 			INTEGER;
DEFINE iNumColonia 			INTEGER;
DEFINE iNumeroExtCalle		INTEGER;


LET sql_err					= 0;
LET cCodRet 				= '000000';
LET cNumeroSucursal 		= '';
LET cNombreSucursal 		= '';
LET cDireccionSucursal 		= '';
LET cColoniaSucursal 		= '';
LET cEstadoSucursal 		= '';
LET iId_Reg 				= 0;
LET dFechaAperturaCred 		= NULL;
LET cNombreTarjeta	 		= '';
LET cNombre	 				= '';
LET cApellidoPat	 		= '';
LET dFechaExp		 		= NULL;
LET cDireccion1				= '';
LET cDireccion2				= '';
LET cNumCiudad				= '';
LET cCiudad					= '';
LET cNumEstado				= '';
LET cCalle					= '';
LET cColonia				= '';
LET cTipoTarjeta			= '';
LET cDireccionRecepcion		= '';
LET cNombreEstado			= '';
LET cNombreCiudad			= '';
LET cBusquedaSuc			= '';
LET iNumCalle				= 0;
LET iNumColonia				= 0;
LET iNumeroExtCalle			= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
			TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_info_layout_ppass.out";
	--TRACE ON;
	
	IF pOpcion = 1 THEN
		IF TRIM(pEmpresa) != "" THEN
			LET cBusquedaSuc = '%' || TRIM(pBusquedaSuc) || '%';
			FOREACH
				SELECT SKIP pSecuencia
							suc.sucursal, suc.nombre, suc.direccion1, suc.direccion2, est.nombre
					INTO
						cNumeroSucursal, cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				WHERE suc.nombre LIKE cBusquedaSuc OR suc.direccion1 LIKE cBusquedaSuc OR suc.direccion2 LIKE cBusquedaSuc
				AND suc.empresa = pEmpresa
				AND suc.tpo_sucursal = 'S'
				ORDER BY est.nombre ASC, suc.nombre ASC
					
				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
				TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,'')) WITH RESUME;
			END FOREACH
		ELSE
			LET cCodRet = "000001";
		END IF;
	ELIF pOpcion = 2 THEN
		IF TRIM(pNumCredito) != "" AND TRIM(pNumCte) != "" AND TRIM(pEmpresa) != "" AND TRIM(pNumTarPlat) != "" AND TRIM(pSucursal) != "" THEN
			SELECT
					MAX(id_reg) + 1
				INTO
					iId_Reg
			FROM "informix".sd_info_layout_ppass;
			
			LET iId_Reg = NVL(iId_Reg, 0);
			
			SELECT
					fecha_apertura
				INTO
					dFechaAperturaCred
			FROM "informix".sd_maecred
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito;
				
			SELECT
					nombretarjeta
				INTO
					cNombreTarjeta
			FROM intercard:"informix".solicitudtarjeta
				WHERE numcliente = pNumCte
				AND numcuenta = pNumCredito;
					
			LET cNombreTarjeta = TRIM(NVL(cNombreTarjeta, ""));
					
			SELECT
					nombre1, apell_paterno
				INTO
					cNombre, cApellidoPat
			FROM bdinteg: "informix".si_cliente
				WHERE empresa = pEmpresa
				AND numcte = pNumCte;
					
			LET cNombre = TRIM(NVL(cNombre, ""));
			LET cApellidoPat = TRIM(NVL(cApellidoPat, ""));
			
			SELECT
					tipo_tarjeta, expiracion
				INTO
					cTipoTarjeta, dFechaExp
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_credito = pNumCredito
				AND num_tarjeta = pNumTarPlat
				AND numcte = pNumCte;
					
			IF pSucursal = '9999' THEN
				FOREACH
					SELECT LIMIT 1
							numeroextcalle, numerocalle, numerocolonia, ciudad, numerociudad, estado
						INTO
							iNumeroExtCalle, iNumCalle, iNumColonia, cCiudad, cNumCiudad, cNumEstado
					FROM bdinteg: "informix".si_direcciones_actual
						WHERE numcte = pNumCte
						AND tipo_dir = 1
						ORDER BY secuencia DESC
						
					SELECT
							nombrezona
						INTO
							cColonia 
					  FROM bdinteg: "informix".si_catzonas
					 WHERE numerociudad = cNumCiudad 
					   and numerocolonia  = iNumColonia;

					SELECT
							nombrecalle
						INTO
							cCalle
					  FROM bdinteg: "informix".si_catcalles
					 WHERE numerocalle = iNumCalle;
						
					SELECT
							nombre
						INTO
							cNombreEstado
					  FROM bdinteg: "informix".si_estados
					 WHERE estado = cNumEstado;
					
					SELECT 
							nombre
						INTO
							cNombreCiudad
					  FROM bdinteg: "informix".si_ciudades
					 WHERE estado = cNumEstado 
					   AND ciudad = cCiudad;
						
					LET cDireccionRecepcion = TRIM(cCalle) || ' ' || iNumeroExtCalle || ', ' || TRIM(cColonia) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
				END FOREACH;
			ELSE
				SELECT 
						direccion1, direccion2, ciudad, estado
					INTO
						cDireccion1, cDireccion2, cNumCiudad, cNumEstado
					FROM bdinteg: "informix".si_sucursales
					WHERE sucursal = pSucursal
					AND empresa = pEmpresa
					AND tpo_sucursal = 'S';
					
				SELECT
						nombre
					INTO
						cNombreEstado
				  FROM bdinteg: "informix".si_estados
				 WHERE estado = cNumEstado;
				
				LET cNombreEstado = TRIM(NVL(cNombreEstado, ""));
				
				SELECT 
						nombre
					INTO
						cNombreCiudad
				  FROM bdinteg: "informix".si_ciudades
				 WHERE estado = cNumEstado 
				   AND ciudad = cNumCiudad;
				   
				  LET cNombreCiudad = TRIM(NVL(cNombreCiudad, ""));
					
				LET cDireccionRecepcion = TRIM(cDireccion1) || ', ' || TRIM(cDireccion2) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
			END IF;
			
			INSERT INTO "informix".sd_info_layout_ppass (id_reg, pan, miembro_desde, nombrecompleto, nombre_cte, apellido_cte, numcte, fecha_exp, sucursal, direccion, tipo, estatus_layout, destino, fecha_insert, usuario_modif)
			VALUES (iId_Reg, pNumTarPPassNue, dFechaAperturaCred, cNombreTarjeta, cNombre, cApellidoPat, pNumCte, dFechaExp, pSucursal, cDireccionRecepcion, cTipoTarjeta, pEstatusLayout, pDestino, CURRENT, 'informix');
			
			IF dbinfo("sqlca.sqlerrd2") > 0 THEN
				IF TRIM(pDestino) = "C" THEN
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'A', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				ELSE
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'S', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				END IF;
			ELSE
				LET cCodRet = "000002";
			END IF;
					
		ELSE
			LET cCodRet = "000001";
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
		LET cCodRet = "000002";
	END IF;

	IF cCodRet <> "000000" OR pOpcion = 2 THEN
		RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
		TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera Procedimiento Almacenado (SP) para realizar la funcionalidad de reposiciÃ³n de tarjetas Priority Pass',
'SolicitÃ³: Rodolfo Gomez Hernandez',
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2020-02-13',
'DescripciÃ³n: Se modifica procedimiento a peticiÃ³n del Cliente para que la tarjeta PPass quede activa cuando el Cliente la solicite',
'			  a domicilio, ademÃ¡s, se le agrega el campo Estado a la direcciÃ³n de la sucursal.',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_rep_cartera_activa_clon(pEmpresa char(3))
returning 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
--************************ Definicion de variables *****************************
    define iSql_err                  integer;
    define cSql                      char(2080);
    define dPrimerDiaMes             date;
    define dUltimoDiaMesAnterior             date;
    define cNumCte                   char(20);
    define cNum_Credito              char(20);
    define cCreditoREES              char(20);
    define cStatus_CreditoREES       char(20);
    define cStatus_Credito           char(15);
    define cHit                      char(6);
    define dFecha_Nac                date;
    define cRfc                      char(13);
    define cSexo                     char(10);
    define cEstado_Civil             char(15);
    define cEmail                    char(70);
    define cNumeroEstado             char(2);
    define cNombreEstado             char(30);
    define sNumeroCiudad, sNumeroCiudadCpl smallint;
    define cNombreCiudad, cNombreCiudadCpl char(30);
    define iNumeroColonia            integer; 
    define cMunicipioZona            char(27);   
    define cTelefono1                char(13);           
    define cTelefono2                char(13);      
    define cTelefono3                char(13);     
    define cExtension                char(5);       
    define mIngreso_Mensual          money;     
    define cSucursal, cNum_Producto  char(4);    
    define cTiempo_Ocupacion_Act     char(50);     
    define dUltima_Disposicion       date;                        
    define dUltimo_Movimiento        date;                         
    define dUltimo_Vencido           date;               
    define cTipo_Ult_Mov             char(3);
    define dultimo_pago              date;
    define dSaldo_Actual             decimal(18,2);     
    define dSaldo_Vencido            decimal(18,2);     
    define dSdo_Capital              decimal(18,2);     
    define dMonto_Vencido            decimal(18,2);     
    define dMto_Venc_Trasp           decimal(18,2);     
    define dCap_Tras_No_Venci        decimal(18,2);     
    define dSaldo_Cierre             decimal(18,2);     
    define dMeses_Vencidos           decimal(18,2);     
    define cNum_Tarjeta              char(20);           
    define cNumCte_Ref               char(20);            
    define dFecha_Apertura           date;     
    define dSituacion_Pago           decimal(5,2);     
    define sMeses_Historia           smallint;
    define dfecha_hoy                date;
    define cMensajeRet               char(80);
    define cCodRet,vvcCod_ret        char(6); 
	define cCod_ret2				 char(6);
    define cNum_dia                  char(02);
    define cNum_mes                  char(02);
    define cNum_anio,cProceso        char(04);
    define dFechaVtaRees             date;
    define dFecha                    date;
    define contador_commit INTEGER;
    define sCommit      SMALLINT;
    define actualiza_esta integer;
    define cTipoReporte             char(02);
    define dUltDisp_atm             date;
    define dUltDisp_pos             date;
    define dUltDisp_vnt             date;
    define vCurrent                 char(25);
    define vdia                     char(10);
    define vhora                    char(8);
    define vHora3                   char(22); 
    define cPaso                    char(01); 
	define cMotivo					char(5);
	
	DEFINE dEvaluacion1        decimal(18,2);
	DEFINE dEvaluacion2         decimal(18,2);
	DEFINE dEvaluacion3         decimal(18,2);
	DEFINE dEvaluacion4         decimal(18,2);
	DEFINE dEvaluacion5         decimal(18,2);
	DEFINE cStatus_Ini CHAR(2);
	DEFINE cRevisado CHAR(2);
	DEFINE cIdbox smallint;
	DEFINE cIfe CHAR(2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dMontoPagos  		decimal(18,2);
	DEFINE cGrupo				CHAR(2);
	DEFINE sFlag2creditoicc		SMALLINT;
	
	-- RQM 09 476 - 2 ADENDUM 
	DEFINE dLineaOrigen			decimal(18,2);
	DEFINE dLineaActual			decimal(18,2);
	DEFINE iSolicitudOS			integer;
	DEFINE iSolicitudOS_Gpo5	integer;
	DEFINE iSolicitudOS_P		integer;
	DEFINE iMarcaOS				integer;
	DEFINE cTipoFac				char(1);
     
	SET DEBUG FILE TO "/tmp/sp_rep_cartera_activa_clon.out";
	TRACE ON;
	
    let iSql_err = 0;
    let cSql    = '';
    let cNumCte = '';
    let	cNum_Credito = '';
    let cNum_Credito = '';
    let cCreditoREES = '';
    let	cStatus_Credito	= '';
    let cHit = '';
    let dFecha_Nac = DATE(1);
    let cRfc = '';
    let cSexo ='';
    let cEstado_Civil = '';
    let cEmail = '';
    let cNumeroEstado = '';
    let cNombreEstado = '';
    let sNumeroCiudad = 0;
    let cNombreCiudad = '';
    let sNumeroCiudadCpl = 0;
    let cNombreCiudadCpl = '';
    let iNumeroColonia = 0;
    let cMunicipioZona = '';
    let cTelefono1 = '';
    let cTelefono2 = '';
    let cTelefono3 = '';
    let cExtension = '';
    let cSucursal = '';
    let cTiempo_Ocupacion_Act = '';
    let dUltima_Disposicion = DATE(1);
    let dUltimo_Movimiento = DATE(1);
    let dUltimo_Vencido = ' ';
    let cTipo_Ult_Mov = '';
    let dUltimo_pago = DATE(1);
    let dSaldo_Actual = 0.0;
    let dSaldo_Vencido = 0.0;
    let dSdo_Capital = 0.0;
    let dMonto_Vencido = 0.0;
    let dMto_Venc_Trasp = 0.0;
    let dCap_Tras_No_Venci = 0.0;
    let dSaldo_Cierre = 0.0;
    let dMeses_Vencidos = 0.0;
    let cNum_Tarjeta = '';
    let cNumCte_Ref = '';
    let dFecha_Apertura = DATE(1);
    let dSituacion_Pago = 0.0;
    let sMeses_Historia = 0;
    let dFecha_hoy = DATE(1);
    let dPrimerDiaMes = DATE(1);
    let dUltimoDiaMesAnterior = DATE(1);
    let cMensajeRet= 'El reporte de CARTERA ACTIVA se realizo correctamente';
    let cCodRet    = '000000';
	let cCod_ret2  = '000000';
    let cNum_dia   = '';
    let cNum_mes   = '';
    let cNum_anio  = '';
    let dFechaVtaRees  = DATE(1);
    let dFecha         = DATE(1);
    let contador_commit = 0;
    let sCommit         = 0;
    let actualiza_esta = 0;
    let cTipoReporte = '';
    let cProceso = '0033';
    let vvcCod_ret = '';
    let mIngreso_Mensual = 0;
    let dUltDisp_atm = date(1); let dUltDisp_pos = date(1); let dUltDisp_vnt = date(1);
    let vCurrent = ''; let vdia = '';   let vhora = '';  let vHora3 = '';
    let cPaso = '';  LET cNum_Producto = '';
	let cMotivo = '';
	
	let dEvaluacion1        =0;
	let dEvaluacion2        =0;
	let dEvaluacion3        =0;
	let dEvaluacion4        =0;
	let dEvaluacion5        =0;
	LET cStatus_Ini = "";
	LET cRevisado = "";
	LET cIdbox = 0;
	LET cIfe = "";
	LET iNumPagos			= 0;
	LET dMontoPagos			= 0;
	LET cGrupo				= '';
	LET sFlag2creditoicc	= 0;
	
	-- RQM 09 476 - 2 ADENDUM 
	LET dLineaOrigen		= 0.00;
	LET dLineaActual		= 0.00;
	LET iSolicitudOS		= 0;
	LET iSolicitudOS_Gpo5	= 0;
	LET iSolicitudOS_P		= 0;
	LET iMarcaOS			= 0;
	LET cTipoFac			= '';
	
--**************************** Control de errores ******************************
    begin
    on exception set iSql_err
		if iSql_err <> 0 then
           let cCodRet= iSql_err;
           let cMensajeRet= 'ERROR en la ejecucion del reporte de CARTERA ACTIVA' || cNum_Credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '02') returning cCod_ret2;
--           SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
           return cCodRet,cMensajeRet;
		end if;
	end exception;


    SELECT today, current INTO vdia, vCurrent 
      FROM systables
      where tabid=1;

      LET vhora = vCurrent[12,19];      


--*************************** Programa principal *******************************
    set isolation to dirty read;
    set lock mode to wait 3;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '01') returning cCod_ret2;	
	
    select fecha_hoy, pri_dia_mes into dFecha_hoy,dPrimerDiaMes from bdicred:sd_fechas where empresa = pEmpresa;

--temporal para pruebas
   --let dFecha_hoy = mdy('11','01','2018');
   --let dPrimerDiaMes = mdy('11','01','2018');
--temporal para pruebas

    let dUltimoDiaMesAnterior = dPrimerDiaMes - 1 units day;
    let dPrimerDiaMes = dPrimerDiaMes - 1 units month;								

    let cNum_dia  = lpad(DAY(dUltimoDiaMesAnterior),2,'0');
    let cNum_mes  = lpad(MONTH(dUltimoDiaMesAnterior),2,'0');
    let cNum_anio = lpad(YEAR(dUltimoDiaMesAnterior),4,'0');
 
/* 
    IF NOT EXISTS (select idxname from sysindices where idxname='idx_numcredito_repcartactiva') THEN
       CREATE INDEX idx_numcredito_repcartactiva on bdicred:"informix".sd_rep_cartera_activa(fecha,tipo_reporte,num_credito);
    END IF;
*/
    select valor into cPaso from bdicred:sd_param where cod_param = '079' and empresa = pEmpresa;

    select first 1 fecha into dFecha from bdicred:"informix".sd_rep_cartera_activa WHERE fecha > DATE(1);

    IF dFecha != dUltimoDiaMesAnterior THEN
        truncate table "informix".sd_rep_cartera_activa;
    END IF;
    
IF cPaso = '1' THEN
    select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcont 
     where fecha = dUltimoDiaMesAnterior 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
	   and empresa = pEmpresa 
       and campo_trab3 <> 'BAJA'
     into temp paso_maecredcont with no log; 

    CREATE INDEX idx_paso_maecredcont on paso_maecredcont (fecha, empresa, num_credito); 
    
	
    FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, nvl(h.grupo,'')
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcont a
              join bdicred:sd_maesdoscont i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
				
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos,linea_origen,linea_actual,marca_os,tipo_facturacion)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos,dLineaOrigen,dLineaActual,iMarcaOS,cTipoFac);
          COMMIT WORK;
    
    END FOREACH;
	---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
	
	select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcontcrd
     where fecha = dUltimoDiaMesAnterior and empresa = pEmpresa 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
       and campo_trab3 <> 'BAJA'
	   and num_producto ='6900'
     into temp paso_maecredcontcrd with no log; 

    CREATE INDEX idx_paso_maecredcontcrd on paso_maecredcontcrd (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE "informix".paso_maecredcontcrd;
	
	
	
	 FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, h.grupo
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcontcrd a
              join bdicred:sd_maesdoscontcrd i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
    
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos);
          COMMIT WORK;
    
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='2'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '2';
END IF;

IF cPaso = '2' THEN
    FOREACH WITH HOLD
        select  'CV' tipo_reporte,a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, a.sucursal,
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_actual,
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido,
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 0 saldo_cierre,
             i.mto_fin_ven_trasp meses_vencidos, --j.num_tarjeta, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto
         from bdicred:sd_maecred_vendida a
              join bdicred:sd_maesdos_vendida i on (a.fecha = i.fecha and a.empresa = i.empresa and a.num_credito = i.num_credito)
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
        where a.fecha between dPrimerDiaMes and dUltimoDiaMesAnterior and a.empresa = pEmpresa and a.num_credito>=''
          and a.num_credito in (select num_credito from bdicred:"informix".sd_maecred where empresa=pEmpresa and num_credito=a.num_credito and status_cred='CV') 
          and a.num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
			
          BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia,cMotivo);
          COMMIT WORK;
  
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='3'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '3';
END IF;

IF cPaso = '3' THEN
    UPDATE statistics medium FOR TABLE "informix".sd_rep_cartera_activa;

    FOREACH WITH HOLD

--        select {+INDEX(bdicred:sd_rep_cartera_activa sd_repcartera_activa1)} tipo_reporte, numcte, num_credito 
        select tipo_reporte, numcte, num_credito 
          INTO cTipoReporte, cNumCte, cNum_Credito  
	        from "informix".sd_rep_cartera_activa 
           where fecha = dUltimoDiaMesAnterior
             and (sexo is null or sexo = '')
         
         select nvl(a.correo_elec,'')  into cEmail 
           from bdinteg:si_correos a
          where a.empresa = pEmpresa
            and a.numcte = cNumCte
            and a.secuencia = (select max(secuencia) from bdinteg:si_correos where empresa = a.empresa and numcte = a.numcte); 

         select c.fecha_nac, b.rfc, (case when c.sexo = 'M' then 'MASCULINO' else 'FEMENINO' end) sexo, 
               (case when c.estado_civil = 'C' then 'Casado' else
                case when c.estado_civil = 'D' then 'Divorciado' else
                case when c.estado_civil = 'S' then 'Soltero' else
                case when c.estado_civil = 'U' then 'Union Libre' else 'Viudo' end end end end) estado_civil,
                b.numcte_ref
             into dFecha_Nac, cRfc, cSexo, cEstado_Civil, cNumCte_Ref
            from bdinteg:si_cliente b 
            left outer join bdinteg:si_ctepf c on (c.numcte = b.numcte)
            where b.numcte = cNumCte;

         select a.num_tarjeta into cNum_Tarjeta
           from bdicred:sd_tarjeta a
          where a.empresa = pEmpresa 
            and a.num_credito = cNum_Credito
            and a.tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
    	                                                 where empresa = a.empresa and num_credito = a.num_credito and tipo_tarjeta = 'T');

         select limit 1 d1.estado, e.nombre, d1.numerociudad CdCpl, catcd.nombreciudad NomCdCpl, d1.ciudad NumCdBcpl,cds.nombre NomCdBcpl,d1.numerocolonia, g.municipiozona,
                nvl(tel1.telefono,''), nvl(tel2.telefono,''), nvl(tel3.telefono,''), nvl(tel3.extension,'')
           into cNumeroEstado, cNombreEstado, sNumeroCiudadCpl, cNombreCiudadCpl, sNumeroCiudad, cNombreCiudad, iNumeroColonia,
                cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension 
           from bdinteg:si_direcciones_actual d1 
                left outer join bdinteg:si_direcciones_actual d2 on (d2.numcte = d1.numcte and d2.tipo_dir = '2')
                left outer join bdinteg:si_estados e on (e.estado = d1.estado)
                left outer join bdinteg:si_catciudades catcd on (catcd.numerociudad = d1.numerociudad )
                left outer join bdinteg:si_ciudades cds on (cds.estado = d1.estado and cds.ciudad_coppel = d1.numerociudad and cds.ciudad = d1.ciudad)
                left outer join bdinteg:si_catzonas g on (g.numerociudad = d1.numerociudad and g.numerocolonia = d1.numerocolonia)
                Left outer join bdinteg:si_telefonos_actual tel1 on tel1.numcte= d1.numcte 
                     and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 1 and cofetel ='V')
                     and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel2 on tel2.numcte= d1.numcte 
                     and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 2 and cofetel ='V')
                     and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel3 on tel3.numcte= d1.numcte 
                     and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 3 and cofetel ='V')
                     and tel3.tipo_tel = 3 and tel3.cofetel ='V'    
          where d1.numcte = cNumCte
            and d1.tipo_dir = '1';
 /*
     select fecha_ult_pago,fecha_vencto into dUltimo_pago,dUltimo_Vencido from bdicred:sd_maecredanexo where empresa = pEmpresa and num_credito = cNum_Credito ;

     if dUltimo_pago is null then let dUltimo_pago = ''; end if;
     if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
 */
    -- obtener la ocupacion actual
         select sel.descripcion into cTiempo_Ocupacion_Act from bdisolic:ss_detalle_scoring  dsc 
             inner join bdisolic:ss_scoring_grupo sgr on sgr.empresa=dsc.empresa and sgr.grupo=dsc.grupo and sgr.seccion=dsc.seccion
             inner join bdisolic:ss_scoring_element sel on sel.empresa=dsc.empresa and sel.grupo=dsc.grupo and sel.elemento=dsc.elemento 
                        and sel.seccion=dsc.seccion
          where dsc.empresa = pEmpresa and dsc.grupo = '8' and dsc.seccion = '2' and dsc.num_solicitud = cNum_Credito 
            and sel.elemento = (select max(elemento) 
                                  from bdisolic:ss_detalle_scoring 
                                 where empresa= dsc.empresa and grupo = dsc.grupo and seccion = dsc.seccion and num_solicitud = dsc.num_solicitud); 
/*
-- obtener la ultima disposicion
    select {+INDEX(bdicred:sd_movhis inx_movhis)} nvl(max(fecha_mov),dFecha_Apertura) into dUltima_Disposicion 
      from bdicred:sd_movhis 
     where empresa = pEmpresa 
       AND fecha_mov >= dFecha_Apertura 
       AND fecha_mov <= dUltimoDiaMesAnterior
       and num_credito = cNum_Credito 
       and codigo_fun = '002' 
       and codigo_ref in (50,60,30,40,41,42,61,62,63,64)
       and reversado = 'N';
*/
		---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		IF SUBSTR(cNum_Credito,1,2) = '69' THEN
			let dUltDisp_atm = ''; 
			let dUltDisp_pos = ''; 
			let dUltDisp_vnt = ''; 
			let dUltimo_pago = ''; 
			let dUltimo_Vencido = ''; 
		ELSE
         SELECT nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,''), nvl(fecha_ultimo_pago_h,''), 
               nvl(fecha_vencido,'')
          INTO dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt, dUltimo_pago, dUltimo_Vencido
          FROM bdicred:sd_indicador_cred
         WHERE empresa = pEmpresa 
           AND num_credito = cNum_Credito;
		END IF;
		
        if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
        if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
        if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
        if dUltimo_pago is null then let dUltimo_pago = ''; end if;
        if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
       
        IF (dUltDisp_atm > dUltDisp_pos) THEN
            IF (dUltDisp_atm >= dUltDisp_vnt) THEN
               LET dUltima_Disposicion = dUltDisp_atm;
            ELSE
               LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        ELIF (dUltDisp_atm = dUltDisp_pos) THEN    
            IF (dUltDisp_pos >= dUltDisp_vnt) THEN
                LET dUltima_Disposicion = dUltDisp_pos;
            ELSE
                LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        END IF;


    -- obtener ultimo pago
        if(dUltima_Disposicion > dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        elif (dUltimo_pago > dUltima_Disposicion) then
            let dUltimo_Movimiento = dUltimo_pago;
            let cTipo_Ult_Mov = '052';
        elif(dUltima_Disposicion = dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        end if;
		
	-- obtener causa solicitud
		
		select limit 1 nvl(a.causa_solicitud,'') into cMotivo
		from bdisolic:ss_autorizacion a
		where a.empresa = pEmpresa
		and a.num_solicitud = cNum_Credito
		and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = cNum_Credito and status_solicitud = 'AT')
		and a.status_solicitud = 'AT';
			
	 ---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		SELECT
				nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
				nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
				nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
				nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
				nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5                        
		INTO dEvaluacion1, dEvaluacion2, dEvaluacion3, dEvaluacion4,dEvaluacion5
		FROM bdisolic:ss_resumen_scoring
		WHERE empresa= '001'
		AND seccion in ('1', '2','3', '4','5')
		AND num_solicitud = cNum_Credito;
		
					-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)				
		
			SELECT nvl(flag2creditoicc,0) INTO sFlag2creditoicc 
			FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001'
			  AND num_solicitud = cNum_Credito;

         SELECT nvl(num_pagos,0),nvl(monto_pagos,0)
          INTO iNumPagos, dMontoPagos
          FROM bdicred:sd_indicador_cred_hist
         WHERE empresa = pEmpresa 
		   AND fecha = dUltimoDiaMesAnterior
           AND num_credito = cNum_Credito;
		   
			-- RQM 09 476 - 2 ADENDUM 
			SELECT monto_solicitado INTO dLineaOrigen FROM bdisolic:ss_solicitudes	
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito; 

			SELECT monto_otorgado INTO dLineaActual FROM bdicred:sd_maesdos 
			WHERE empresa=pEmpresa AND num_credito=cNum_Credito; 
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS FROM bdisolic:ss_solicitud_os
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS_Gpo5 FROM bdisolic:bitacora_os_gpo5 
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			  
			IF iSolicitudOS > 0 THEN 
			
				LET iMarcaOS = 1;		-- ADD
				
				SELECT COUNT(num_solicitud) INTO iSolicitudOS_P FROM bdisolic:ss_solicitud_os
				WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito AND status='P';
				
				IF iSolicitudOS_P > 0 THEN
					LET iMarcaOS = 1;
				ELSE
					IF iSolicitudOS_Gpo5 >0 THEN
						LET iMarcaOS = 2;
					ELSE
						LET iMarcaOS = 0;
					END IF;	
				END IF;
			ELSE	
				IF iSolicitudOS_Gpo5 >0 THEN
					LET iMarcaOS = 2;
				ELSE
					LET iMarcaOS = 0;
				END IF;	
			END IF;
			
			if dUltDisp_atm is null or dUltDisp_atm = '' then let dUltDisp_atm = date(1); end if;
			if dUltDisp_pos is null or dUltDisp_pos = '' then let dUltDisp_pos = date(1); end if;
			if dUltDisp_vnt is null or dUltDisp_vnt = '' then let dUltDisp_vnt = date(1); end if;
			
			--	Indicaremos "D" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ SOLO disposiciones en efectivo.((ATM OR VNT)OR (ATM AND VNT))AND NOT POS
			IF ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR  (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR
				 ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior)))AND	
				 (dUltDisp_pos<dPrimerDiaMes OR dUltDisp_pos>dUltimoDiaMesAnterior)THEN
					LET cTipoFac = 'D';
			-- Indicaremos "C" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ SOLO compras en terminal punto de venta.
			--	((POS)AND(ATM<PriDiaMes OR ATM>UltDiaMes) or AMBAS)AND (VNT<PriDiaMes OR VNT>UltDiaMes) or AMBAS)
			ELIF (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND 
				 (dUltDisp_atm<dPrimerDiaMes OR dUltDisp_atm>dUltimoDiaMesAnterior) AND 
				 (dUltDisp_vnt<dPrimerDiaMes OR dUltDisp_vnt>dUltimoDiaMesAnterior ) THEN
					LET cTipoFac = 'C';
			--	Indicaremos "M" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ compras y disposiciones (cajero y/o ventanilla) en efectivo.(ATM AND VNT AND POS)
			ELIF (dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND
				   (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) THEN
						LET cTipoFac = 'M';
			ELSE 
				LET cTipoFac = ' ';
			END IF;
						
        BEGIN WORK;
            UPDATE "informix".sd_rep_cartera_activa
               SET  fecha_nac = dFecha_Nac, rfc = cRfc, sexo = cSexo, estado_civil = cEstado_Civil, email = cEmail, numeroestado = cNumeroEstado, 
                    nombreestado = cNombreEstado, numerociudad=sNumeroCiudad, nombreciudad=cNombreCiudad, numciudad_cpl=sNumeroCiudadCpl, nombreciudad_cpl=cNombreCiudadCpl, numerocolonia=iNumeroColonia, 
                    municipiozona = cMunicipioZona, telefono1 = cTelefono1, telefono2 = cTelefono2, telefono3 = cTelefono3, extension = cExtension, 
                    tiempo_ocupacion_act = NVL(cTiempo_Ocupacion_Act,''), ultima_disposicion = dUltima_Disposicion, ultimo_movimiento = dUltimo_Movimiento,
                    ultimo_vencido = dUltimo_Vencido, tipo_ult_mov = cTipo_Ult_Mov, num_tarjeta = NVL(cNum_Tarjeta,''), numcte_ref = cNumCte_Ref, motivo = NVL(cMotivo  ,''),
					bscore = dEvaluacion1, scoreprop= dEvaluacion2, ficoscore = dEvaluacion3, ficoextended = dEvaluacion4,icc =dEvaluacion5,
					status = cStatus_Ini, revisado = cRevisado, ife = cIFE, num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0), flag2credito = nvl(sFlag2creditoicc,0),
					num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0),linea_origen=dLineaOrigen,linea_actual=dLineaActual,marca_os=iMarcaOS,tipo_facturacion=nvl(cTipoFac,'')
             WHERE numcte = cNumCte 
			 AND num_credito = cNum_Credito ;
        COMMIT WORK;
    	
    
        let dFecha_Nac = '';
        let cRfc  = '';
        let cSexo = '';
        let cEstado_Civil = '';
        let cEmail = '';
        let cNumeroEstado = '';
        let cNombreEstado = '';
        let sNumeroCiudad = '';
        let cNombreCiudad  = '';
        let sNumeroCiudadCpl=''; let cNombreCiudadCpl='';
        let iNumeroColonia = '';
        let cMunicipioZona = '';
        let cTelefono1 = '';
        let cTelefono2 = '';
        let cTelefono3 = '';
        let cExtension = '';
        let cTiempo_Ocupacion_Act  = '';
        let dUltima_Disposicion  = '';
        let dUltimo_Movimiento = '';
        let dUltimo_Vencido = '';
        let cTipo_Ult_Mov = '';
        let cNum_Tarjeta  = '';
        let cNumCte_Ref  = '';
		let cMotivo = '';
		let sFlag2creditoicc = 0;
        let contador_commit = contador_commit  + 1;
        let actualiza_esta = actualiza_esta + 1;
		let dLineaOrigen=0;
		let dLineaActual=0;
		let iMarcaOS=0;
   end foreach;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='4'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '4';
END IF;


IF cPaso = '4' THEN
   let sCommit = 0;
--Reporte de cartera activa
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select num_producto, numcte, num_credito, estatus_credito, hit, numeroestado, nombreestado, ' ||
       ' numciudad_cpl, nombreciudad_cpl, numerociudad, nombreciudad, ' ||
       ' sucursal, saldo_actual, saldo_vencido, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, ' ||
       ' saldo_cierre, meses_vencidos, fecha_apertura, situacion_pago, meses_historia, motivo, ' ||
	   ' case when (select excluye_validacion from bdisolic:'''||'informix'||'''.ss_revision_determinacion where empresa = '''||'001'||''' and num_solicitud = num_credito)  ' || 
	   ' = 1 then '''||'Excepcion de validacion telefonica por puntaje'||'''  else '''||' '||''' end case , ' ||	 
	   ' bscore , scoreprop, ficoscore , ficoextended ,icc,status , revisado, ife, flag2credito, grupo, num_pagos, monto_pagos,	   ' ||	
	   ' linea_origen,linea_actual,marca_os,tipo_facturacion,ultima_disposicion	'||
       ' from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql';
       /*' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia, flag2credito, grupo, num_pagos, monto_pagos from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql'; */
--     ' > query_cartera_activa.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_activa.sql';
--  let cSql = 'dbaccess bdicred query_cartera_activa.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_activa.sql';
--  LET cSql = 'rm query_cartera_activa.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='5'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '5';
END IF;

IF cPaso = '5' THEN
--Reporte de creditos inactivos o con saldo a favor
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre <= 0;"' ||
       ' > /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--     ' > query_clientes_inactivos.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  let cSql = 'dbaccess bdicred query_clientes_inactivos.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  LET cSql = 'rm query_clientes_inactivos.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='6'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '6';
END IF;

IF cPaso = '6' THEN
--Reporte de cartera vendida
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte ='''||'CV'||''';"' ||
       ' > /resplogifx/archivoscartera/query_cartera_vendida.sql';
--     ' > query_cartera_vendida.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  let cSql = 'dbaccess bdicred query_cartera_vendida.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  LET cSql = 'rm query_cartera_vendida.sql';
    SYSTEM cSql;
END IF;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='1'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
--    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '03') returning cCod_ret2;
    return cCodRet,cMensajeRet;
end;
end procedure;