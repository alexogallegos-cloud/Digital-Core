CREATE PROCEDURE "informix".ugenera_layoutedocuenta_adn(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;
DEFINE v_sql        CHAR(7000);
DEFINE v_sql1       CHAR(1500);
DEFINE v_sql2       CHAR(1500);
DEFINE v_sql3       CHAR(1500);
DEFINE v_sql4       CHAR(1000);
DEFINE v_sql5       CHAR(1000);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;

--SET DEBUG FILE TO "/informix/jesus/RQM10617/lib/ugenera_layoutedocuenta.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;


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
SELECT TRIM(valor) INTO v_ruta_cfd FROM sd_param WHERE empresa = pempresa AND cod_param = '037';
                  

	-----------------ENCABEZADO DOS---------------------------------------------------ARCHIVO 200
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( capital_tc,0),'||
                  ' nvl ( interes_tc,0),'||
                  ' nvl ( iva_interes_tc,0),'||
                  ' nvl ( capital_ven_tc,0),'||
                  ' nvl ( interes_ven_tc,0),'||
	          ' nvl ( iva_interes_ven_tc,0),'||
                  ' nvl ( moratorios_tc,0),'||
                  ' nvl ( iva_moratorios_tc,0),'||                 
                  ' nvl ( interes_pago_total_tc,0),'||                  
                  ' date(1),'||
                  ' nvl ( periodo_tc_ini,0),'||
                  ' nvl ( periodo_tc_fin,date(1)),'||                 
                  ' nvl ( fecha_corte,date(1)),'||
                  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( limite_tc,0),'||                  
                  ' nvl ( pago_antes_de,date(1)),'||
	          ' nvl ( sus_comisiones,0),'||                  
                  ' nvl ( mas_intereses,0),'||
                  ' nvl ( menos_abonos,0)'||
                  ' FROM sd_encabezado2_edocta a';
       LET v_sql3=' WHERE a.fecha_emision = '''||pperiodo||'''   " > query200.sql';


	 LET v_sql = v_sql1||v_sql2||v_sql3;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query200.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES



	-----------------DETALLE---------------------------------------------------ARCHIVO 300
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( fecha_mov,'' ''),'||
            ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( cargos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( abonos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_detalle_edocta a '||
            ' WHERE a.fecha_emision ='''||pperiodo||'''   ORDER BY a.num_credito,secuencia,nlinea"'||
            ' > query300.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query300.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------ACLARACIONES---------------------------------------------------ARCHIVO 400
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
         LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( folio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( fecha_movimiento, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( importe,0) FROM sd_aclaraciones_edocta a '||
            ' WHERE a.fecha_emision ='''||pperiodo||'''   ORDER BY a.num_credito,secuencia,nlinea"'||
            ' > query400.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query400.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------MENSAJES---------------------------------------------------ARCHIVO 500

    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';

    LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' nvl ( a.secuencia,0),'||
        ' nvl ( a.nlinea,0),'||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        ' nvl ( replace ( replace( a.mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta a '||
		 ' WHERE a.fecha_emision ='''||pperiodo|| ''' ' ||
        '   ORDER BY 2,3,4"'||
		' > query500.sql';		
	
		
	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query500.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
	  --FIN DE COMPRIMIR. Este archivo se queda unicamente en archivoscartera (No se copia ni mueve).



	-----------------MENSAJES ARCHIVO 500 BIS -----------ARCHIVO DE MENSAJES ANTERIOR----------------------------------  
-----------------MENSAJES---------------------------------------------------
    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga500B.unl';
    
	
	LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' (clave + 1 -43)::integer,'||
        ' ''1'','||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        '  nvl ( replace ( replace (replace ( b.mensajes, ''|'' , '' '' ), ''\'' , '' ''),''{1}'',meses_liq::CHAR(2)),'' '') FROM sd_mensajes_edocta a '||
		' left join   bdicred:sd_config_mensaje_edocta b on b.num_producto = '''||7800||''' '||
		' where a.num_credito =a.num_credito and a.secuencia= ''1'' '||		  
 ' UNION ALL '||
        ' SELECT a.fecha_emision,a.num_credito, a.secuencia, ''0'', '' '' , mensajes FROM bdicred:sd_mensajes_edocta a'||
        ' WHERE a.fecha_emision ='''||pperiodo|| ''' ' ||
        '  and num_credito = ''500'' ORDER BY 2,3,4"'||       
        ' > query500B.sql';
		
		


	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query500B.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga500B.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga500B.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;	  
/*---
	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'Archivo500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y MOVER  A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

	  
    -----------------MENSAJES ARCHIVO 800 ---------------------------------------------

    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga800.unl';

     /*LET v_sql2 = ' SELECT 1, clave, mensajes FROM bdicred:sd_config_mensaje_edocta"'||
        ' > query501.sql';*/

     LET v_sql2 = ' SELECT '''||pperiodo||''', 1, clave, replace(replace (mensajes,''{0}'',''X1''),''{1}'',''X2'') FROM bdicred:sd_config_mensaje_edocta where num_producto = ''6001'' order by clave"'||
        ' > query800.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query800.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga800.unl'||" >"||v_ruta||'descarga1800.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga800.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1800.unl'||" > "||v_ruta||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;
	  
      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1800.unl';
      SYSTEM v_sql;
	  

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
	-----------------PIE DE PAGINA---------------------------------------------------ARCHIVO 600

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( round(tasa_anual,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( round(cat,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( tasa_mora,0),'||
			' case when nvl ( tasa_mensual_mora,0) - (trim(nvl ( tasa_mensual_mora,0)::CHAR(2))::int ) = 0 THEN '||
            ' (trim(nvl ( tasa_mensual_mora,0)::CHAR(2)))||''.00'' '||
            ' else '||
            ' (trim(nvl ( tasa_mensual_mora,0)::CHAR(2)))||substr(rpad(nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ),4,0),2,3) '||
            ' end '||
			' FROM sd_pie_edocta a '||
            ' WHERE fecha_emision ='''||pperiodo||'''   "' ||
            ' > query600.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query600.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;
	  
      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;

-----------------ENCABEZADO UNO---------------------------------------------------ARCHIVO 100
	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,DATE(1)),'||
                  ' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edocta a';
     LET v_sql5=  ' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||'''  order by ruta " > query100.sql';

	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
--||v_sql6;
	 system v_sql;

	 LET v_sql = "dbaccess bdicred query100.sql";
	 system v_sql;
 LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â´/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
--"s/'/ /g"

		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â¨/ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;


          LET v_sql = '';
		  LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  
		  let v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  let v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " || trim(v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
		  SYSTEM v_sql;


	  --COMPRIME ARCHIVO GENERADO
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;
	  
	  let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga2.unl';
      SYSTEM v_sql;

	  
	  --- ARCHIVO 100 DE CFDI con la atenciòn del RQI 12 379 Inclusión de Correo Electrónico en Archivos de TDC PIQV
	   LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,DATE(1)),'||
                  ' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				   ' (SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
				  ' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
                  ' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' ),'||
				  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edocta a';
     LET v_sql5=  ' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||'''  order by ruta " > query100.sql';

	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
--||v_sql6;
	 system v_sql;

	 LET v_sql = "dbaccess bdicred query100.sql";
	 system v_sql;
 LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â´/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
--"s/'/ /g"

		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â¨/ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;


          LET v_sql = '';
		  LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  
		  let v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " || trim(v_ruta||'ArchivoADN100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
		  SYSTEM v_sql;


	  --COMPRIME ARCHIVO GENERADO
	  --LET v_sql = '';
	  --LET v_sql = " gzip " || v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      --SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;
	  
	  let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga2.unl';
      SYSTEM v_sql;

	  
	  --- ARCHIVO 100 DE CFDI con la atenciòn del RQI 12 379 Inclusión de Correo Electrónico en Archivos de TDC PIQV
		
      ---------  COPIA ARCHIVOS CREADOS A LA DE CFD -------------------

	  --LET v_sql = '';
      --LET v_sql = "cp " || v_ruta|| 'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   --trim(v_ruta_cfd) ||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  --SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;
	  

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;
	  
	
	  
	  LET v_sql = '';
      LET v_sql = "mv " || v_ruta|| 'ArchivoADN500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
						   trim(v_ruta_cfd) ||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	  SYSTEM v_sql;
	  
	  
	  	  LET v_sql = '';
      LET v_sql = "mv " || v_ruta|| 'ArchivoADN100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
						   trim(v_ruta_cfd) ||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	  SYSTEM v_sql;

	  

    ---
	  --COMPRIMIR YA QUE AL PASAR SE PASA SIN COMPRIMIR PARA DEJAR EL MISMO NOMBRE
	  LET v_sql = '';
	  LET v_sql = " gzip " || trim(v_ruta_cfd)||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
	  LET v_sql = '';
	  LET v_sql = " gzip " || trim(v_ruta_cfd)||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
--*/
	  
	  
--*/  --FIN DE COPIAR A LA RUTA DE CFD.

	  LET v_sql = '';
      LET v_sql = 'rm query100.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query200.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query300.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query400.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query500.sql ';
	  SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = 'rm query600.sql ';
	  SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = 'rm query500B.sql ';
	  SYSTEM v_sql;

	  
	  LET v_sql = '';
      LET v_sql = 'rm query800.sql ';
	  SYSTEM v_sql;	  
	

  END;
  RETURN cod_ret;

END PROCEDURE;