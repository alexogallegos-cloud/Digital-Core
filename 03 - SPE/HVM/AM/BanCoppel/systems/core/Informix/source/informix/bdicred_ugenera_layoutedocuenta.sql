CREATE PROCEDURE "informix".ugenera_layoutedocuenta(pempresa CHAR(3),pperiodo DATE)
	RETURNING CHAR(5);

	DEFINE v_ruta      VARCHAR(255);
	DEFINE v_ruta_cfd  VARCHAR(255);
	DEFINE cod_ret     CHAR(5);
	DEFINE sql_err     INTEGER;
	DEFINE v_sql        CHAR(8000);
	DEFINE v_sql1       CHAR(1600);
	DEFINE v_sql2       CHAR(1600);
	DEFINE v_sql3       CHAR(1600);
	DEFINE v_sql4       CHAR(1600);
	DEFINE v_sql5       CHAR(1600);
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

	--SET DEBUG FILE TO "/resplogifx/archivoscartera/ugenera_layoutedocuenta.out";
	--TRACE ON;
	--SET DEBUG FILE TO "/INFORMIXDUMP/ugenera_layoutedocuenta.out";
	--TRACE ON;


	set isolation to dirty read;
	---set lock mode to wait 3;
        --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION COMMITTED READ;
	--set pdqpriority 20;--adlm 

	-- Fecha: 09/09/2009
	-- Autor: Roque Enrique Solis CampaÃÂ±a
	-- Nodificacion: Se modifico la forma de armar la tabla temporal  sd_paso_cred
	-- Separando los querys.

	BEGIN

	   ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				SELECT COUNT(tabid)
				  INTO sPaso
				  FROM systables
				 WHERE tabname= 'sd_paso_cred';

				IF NVL(sPaso,0) > 0 THEN
					DROP TABLE sd_paso_cred;
				END IF;
				SELECT COUNT(tabid)
				  INTO sPaso
				  FROM systables
				 WHERE tabname= 'paso_credNoMovto';

				IF NVL(sPaso,0) > 0 THEN
					DROP TABLE paso_credNoMovto;
				END IF;
				RETURN cod_ret;
			END IF
	   END EXCEPTION;

	   LET cod_ret = "000";

	-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

	SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
	SELECT TRIM(valor) INTO v_ruta_cfd FROM sd_param WHERE empresa = pempresa AND cod_param = '037';


	SELECT COUNT(tabid)
	  INTO sPaso
	  FROM systables
	 WHERE tabname= 'sd_paso_cred';

	IF NVL(sPaso,0) > 0 THEN
		DROP TABLE "informix".sd_paso_cred;
	END IF;
		CREATE TABLE "informix".sd_paso_cred
		(
			num_credito CHAR(20)
		 );

	select num_credito
	 from sd_edocta_se
	where idaccion = 5
	  and instruccion = '1'
	group by 1
	into temp paso_sitesp with no log;

	insert into "informix".sd_paso_cred
	select * from paso_sitesp group by 1;
    insert into "informix".sd_paso_cred  values ('000'); -- Encabezado_edocta  General
    insert into "informix".sd_paso_cred  values ('100'); -- Encabezado_edocta  General
    insert into "informix".sd_paso_cred  values ('200'); -- Encabezado edocta Saldos
    insert into "informix".sd_paso_cred  values ('300'); -- Detalle
    insert into "informix".sd_paso_cred  values ('400'); -- Aclaraciones
    insert into "informix".sd_paso_cred  values ('500'); -- Mensajes
    insert into "informix".sd_paso_cred  values ('600'); -- Pie
    insert into "informix".sd_paso_cred  values ('900'); -- Credisoluciones
	if month(pperiodo) not in (3,9) then
		select num_credito
		  from sd_edocta_sdos
		where fecha = pperiodo
         and empresa = '001'
		 and (fecha_ultimo_pago is null or fecha_ultimo_pago <= pperiodo - 6 units month)
		 and sdo_cap_insoluto <= 0 and fecha_apertura <=pperiodo - 6 units month
		--and fecha_apertura <= fecha_ult_compra - 6 units month
		 into temp paso_credNoMovto with no log;
		 insert into paso_credNoMovto
		 select num_credito
		  from sd_edocta_sdos
		where fecha = pperiodo
         and empresa = '001'
		 and num_producto = '7000';
		--and fecha_apertura <= fecha_ult_compra - 6 units month		 

		--LET v_sql = " unload to CreditosNoEdocta"||char(pperiodo,"%m%Y")||" ";
			LET v_sql1 =  ' echo "UNLOAD TO '||trim(v_ruta)||'CreditosNoEdocta'||to_char(pperiodo,"%m%Y")||'.txt ';

		LET v_sql2 = ' select ''001'',numcte,  num_credito,fecha, 0,0,'''','''',0,0,fecha, ''informix'' '||
					' from sd_edocta_sdos  '||
					' where fecha ='''|| to_char(pperiodo,'%m-%d-%Y')||''' '||
                    '  and empresa = ''001'' '||
					'  and (fecha_ultimo_pago is null or fecha_ultimo_pago <=date('''|| to_char(pperiodo,'%m-%d-%Y')||''') - 6 units month)'||
					'  and sdo_cap_insoluto <= 0 and fecha_apertura <= date('''|| to_char(pperiodo,'%m-%d-%Y')||''') - 6 units month ' ||
					' union '||					
					' select ''001'',numcte,  num_credito,fecha, 0,0,'''','''',0,0,fecha, ''informix'' '||
					' from sd_edocta_sdos ' ||	
					' where fecha ='''|| to_char(pperiodo,'%m-%d-%Y')||''' '||
					' and empresa = ''001'' ' ||
					' and num_producto = ''7000'' '||
                    '  " > queryNEC.sql '; --||
					--'  and fecha_apertura <= fecha_ult_compra - 6 units month " > queryNEC.sql';
		LET v_sql = trim(v_sql1)||' ' || trim(v_sql2);
		SYSTEM v_sql;

		LET v_sql = "dbaccess bdicred queryNEC.sql";
		SYSTEM v_sql;

	  insert into "informix".sd_paso_cred
	  select * from paso_credNoMovto where num_credito not in (select num_credito from sd_paso_cred) group by 1;
	  LET v_sql ="";
	  LET v_sql ="";
	  LET v_sql2 ="";

      LET v_sql = '';
	  LET v_sql = 'rm queryNEC.sql ';
	  SYSTEM v_sql;

	end if;

    -- INICIA DESCARGA DE ARCHIVOS.
	--FIN DE DESCARGA DE CFD Y HASTA AQUI YA NO SE GENERARAN LOS ARCHIVOS  FMJ DICIEMBRE 2011	
		-----------------ENCABEZADO DOS---------------------------------------------------ARCHIVO 200

		 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl' ||
                      ' SELECT fecha_emision,a.num_credito, ' ||
                      ' nvl ( capital_tc,0), nvl( interes_tc,0),  nvl( iva_interes_tc,0), nvl(capital_ven_tc,0),'||
                      ' nvl ( interes_ven_tc,0), nvl ( iva_interes_ven_tc,0), nvl ( moratorios_tc,0), nvl ( iva_moratorios_tc,0),'||
                      ' nvl ( sdo_pagar,0), nvl ( interes_pago_total_tc,0), nvl ( limite_tc,0), nvl ( sdo_disponible,0),'||
                      ' nvl ( periodo_tc_ini,0), nvl ( periodo_tc_fin,date(1)), nvl ( pago_antes_de,date(1)),'||
                      ' nvl ( fecha_corte,date(1)), nvl (dias_periodo_tc, ''0'' ), nvl ( usted_debia,0),'||
                      ' nvl ( menos_abonos,0), nvl ( mas_compras,0), nvl ( sus_comisiones,0), nvl ( mas_disp_efectivo,0),'||
                      ' nvl ( mas_intereses,0), nvl ( mas_iva,0), nvl ( mas_rendimientos,0),  nvl ( comisiones_iva,0), '||
                      ' nvl ( intereses_iva,0),  nvl ( intereses_pag,0), nvl ( saldo_menos_pag,0), nvl ( compras_disp,0), nvl ( saldo_diferido,0),'||
					  ' nvl ( saldo_total,0), nvl ( saldo_corte,0) , 0.00 ' ||
                      ' FROM bdicred:sd_encabezado2_edocta a '||
			          ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''200'' UNION ALL  '  ;
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
					  ' nvl ( sdo_pagar,0),'||
					  ' nvl ( interes_pago_total_tc,0),'||
					  ' nvl ( limite_tc,0),'||
					  ' nvl ( sdo_disponible,0),'||
					  ' nvl ( periodo_tc_ini,0),'||
					  ' nvl ( periodo_tc_fin,date(1)),'||
					  ' nvl ( pago_antes_de,date(1)),'||
					  ' nvl ( fecha_corte,date(1)),'||
					  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					  ' nvl ( usted_debia,0),'||
					  ' nvl ( menos_abonos,0),'||
					  ' nvl ( mas_compras,0),'||
				      ' nvl ( sus_comisiones,0),'||
					  ' nvl ( mas_disp_efectivo,0),'||
					  ' nvl ( mas_intereses,0),'||
					  ' nvl ( mas_iva,0),'||
					  ' nvl ( mas_rendimientos,0), '||
					  ' nvl ( comisiones_iva,0), '||
					  ' nvl ( intereses_iva,0), '||
					  ' nvl ( intereses_pag,0), '||
					  ' nvl ( saldo_menos_pag,0), '||
					  ' nvl ( compras_disp,0), '||
					  ' nvl ( saldo_diferido,0), '||
					  ' nvl ( saldo_total,0), ' ||
					  ' nvl ( saldo_corte,0) , 0.00 ' ||
					  ' FROM sd_encabezado2_edocta a';
		   LET v_sql3=' WHERE a.fecha_emision = '''||pperiodo||'''  AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  " > query.sql';


		 LET v_sql = trim(v_sql1)||v_sql2||v_sql3;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

		-----------------DETALLE---------------------------------------------------ARCHIVO 300
		 LET v_sql1 = ' echo " UNLOAD TO '||v_ruta||'descarga.unl';
		 LET v_sql2 = ' SELECT a.fecha_emision, num_credito, nvl ( secuencia,0)secuencia ,nvl ( nlinea,0) nlinea, ''0'', ''0'',''0'',''0'' FROM bdicred:sd_detalle_edocta a '||
			          ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''300'' UNION ALL  '||
                ' SELECT nvl ( fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( secuencia,0),'||
				' nvl ( nlinea,0),'||
				' nvl ( fecha_mov,'' ''),'||
				' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( cargos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( abonos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_detalle_edocta a '||
				' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  ORDER BY a.num_credito,secuencia,nlinea"'||
				' > query.sql';

		 LET v_sql = v_sql1||v_sql2;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


		-----------------ACLARACIONES---------------------------------------------------ARCHIVO 400
		 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
			 LET v_sql2 = ' SELECT a.fecha_emision, num_credito, nvl ( secuencia,0) secuencia, nvl ( nlinea,0) nlinea, '||
                          ' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ), ' ||
                          ' '' '', '' '','' '', 0.0  FROM bdicred:sd_aclaraciones_edocta a '||
			              ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''400'' UNION ALL  '||
                ' SELECT nvl ( fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( secuencia,0),'||
				' nvl ( nlinea,0),'||
				' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( folio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( fecha_movimiento, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( importe,0) FROM sd_aclaraciones_edocta a '||
				' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  ORDER BY a.num_credito,secuencia,nlinea"'||
				' > query.sql';

		 LET v_sql = Trim(v_sql1)||v_sql2;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

		-----------------MENSAJES---------------------------------------------------ARCHIVO 500

		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
		LET v_sql2 = ' SELECT '''||pperiodo||''', num_credito, 1,''0'',  '' '', '' '','' '','' ''  FROM bdicred:sd_mensajes_edocta a '||
			         ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''500'' UNION ALL  '||
            ' SELECT '''||pperiodo||''', num_credito, 1, NVL(si_paga,'' ''), ''44'', '' '', '' '', '' '' FROM bdicred:sd_mensajes_edocta a'||
			' WHERE a.fecha_emision = '''||pperiodo||''' AND NVL(si_paga, '''') <> '''' AND num_credito not in (select num_credito from "informix".sd_paso_cred) ORDER BY 2"'||
			' > query.sql';

		 LET v_sql = v_sql1||v_sql2;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR. Este archivo se queda unicamente en archivoscartera (No se copia ni mueve).


	-----------------MENSAJES ARCHIVO 500 BIS -----------ARCHIVO DE MENSAJES ANTERIOR----------------------------------
	-----------------MENSAJES---------------------------------------------------
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga500B.unl';
		LET v_sql2 = ' SELECT a.fecha_emision, num_credito, 1,0, NVL(si_paga,'' ''), '' ''  FROM bdicred:sd_mensajes_edocta a '||
			         ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''500'' UNION ALL  '||
            ' SELECT nvl (a.fecha_emision,date(1)),'||
			' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
			' nvl ( b.secuencia,0),'||
			' nvl ( b.nlinea,0),'||
			' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
			' nvl ( replace ( replace( b.mensaje, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta a '||
			' LEFT OUTER JOIN sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision'||
			' WHERE a.fecha_emision ='''||pperiodo||''' AND a.secuencia = 2 AND a.nlinea = 1 AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  '||
			' UNION ALL '||
			' SELECT fecha_emision, num_credito, secuencia, nlinea, NVL(si_paga,'' ''), mensajes FROM sd_mensajes_edocta a'||
			' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito not in (select num_credito from "informix".sd_paso_cred)  "'||
			' > query.sql';

		 LET v_sql = v_sql1||v_sql2;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga500B.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga500B.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;
	/*---
		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;
	--*/
		  --FIN DE COMPRIMIR Y MOVER  A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


		-----------------MENSAJES ARCHIVO 800 ---------------------------------------------

		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga800.unl';

		 /*LET v_sql2 = ' SELECT 1, clave, mensajes FROM bdicred:sd_config_mensaje_edocta"'||' > query501.sql';*/

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
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1800.unl'||" > "||v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1800.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR Y COPIAR A LA RUTA DE CFD
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
		  

		-----------------PIE DE PAGINA---------------------------------------------------ARCHIVO 600

		 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
		 LET v_sql2 = ' SELECT a.fecha_emision, num_credito, ''0'',''0'', ''0'',''0'',0,''0.00''  FROM bdicred:sd_pie_edocta a '||
			          ' WHERE a.fecha_emision = '''||pperiodo||''' AND num_credito = ''600'' UNION ALL  '||
                ' SELECT nvl (fecha_emision,date(1)),'||
				' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
				' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(tasa_anual,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( round(cat,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				' nvl ( tasa_mora,0),'||
				' case when nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ) = 0 THEN '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||''.00'' '||
				' else '||
				' (trim(nvl (tasa_mensual_mora,0)::CHAR(2)))||substr(rpad(nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ),4,0),2,3) '||
				' end '||
				' FROM sd_pie_edocta a '||
				' WHERE fecha_emision ='''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  "' ||
				' > query.sql';

		 LET v_sql = v_sql1||v_sql2;

		 system v_sql;
		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;


		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  --COMPRIMIR ARCHIVO GENERADO
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;


	-----------------ENCABEZADO UNO---------------------------------------------------ARCHIVO 100

		 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descarga.unl';
		 LET v_sql2 = ' SELECT a.fecha_emision, a.num_credito, '' '', ''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',''0'',ruta,'' '','' '', '' '','' '' '||
                      ' FROM bdicred:sd_encabezado_edocta a '||
			          ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito IN ( ''100'', ''000'') UNION ALL  '||
                      ' SELECT nvl ( fecha_emision,DATE(1)),'||
					  ' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
					  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
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
		 LET v_sql5=  ' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||''' AND a.num_credito  not in (select num_credito from "informix".sd_paso_cred) order by ruta " > query.sql';

		 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
		 system v_sql;

		 LET v_sql = "dbaccess bdicred query.sql";
		 system v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/ÃÂ´/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
--"s/'/ /g"

		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/ÃÂ¨/ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
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
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " || trim(v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
		  SYSTEM v_sql;

		  --COMPRIME ARCHIVO GENERADO
		  LET v_sql = '';
		  LET v_sql = " compress " || v_ruta||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

		  let v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          let v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

		LET v_sql3= "";
		
				  --------------------- ARCHIVO 900 CREDISOLUCIONES --------------------
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';		
		LET v_sql4 = ' SELECT nvl ( fecha_emision,date(1)),'||
					 '  a.num_credito,'||
					 ' nvl (secuencia,0),'||
					 ' nvl (nlinea,0),'||
					 ' nvl (prox_fecha_pago,date(1)),'||
					 ' concepto,'||
					 ' nvl (tasa,0),'||
					 ' nvl (saldo_pendiente,0),'||
					 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer ' ||'||''/''||'||'"plazo",'||
					 ' nvl (monto_prox_pago,0)'||
					 ' FROM sd_detalle_dif_edocta a'||
					 ' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito = ''900'' '||
					 'UNION ALL';
		LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
					 ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
					 ' nvl (secuencia,0),'||
					 ' nvl (nlinea,0),'||
					 ' nvl (prox_fecha_pago,date(1)),'||
					 ' concepto,'||
					 ' nvl (tasa,0),'||
					 ' nvl (saldo_pendiente,0),'||
					 ' replace (replace(numero_cuotas,''.0'',''''),''/'','''')::integer  ' ||'||''/''||'||'"plazo",'||
					 ' nvl (monto_prox_pago,0)'||
					 ' FROM sd_detalle_dif_edocta a';
		  LET v_sql3=' WHERE a.fecha_emision = '''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred) " > query900.sql';
		                                                                                   
		LET v_sql = TRIM(v_sql1)||" "||TRIM(v_sql4)||" "||TRIM(v_sql2)||" "||TRIM(v_sql3);

		system v_sql;
		LET v_sql = "dbaccess bdicred query900.sql";
		system v_sql;
			 
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		SYSTEM v_sql;

		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descarga.unl';
		SYSTEM v_sql;

		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
		SYSTEM v_sql;

		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descarga1.unl';
		SYSTEM v_sql;

		--COMPRIMIR Y COPIAR A LA RUTA DE CFD 
		LET v_sql = '';
		LET v_sql = " compress " || v_ruta||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		SYSTEM v_sql;

		  ---------  COPIA ARCHIVOS CREADOS A LA DE CFD -------------------

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "mv " || v_ruta|| 'Archivo500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
							   trim(v_ruta_cfd) ||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

      LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo900'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  --COMPRIMIR YA QUE AL PASAR SE PASA SIN COMPRIMIR PARA DEJAR EL MISMO NOMBRE
		  LET v_sql = '';
		  LET v_sql = " compress " || trim(v_ruta_cfd)||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;



		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;
	  --FIN DE COPIAR A LA RUTA DE CFD.


		  LET v_sql = '';
		  LET v_sql = 'rm query.sql ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = 'rm query800.sql  ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = 'rm query900.sql  ';
		  SYSTEM v_sql;		  
	  END;
	  RETURN cod_ret;

	END PROCEDURE;