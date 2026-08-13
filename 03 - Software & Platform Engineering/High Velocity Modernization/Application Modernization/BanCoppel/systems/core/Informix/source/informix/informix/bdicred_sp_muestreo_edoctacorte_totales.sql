CREATE PROCEDURE "informix".sp_muestreo_edoctacorte_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
RETURNING CHAR(5) AS codret,
		INTEGER AS total;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
    
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN 	cCodRet,iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_muestreo_edoctacorte_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN 	cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN 	cCodRet,iNoRegistros;
		END IF;

		SELECT COUNT(*)
		INTO iNoRegistros
		FROM (SELECT cre.num_credito
			FROM bdicred:"informix".sd_maecred AS cre
			INNER JOIN bdicred:"informix".sd_muestra_edocta AS edo ON cre.num_credito = edo.num_Credito
			WHERE cre.empresa = '001' AND edo.fecha_corte = pFecha
			UNION ALL
			SELECT cre.num_credito 
			FROM bdicred:"informix".sd_maecredcrd AS cre
			INNER JOIN bdicred:"informix".sd_muestra_edocta AS edo ON cre.num_credito = edo.num_Credito
			WHERE cre.empresa = '001' AND edo.fecha_corte = pFecha);
			
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNoRegistros;
        
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/SEPTIEMBRE/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MUESTREO DE ESTADOS DE CUENTA',
'DESCRIPCION: SP que obtiene el total de registros a consultar de los estados de Cuenta',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_obtienecodtarjeta(pEmpresa CHAR(3),pnumbin CHAR(6),ptipotar CHAR(1))
RETURNING CHAR(6)         AS codigo_retorno,
		  CHAR(28)		  AS cproducto,
		  CHAR(3) 		  AS ccodTarjeta;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cnomproducto	 CHAR(28);
DEFINE ccodproductotar	 CHAR(3);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cnomproducto	  = '';
LET ccodproductotar  = '';


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
	RETURN cCodRet, NVL(cnomproducto,''), NVL(ccodproductotar,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/Malena/sp_obtienecodtarjeta.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT limit 1 codproductotarjeta, descripcion
	INTO ccodproductotar,cnomproducto
	FROM intercard:tipotarjeta
	WHERE tipo=ptipotar 
	AND bin = pnumbin;

	IF NVL(ccodproductotar,'') = ''  THEN
	   LET cCodRet= '000001';
	   LET cnomproducto='No hay datos con la información indicada';
	END IF;

	RETURN cCodRet, NVL(cnomproducto,''), NVL(ccodproductotar,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para consultar el codigo de producto de la tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 13/10/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".ugenera_layoutedocuentacrdpp_reproceso(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql       CHAR(5000);
DEFINE v_sql1      CHAR(2000);
DEFINE v_sql2      CHAR(2000);
DEFINE v_sql3      CHAR(2000);
DEFINE v_sql4      CHAR(1000);
DEFINE v_sql5      CHAR(1000);
DEFINE pperiodo1   DATE;
DEFINE pperiodo2   DATE;
DEFINE pperiodo3    DATE;

LET v_ruta  = "";
LET v_ruta_cfd = "";
LET v_sql   = "";
LET v_sql1  = "";
LET v_sql2  = "";
LET v_sql3  = "";
LET v_sql4  = "";
LET v_sql5  = "";

 --SET DEBUG FILE TO "/informix/gpe/ugenera_layoutedocuentacrd.out";
 --TRACE ON;

-- Autor: Leonardo Hernández Moreno
-- Fecha: 2009/07/24
-- Modificación: Se realiza modificación para obtener
--               la ruta donde se almacenarán los archivos
--               generados para créditos reestructurados
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
	  
	  
---CREATE TABLE "informix".pp_creditos
---		(
---			num_credito CHAR(20)
---		 );


---Insert into pp_creditos (num_credito) 
---select num_credito
---from bdicred:sd_movhiscrd where fecha_mov = mdy(01,14,2017) and usuario = 'cobroapp' and folio_suc in ('cobroapp14117052','cobroapp14117053') and codigo_fun = 023 and codigo_ref = 1
---group by 1 having count(*) >1;
--into temp pp_creditos with no log;

---create unique index inx_pp_creditos on pp_creditos(num_credito);
---update statistics high for table pp_creditos;
	  

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
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edoctacrd ';
--     LET v_sql5=  ' WHERE fecha_emision ='''||TO_CHAR(pperiodo,'%m/%d/%Y')||''' order by ruta" > query.sql';
     LET v_sql5=  ' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y')|| ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y')|| 
                  ''' AND num_credito not in (select num_credito from pp_creditos) AND num_credito = '''||6300100||''' and num_producto in('''||6300||''','''||7600||''','''||7700||''') order by fecha_emision,num_credito" > query.sql';
	 LET v_sql = TRIM(v_sql1)||' '||TRIM(v_sql2)||' '||TRIM(v_sql3)||' '||TRIM(v_sql4)||' '||TRIM(v_sql5);
	 SYSTEM  TRIM(v_sql);

	 LET v_sql = "dbaccess bdicred query.sql";
	 SYSTEM  TRIM(v_sql);

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
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edoctacrd ';
--     LET v_sql5=  ' WHERE fecha_emision ='''||TO_CHAR(pperiodo,'%m/%d/%Y')||''' order by ruta" > query.sql';
     LET v_sql5=  ' WHERE fecha_emision > '''||TO_CHAR(pperiodo1,'%m/%d/%Y') || ''' AND fecha_emision <= '''||TO_CHAR(pperiodo2,'%m/%d/%Y') 
                    ||''' AND num_credito not in (select num_credito from  pp_creditos ) AND num_credito <> '''||6300100||''' AND num_producto in('''||6300||''','''||7600||''','''||7700||''') order by fecha_emision,num_credito" > query.sql';
LET v_sql = TRIM(v_sql1)||' '||TRIM(v_sql2)||' '||TRIM(v_sql3)||' '||TRIM(v_sql4)||' '||TRIM(v_sql5);
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
                   ''' AND num_credito not in (select num_credito from  pp_creditos ) and num_credito ='''||6300200||''' ORDER BY fecha_emision,num_credito"'||
            	  ' > query.sql';
	 LET v_sql = TRIM(v_sql1)||' '||TRIM(v_sql2)||' '||TRIM(v_sql3);
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

-----------------SE INSERTAN EL CABECERO DEL ENCABEZADO DOS-------------------------------
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
                  '''  AND a.num_credito not in (select num_credito from  pp_creditos ) and a.fecha_emision = b.fecha_emision and a.num_credito <> '''||6300200||''' and a.num_credito = b.num_credito and b.num_producto in('''||6300||''','''||7600||''','''||7700||''') ORDER BY a.fecha_emision,a.num_credito"'||
            	  ' > query.sql';
	 LET v_sql = TRIM(v_sql1)||' '||TRIM(v_sql2)||' '||TRIM(v_sql3);
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
	LET v_sql = " compress " || v_ruta||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
     SYSTEM v_sql;

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
            ''' AND num_credito not in (select num_credito from  pp_creditos )  and num_credito ='''||6300300||''' "'||               
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
            ||''' AND a.num_credito not in (select num_credito from  pp_creditos )  and a.fecha_emision = b.fecha_emision  and a.num_credito <> '''||6300300||''' and a.num_credito = b.num_credito and b.num_producto in('''||6300||''','''||7600||''','''||7700||''') ORDER BY a.fecha_emision,a.num_credito,a.secuencia,nlinea"'||
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
            ''' AND fecha_emision <= '''||pperiodo2|| ''' AND num_credito not in (select num_credito from  pp_creditos ) and num_credito = '''||6300400||''' "'||
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
            ''' AND num_credito not in (select num_credito from  pp_creditos ) AND num_credito =  "6300500" ORDER BY fecha_emision,num_credito,secuencia,nlinea"'||
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
    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
    LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' nvl ( b.secuencia,0),'||
        ' nvl ( b.nlinea,0),'||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        ' nvl ( replace ( replace( b.mensaje, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edoctacrd a '||
        ' LEFT OUTER JOIN bdicred:sd_mensajes_mensual_edoctacrd b on a.fecha_emision = b.fecha_emision'||
        ' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
        ''' AND a.num_credito not in (select num_credito from  pp_creditos ) AND a.secuencia = 1 AND a.nlinea = 1 and num_credito <> "6300500 and a.num_producto = '''||6300||'''"'||
        ' AND a.num_producto = b.num_producto'||
        ' UNION ALL '||
        ' SELECT fecha_emision, num_credito, secuencia, nlinea, NVL(si_paga,'' ''), mensajes FROM bdicred:sd_mensajes_edoctacrd a'||
        ' WHERE a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| 
        '''  AND a.num_credito not in (select num_credito from  pp_creditos ) and num_credito <> "6300500" and a.num_producto = '''||6300||''' ORDER BY 2,3,4"'||
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
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> "||v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

    LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
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
            ''' AND num_credito not in (select num_credito from  pp_creditos ) AND num_credito =  "6300500" ORDER BY fecha_emision,num_credito,secuencia,nlinea"'||
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
        ' left join   bdicred:sd_config_mensaje_edocta b on b.num_producto = '''||6300||''' '||
		' where a.num_credito =a.num_credito and a.secuencia= ''1'' '||
		' and a.fecha_emision >'''||pperiodo1|| ''' AND a.fecha_emision <= '''||pperiodo2|| ''' '||
        ' AND a.num_credito not in (select num_credito from  pp_creditos ) and a.num_credito <> '''||6300500||'''   and a.num_producto = '''||6300||''' '||
		' order by a.num_credito,b.clave "'||
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
     LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" >> "||v_ruta||'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
     SYSTEM v_sql;

   /* LET v_sql = '';
	LET v_sql = " compress " || v_ruta||'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
    SYSTEM v_sql;*/

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descarga1.unl';
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
            ''' AND a.num_credito not in (select num_credito from  pp_creditos ) and a.num_credito = '''||6300600||''' ORDER BY a.fecha_emision"'||
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
            '''AND a.num_credito not in (select num_credito from  pp_creditos )  and a.fecha_emision = b.fecha_emision and a.num_credito = b.num_credito and b.num_producto in('''||6300||''','''||7600||''','''||7700||''') ORDER BY a.fecha_emision"'||
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

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "mv " || v_ruta|| 'Archivo63500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
							   trim(v_ruta_cfd) ||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  --COMPRIMIR YA QUE AL PASAR SE PASA SIN COMPRIMIR PARA DEJAR EL MISMO NOMBRE
		  LET v_sql = '';
		  LET v_sql = " compress " || trim(v_ruta_cfd)||'Archivo63500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "cp " || v_ruta|| 'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z '||
							   trim(v_ruta_cfd) ||'Archivo63600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.Z ';
		  SYSTEM v_sql;
	  --FIN DE COPIAR A LA RUTA DE CFD.


  END;
  RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Se realiza procedimiento para generar los archivos',
'de cada una de las tablas que componen el estado de',
'cuenta para créditos reestructurados',
'AUTOR : Bernardo Baez',
'FECHA : 23/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_compac_genera_reporte_tmp2(pEmpresa CHAR(3), pTipoReporte INTEGER, pFechaIni DATE, pFechaFin DATE, pProducto CHAR(4))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(80) AS Nombre_archivo,
		  CHAR(80) AS ruta; 
	---DECLARACIONES
	DEFINE cCodRet        	  CHAR(6); 
	DEFINE cMensajeRet        CHAR(80);
	DEFINE iSqlErr      	  INTEGER;
	DEFINE iIsamErr           INTEGER;
	DEFINE cErrorInfo         CHAR(80);
	DEFINE cNombreArchivo	  CHAR(80);
	DEFINE iNumArchivo		  INTEGER;
	DEFINE cTipoArchivo	      CHAR(80);
	DEFINE cConsulta		  CHAR(2200);
	DEFINE cConsulta2		  CHAR(500);
	DEFINE cConsulta3		  CHAR(500);
	DEFINE cSql		 		  CHAR(3000);
	DEFINE cParam1		      CHAR(20);
	DEFINE cParam2		      CHAR(20);
	DEFINE cParam3		      CHAR(20);
	DEFINE cParam4			  CHAR(20);
	DEFINE cRuta		      CHAR(80);
	DEFINE cTabla		      CHAR(1);
	DEFINE dtFecha		      DATE;

	DEFINE vvCodRet       	  CHAR(5);  
	DEFINE vvMensajeRet       CHAR(80);
	DEFINE vvNombreArchivo	  CHAR(80);
	DEFINE dtFechaIni         DATE;
	DEFINE dtFechaFin         DATE;
	DEFINE cArch_medidor_compac	  CHAR(15);
	DEFINE cRandomId           CHAR(30);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cMensajeRet         = "PROCESO EXITOSO";
	LET iNumArchivo			= 0;
	LET cNombreArchivo		= "reporte";
	LET cTipoArchivo     	= "";
	LET cConsulta			= "";
	LET cConsulta2			= "";
	LET cConsulta3			= "";
	LET cParam1				= "";
	LET cParam2				= "";
	LET cParam3				= "";
	LET cParam4 			= "";
	LET cRuta				= "";
	LET cTabla				= "N";
	LET dtFecha				= DATE(1);
	LET vvCodRet        = ''; 
	LET vvMensajeRet    = '';
	LET vvNombreArchivo	= '';
	LET dtFechaIni    = DATE(1);
	LET dtFechaFin    = DATE(1);
	LET cArch_medidor_compac	= '_indsconvs_';
	LET cRandomId     = '';
       
	BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		IF cTabla="S" THEN
			-- DROP TABLE cb_med_pagomin_rep;
		END IF;
		RETURN cCodRet, cMensajeRet,"", cRuta;
	END EXCEPTION;

	  -- SET DEBUG FILE TO '/tmp/mfinis/sp_compac_genera_reporte_tmp2.out';   
	  -- TRACE ON;
	  

	  SELECT substr(current year to day ,1,4)||
			 substr(current year to day ,6,2)||
			 substr(current year to day ,9,2)|| '_' ||
			 substr(current hour to second ,1,2)||
			 substr(current hour to second ,4,2)||
			 substr(current hour to second ,7,2)||
			 dbinfo('sessionid')
		INTO cRandomId
		FROM systables where tabid=1; 

	IF NVL(pEmpresa,"") = "" OR  NVL(pTipoReporte,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
		LET cCodRet= "000001";
		LET cMensajeRet = "Parametro no valido para realizar la consulta";
		RETURN cCodRet, cMensajeRet,"", cRuta;
	END IF;

	--se obtiene la ruta donde se almacenara el archivo generado.
		SELECT  TRIM(valor_alfabetico) 
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11  
		AND  grupo_parametro = 'RUTAS'
		AND num_parametro =1;


	IF NVL(cRuta,"") = "" THEN
		LET cCodRet= "000002";
		LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
		RETURN cCodRet, cMensajeRet,"", cRuta;
	END IF;		


			--consulta la fecha base 
			SELECT fecha_hoy   
			INTO dtFecha 
			FROM bdicred:"informix".sd_fechas
			WHERE empresa = pEmpresa;

	 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_med_pagomin_rep_t'  AND dbsname = 'bdicred') THEN
			DROP TABLE "informix".sd_med_pagomin_rep_t;
	 END IF;

	 IF pTipoReporte = 2 THEN

	  LET cNombreArchivo= TRIM(cNombreArchivo)|| TRIM(cArch_medidor_compac) || TRIM(cRandomId)||'_'||pProducto;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
		  FOREACH WITH HOLD 
		  SELECT num_archivo,tipo_archivo,query,param1,param2,param3,param4
			INTO iNumArchivo,cTipoArchivo,cConsulta,cParam1,cParam2,cParam3,cParam4		
			FROM  bdicobranza:"informix".cb_param_archivos 
			WHERE num_archivo = 5
	 
		  IF cParam1 IN ('001','1','2') THEN
					LET cConsulta= replace( cConsulta , 'Param1' , "'"||TRIM(cParam1)||"'");
				END IF;
				
				IF cParam2 = 'Fecha Inicio' THEN
					LET cParam2 = pFechaIni;
					LET cConsulta= replace( cConsulta , 'Param2' , "'"||TRIM(cParam2)||"'");
				END IF;
				
				IF cParam3 = 'Fecha Fin' THEN
					LET cParam3 = pFechaFin;
					LET cConsulta= replace( cConsulta , 'Param3' , "'"||TRIM(cParam3)||"'");
				END IF;
		
				IF cParam4 = 'Numero Producto' THEN
					LET cParam4 = pProducto;
					LET cConsulta = replace( cConsulta , 'Param4' , "'"||TRIM(cParam4)||"'");
				END IF;
			  LET dtFechaIni = pFechaIni;
			  LET dtFechaFin = pFechaFin;
			

		  IF  cTabla="N" THEN 
					CREATE TABLE "informix".sd_med_pagomin_rep_t(
					  SUCURSAL   CHAR(20),
					  NUMERO_CONVENIO	CHAR(20),
					  IMPORTE_CONVENIADO CHAR(20),
					  IMPORTE_PAGADO	CHAR(20),
					  CUMPLIMIENTO CHAR(20)
			);
					LET cTabla="S";
				END IF;
				
				LET cConsulta2 = 'INSERT INTO "informix".sd_med_pagomin_rep_t (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)';
				IF cParam1 = '1' THEN
					INSERT INTO "informix".sd_med_pagomin_rep_t (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
					VALUES("COMPROMISOS","","","","");
				ELIF cParam1 = '2' THEN
					INSERT INTO "informix".sd_med_pagomin_rep_t (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
					VALUES("ACUERDOS","","","","");
				END IF;
				LET cConsulta3 = 'SELECT SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO FROM  "informix".sd_med_pagomin_rep_t';
				INSERT INTO "informix".sd_med_pagomin_rep_t (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
				VALUES("SUCURSAL","NUMERO DE CONVENIO","IMPORTE CONVENIADO","IMPORTE PAGADO","CUMPLIMIENTO");
	 
		  -- Primero descargar archivo
			  LET cSql = '';
				LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query32.sql';
				SYSTEM TRIM(cSql);
			
			 LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicred ' ||TRIM(cRuta)||'query32.sql';
			SYSTEM TRIM(cSql);
				
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			  LET cSql = '';
			  LET cSQL = "rm " ||trim(cRuta)||'query32.sql';
			  SYSTEM trim(cSql); 
			  LET cSql = '';

			LET cSql = '';
			LET cSql = 'echo "LOAD FROM ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta2)||'" > '|| TRIM(cRuta) ||'query42.sql';
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicred ' ||TRIM(cRuta)||'query42.sql';
			SYSTEM TRIM(cSql);
				
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||trim(cRuta)||'query42.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
				
		  END FOREACH; 
	 ELIF pTipoReporte = 3 THEN

			LET dtFechaIni = pFechaIni;
			LET dtFechaFin = pFechaFin;

		  CALL "informix".sp_compac_pagomin_sdovenc2(pEmpresa, dtFechaIni, dtFechaFin, pProducto) Returning vvCodRet, vvMensajeRet, vvNombreArchivo;  
		  
			 LET cNombreArchivo= TRIM(vvNombreArchivo);
						  
		  if vvCodRet <> '00000' then
			  LET cCodRet = '000997'; 
			  LET cMensajeRet = 'Error en call sp_compac_pagomin_sdovenc.';
			  RETURN cCodRet, trim(cMensajeRet),cNombreArchivo, cRuta;
		  else    
			  RETURN cCodRet, cMensajeRet,cNombreArchivo, cRuta;
		  end if;
	 
	 END IF;

			LET cConsulta3 =' '||TRIM(cConsulta3);
			LET cSql = '';
		
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.txt '|| TRIM(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1927.sql';
		SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicred ' ||TRIM(cRuta)||'query1927.sql';
			SYSTEM TRIM(cSql);
			
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||trim(cRuta)||'query1927.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			  
			IF cTabla="S" THEN
				DROP TABLE "informix".sd_med_pagomin_rep_t;
			END IF;
			LET cNombreArchivo= TRIM(cNombreArchivo)||'.txt';
			
			LET cSql = '';
		LET cSql = "gzip  " ||trim(cRuta)|| trim(cNombreArchivo);
		SYSTEM trim(cSql);
		
		LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
			
			
			RETURN cCodRet, cMensajeRet,cNombreArchivo, cRuta;
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la generacion de archivos de los tipos de reportes para estadistica de convenios',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110404.0850',
'Se modifica para que use el tabulador como separador en la generación del archivo',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 20/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110420.1250',
'2012-05-16 Si existe borrar la tabla "informix".cb_med_pagomin_rep al inicio del proceso. Autor: Marco A. Campos',
'AUTOR : Mohamed Carreón',
'FECHA : 23/08/2012',
'BD    : BDICRED',
'Version: 20120823.1703',
'Se modifica para migrar el sp a la bd bdicred y para cambiar de nombre las columnas y agregar 1 coumna nueva esto para el archivo tipo 3.',
'AUTOR : Guadalupe Angelica Herández Pérez',
'FECHA : 02/07/2016',
'BD    : BDICRED',
'DESCRIPCION: Se modifica para eliminar los archivos .sql y ademas agregar la  ruta campleta para al descarga de archivos.',
'AUTOR : Guadalupe Angelica Herández Pérez',
'FECHA : 05/08/2016',
'BD    : BDICRED',
'DESCRIPCION: Se realizo una modificación para el num_archivo de 4 cambiarlo a 5 para poder realizar correctamente la consulta ya que en otros ambientes ya se utiliza el numero asigando con anterioridad.',
'FECHA : 11/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica el nombre del sql que se genera internamente';

CREATE PROCEDURE "informix".sp_compac_pagomin_sdovenc2(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pProducto CHAR(4))
	RETURNING CHAR(5)  AS codigo_retorno,
		CHAR(80) AS mensaje_retorno,
		CHAR(80) AS Nombre_archivo; 
		
		---DECLARACIONES
	DEFINE cCodRet         			CHAR(5); 
	DEFINE cMensajeRet      		CHAR(80);
	DEFINE iSqlErr            		INTEGER;
	DEFINE iIsamErr         		INTEGER;
	DEFINE cErrorInfo       		CHAR(80);
	DEFINE cNombreArchivo     		CHAR(80);
	DEFINE cNombreArchivo2  		CHAR(30);
	DEFINE iNumArchivo  			INTEGER;
	DEFINE cTipoArchivo         	CHAR(80);
	DEFINE cConsulta 				CHAR(2200);
	DEFINE cConsulta2 				CHAR(500);
	DEFINE cConsulta3 				CHAR(500);
	DEFINE cSql 					CHAR(2500);
	DEFINE cEncabezado				CHAR(1000);
	DEFINE cParam1 					CHAR(20);
	DEFINE cParam2 					CHAR(20);
	DEFINE cParam3 					CHAR(20);
	DEFINE cRuta 					CHAR(80);
	DEFINE cTabla 					CHAR(1);
	DEFINE cTabla_2        			CHAR(1);
	DEFINE cTabla_3 				CHAR(1);
	DEFINE dtFecha                  DATE;
	DEFINE dtFechaIni       		DATE;
	DEFINE dtFechaFin       		DATE;
	DEFINE vEmpresa         		CHAR(3);
	DEFINE vSucursal        		CHAR(4); 
	DEFINE vUsuario         		CHAR(8);
	DEFINE vNumPagosMinOk   		INTEGER;
	DEFINE vNumPagosMinNok  		INTEGER;
	DEFINE vNumPagosVencOk  		INTEGER;
	DEFINE vNumPagosVencNok 		INTEGER;
	DEFINE vfecha_insert       		DATE;
	DEFINE vcant_a_recup_pm    		INTEGER;
	DEFINE vcant_recup_pm      		INTEGER;
	DEFINE vPct_PM_Recup       		DECIMAL(10,2);  
	DEFINE vcount_con_pagomin  		INTEGER;
	DEFINE vcount_sin_pagomin  		INTEGER; 
	DEFINE vPct_cumpl_PM       		DECIMAL(10,2);
	DEFINE vcant_a_recup_sv    		INTEGER;     
	DEFINE vcant_recup_sv      		INTEGER;
	DEFINE vPct_SV_Recup            DECIMAL(10,2); 
	DEFINE vcount_con_sv       		INTEGER;
	DEFINE vcount_sin_sv       		INTEGER; 
	DEFINE vPct_cumpl_SV       		DECIMAL(10,2);
	DEFINE d_cant_a_recup_pm   		DECIMAL(14,2);  
	DEFINE d_cant_recup_pm     		DECIMAL(14,2);
	DEFINE d_cant_a_recup_sv   		DECIMAL(14,2);
	DEFINE d_cant_recup_sv     		DECIMAL(14,2);
	DEFINE vPct_Cump_Recup_Cartera  DECIMAL(10,2);
	DEFINE vPct_PM_Recup_total 		DECIMAL(10,2);                 
	DEFINE vPct_SV_Recup_total 		DECIMAL(10,2);
	DEFINE cArch_pagomin       		CHAR(10);
	DEFINE cRandomId           		CHAR(30);
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "00000";
	LET cMensajeRet         = "PROCESO EXITOSO";
	LET iNumArchivo         = 0;
	--LET cNombreArchivo    = "rep_pm_sdovenc_";
	LET cNombreArchivo      = '';
	LET cTipoArchivo        = "";
	LET cConsulta           = "";
	LET cConsulta2          = "";
	LET cConsulta3          = "";
	LET cParam1             = "";
	LET cParam2             = "";
	LET cParam3             = "";
	LET cRuta               = "";
	LET cTabla              = "N";
	LET cTabla_2            = "N";
	LET cTabla_3            = "N";
	LET dtFecha             = DATE(1);
	LET vEmpresa            = '';
	LET vSucursal           = ''; 
	LET vUsuario            = '';
	LET vNumPagosMinOk      = 0;
	LET vNumPagosMinNok     = 0;
	LET vNumPagosVencOk     = 0;
	LET vNumPagosVencNok    = 0;
	LET dtFechaIni          = DATE(1);
	LET dtFechaFin          = DATE(1);
	LET cNombreArchivo2     = 'reporte';
			 
	LET vfecha_insert        = DATE(1);         
	LET vcant_a_recup_pm     = 0;
	LET vcant_recup_pm       = 0;
	LET vPct_PM_Recup        = 0;
	LET vcount_con_pagomin   = 0;
	LET vcount_sin_pagomin   = 0;
	LET vPct_cumpl_PM        = 0;
	LET vcant_a_recup_sv     = 0;
	LET vcant_recup_sv       = 0;
	LET vPct_SV_Recup                         = 0;
	LET vcount_con_sv        = 0; 
	LET vcount_sin_sv        = 0;
	LET vPct_cumpl_SV        = 0;
	LET d_cant_a_recup_pm    = 0;
	LET d_cant_recup_pm      = 0;
	LET d_cant_a_recup_sv    = 0;
	LET d_cant_recup_sv      = 0;
	LET vPct_Cump_Recup_Cartera = 0;
	LET vPct_PM_Recup_total  = 0;                 
	LET vPct_SV_Recup_total  = 0;
	LET cArch_pagomin = '_pagomin_';
	LET cRandomId = '';
	LET cEncabezado = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			LET cCodRet= iSqlErr;
			LET cMensajeRet = cErrorInfo;			
			RETURN cCodRet, cMensajeRet,"";
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/macf/sp_compac_pagomin_sdovenc.trc';
		--TRACE ON;
		
		
		IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_rep_pagos_pmsv_tmp'  AND dbsname = 'bdicred') THEN
			DROP TABLE "informix".sd_rep_pagos_pmsv_tmp;
		END IF;

                
		SELECT substr(current year to day ,1,4)|| 
			substr(current year to day ,6,2)|| 
			substr(current year to day ,9,2)|| '_' ||
			substr(current hour to second ,1,2)||
			substr(current hour to second ,4,2)||
			substr(current hour to second ,7,2)||
			dbinfo('sessionid')
		INTO cRandomId
		FROM systables where tabid=1; 
 
 
		LET dtFechaIni  = pFechaIni;
		LET dtFechaFin  = pFechaFin;
		
		IF NVL(pEmpresa,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" OR NVL(pProducto,"") = ""  THEN
			LET cCodRet= "00001";
			LET cMensajeRet = "Parametro no valido para realizar la consulta";
			RETURN cCodRet, cMensajeRet,"";
		END IF;
		
		--se obtiene la ruta donde se almacenara el archivo generado.
		SELECT  TRIM(valor_alfabetico) 
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11  
			AND  grupo_parametro = 'RUTAS'
			AND num_parametro =1;
	
	
		IF NVL(cRuta,"") = "" THEN
			LET cCodRet= "00002";
			LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
			RETURN cCodRet, cMensajeRet,"";
		END IF;
		
		SELECT fecha_hoy   
		INTO dtFecha 
		FROM bdicred:"informix".sd_fechas
		WHERE empresa=pEmpresa;

		LET cNombreArchivo= TRIM(cNombreArchivo2)|| TRIM(cArch_pagomin) || TRIM(cRandomId) ||'_'|| pProducto;
		
		LET cConsulta = "SELECT 'sucursal','Fecha','$ a Recup.PM','$ Recup.PM','%Cump.Recup PM','# de PM','# Sin PM','%Cump. #PM','$ a Recup.SV','$ Recup.SV','%Cump.Recup.SV', '# de Vencidos', '# sin Vencidos','%Cump. #Vencidos','%Cum.Recup.Cartera'" || 
	     ' FROM systables WHERE tabid = 1 UNION ' || 'SELECT sucursal,fecha_insert::CHAR(10),cant_a_recup_pm,cant_recup_pm,Pct_PM_Recup,count_con_pagomin,count_sin_pagomin,Pct_cumpl_PM,cant_a_recup_sv,cant_recup_sv,Pct_SV_Recup,count_con_sv,count_sin_sv,Pct_cumpl_SV, Pct_cump_recup_cartera ' || 'FROM sd_rep_pagos_pmsv ' || 'WHERE fecha_insert BETWEEN ' || "'" || dtFechaIni || "' AND '" || dtFechaFin  || "' AND num_producto='"||pProducto||"'" || ' ORDER BY 1 DESC';
		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'txt'|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query003.sql';
		SYSTEM TRIM(cSql);
					
		LET cSql = '';
		LET cSql = "/informix/bin/dbaccess bdicred " ||TRIM(cRuta)||'query003.sql';
		SYSTEM TRIM(cSql);
		
		-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
		LET cSql = '';
		LET cSQL = "rm " ||trim(cRuta)||'query003.sql';
		SYSTEM trim(cSql); 
		LET cSql = '';

		LET cSql = '';
		LET cSql = "gzip " ||trim(cRuta)|| trim(cNombreArchivo) || '.' || 'txt';
		SYSTEM trim(cSql);
		
		LET cNombreArchivo= trim(cNombreArchivo)||'.txt.gz';         
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
		
	END
END PROCEDURE
DOCUMENT 
'Procedimiento para generar info de pago mínimo y saldo vencido para estadistica de convenios',
'AUTOR : Marco A. Campos',
'FECHA : 2014/07/23',
'BD    : bdicred',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 30/05/2016',
'MODULO: CREDITO',
'DESCRIPCION: Spl que genra el reporte de pago minimo, agegando a la consulta el num_producto', 
'BD: bdicred',
'AUTOR : Guadalupe Angelica Herández Pérez',
'FECHA : 02/07/2016',
'DESCRIPCION: Se modifica para eliminar los archivos .sql y ademas agregar la  ruta campleta para al descarga de archivos.',
'FECHA : 11/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica el nombre del sql que se genera internamente';

CREATE PROCEDURE "informix".sp_consultarcompromisosacuerdos2(pEmpresa      	CHAR(3), 
															pNumDivision  	INTEGER, 
															pNumRegion    	INTEGER, 
															pNumSucursal  	CHAR(4), 
															pFechaInicio  	CHAR(10), 
															pFechaFin     	CHAR(10),
															pUsuario      	CHAR(8),
															pTipoEjecucion 	SMALLINT,
															pOrigen			SMALLINT,
															pProducto       CHAR(4),
															pDiaCorte		SMALLINT,
															pRegistros      INTEGER,
															pRecuperacion   INTEGER)
	  RETURNING CHAR(6)        AS COD_RET,
				CHAR(80)       AS DESCRIPCION,
				VARCHAR(100)   AS DIVISION,
				CHAR(30)       AS REGION,
				CHAR(4)        AS SUCURSAL,
				INTEGER        AS NUM_RDOS_COMP,
				DECIMAL(18,2)  AS NEG_EFEC_VOL_COMP,
				DECIMAL(18,2)  AS IMP_NEG_COMP,
				DECIMAL(18,2)  AS IMP_REC_COMP,
				DECIMAL(18,2)  AS NEG_EFEC_MONT_COMP,
				DECIMAL(8,2)   AS PORC_CUMP_COMP,
				INTEGER        AS NUM_RDOS_ACUE,
				DECIMAL(18,2)  AS NEG_EFEC_VOL_ACRD,
				DECIMAL(18,2)  AS IMP_NEG_ACUE,
				DECIMAL(18,2)  AS IMP_REC_ACUE,
				DECIMAL(18,2)  AS NEG_EFEC_MONT_ACRD,
				DECIMAL(8,2)   AS PORC_CUMP_ACUE,
				INTEGER  		 AS NUM_CTES_CON_VDO,
				INTEGER   	 AS NUM_CONVENIOS,
				DECIMAL(8,2)   AS PORC_CTES_CONV,
				DECIMAL(18,2)  AS PESOS_CONVENIOS,
				DECIMAL(18,2)  AS PESOS_PAGO,
				DECIMAL(8,2)   AS PORC_REC_CONV,
				DATE           AS FECHA_ACUE_COMP,
				CHAR (80)      AS RUTA;

	---DECLARACIONES
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	DEFINE cCodRet              CHAR(6);
	DEFINE cMensajeRet          CHAR(80);
	DEFINE iNRows               INTEGER;
	DEFINE iDivision            INTEGER;
	DEFINE vcNomDivision        VARCHAR(100);
	DEFINE iRegion              INTEGER;
	DEFINE cNomRegion           CHAR(30);
	DEFINE cSucursal            CHAR(4);
	DEFINE iNum_Rdos            INTEGER;
	DEFINE dImp_Neg             DECIMAL(18,2);
	DEFINE dImp_Rec             DECIMAL(18,2);
	DEFINE dPorc_Cump           DECIMAL(8,2);
	DEFINE iNum_Rdos_Comp       INTEGER;
	DEFINE dImp_Neg_Comp        DECIMAL(18,2);
	DEFINE dImp_Rec_Comp        DECIMAL(18,2);
	DEFINE dPorc_Cump_Comp      DECIMAL(8,2);
	DEFINE iNum_Rdos_Acue       INTEGER;
	DEFINE dImp_Neg_Acue        DECIMAL(18,2);
	DEFINE dImp_Rec_Acue        DECIMAL(18,2);
	DEFINE dPorc_Cump_Acue      DECIMAL(8,2);
	DEFINE dtFechaAcueComp       DATE;
	DEFINE cUsuario             CHAR(8);
	DEFINE iNumSesion           INTEGER;
	DEFINE iId_sesion           INTEGER;
	DEFINE iRegistros           INTEGER;
	DEFINE iContador            INTEGER;
	DEFINE cNombreArchivo	  	CHAR(80);
	DEFINE cSql          		CHAR(1024);
	DEFINE cRuta		      	CHAR(80);   
	DEFINE cConsulta		  	CHAR(2200);
	DEFINE cTabla		      	CHAR(1); 
	DEFINE cFechaAcueComp	  	CHAR(10); 	
	--Declaracion Variables Fechas.
	DEFINE dtFechaHoy 			DATE;	
	DEFINE dtFechCortInmAnt		DATE;
	DEFINE dtFechCortMesSig		DATE;
	----Declaracion Variables Archivo.
	DEFINE dNegEfectVolComp 	DECIMAL(18,2);
	DEFINE dNegEfectMontComp 	DECIMAL(18,2);
	DEFINE dNegEfectVolAcue 	DECIMAL(18,2);
	DEFINE dNegEfectMontAcue 	DECIMAL(18,2);
	DEFINE vDia, vMes         CHAR(2);
	DEFINE vAnio              CHAR(4);
	DEFINE cFechCortInmAnt_2, cFechCortMesSig_2 CHAR(10);		
	DEFINE vSucursal          CHAR(4);
	DEFINE vSuma              DECIMAL(18,2);			
	DEFINE vNegEfecMonCom     DECIMAL(18,2);
	DEFINE vMonAcue           DECIMAL(18,2);
	DEFINE vPartNum_min       INTEGER;
	DEFINE vPartNum_max       INTEGER;
	DEFINE dtFechaInicio       DATE;
	DEFINE dtFechaFin          DATE;
	----Declaracion Variables del anexo de columnas a la tabla tme_encabezadosexcel.
	DEFINE	iNumCtesVdo		INTEGER;
	DEFINE	iNumConvenios	INTEGER;
	DEFINE	dPorcCtesConv	DECIMAL(8,2);
	DEFINE	dPesosConvenios	DECIMAL(18,2);
	DEFINE	dPesosPago		DECIMAL(18,2);
	DEFINE	dPorcRecConv	DECIMAL(8,2);
	--DEFINE  vSucursalCAT  CHAR(4);	
	DEFINE vRegs          INTEGER;		  			  

	---INICIALIZACIONES
	LET iSqlErr                 = 0;
	LET iIsamErr                = 0;
	LET cErrorInfo              = "";
	LET cCodRet                 = "000000";
	LET cMensajeRet             = "PROCESO EXITOSO";
	LET iNRows                  = 0;
	LET iDivision               = 0;
	LET vcNomDivision           = "";
	LET iRegion                 = 0;
	LET cNomRegion              = "";
	LET cSucursal               = "";
	LET iNum_Rdos               = 0;
	LET dImp_Neg                = 0.0;
	LET dImp_Rec                = 0.0;
	LET dPorc_Cump              = 0.0;
	LET iNum_Rdos_Comp          = 0;
	LET dImp_Neg_Comp           = 0.0;
	LET dImp_Rec_Comp           = 0.0;
	LET dPorc_Cump_Comp         = 0.0;
	LET iNum_Rdos_Acue          = 0;
	LET dImp_Neg_Acue           = 0.0;
	LET dImp_Rec_Acue           = 0.0;
	LET dPorc_Cump_Acue         = 0.0;
	LET dtFechaAcueComp          = DATE(1);
	LET cUsuario                = "";  
	LET iNumSesion              = 0;
	LET iId_sesion              = 0;
	LET iRegistros              = 0;
	LET iContador               = 0;
	LET cNombreArchivo          = "";
	LET cSql             		= "";
	LET cRuta					= "";
	LET cConsulta               = "";
	LET cTabla					= "N";
	LET cFechaAcueComp          = "";	
	--Inicializacion Variables Fechas.
	LET dtFechaHoy 				= DATE(1);	 --01/01/1900
	LET dtFechCortInmAnt		= DATE(1);
	LET dtFechCortMesSig		= DATE(1);				
	--Inicializacion Variables Archivo.
	LET dNegEfectVolComp 		= 0.00;
	LET dNegEfectMontComp 		= 0.00;
	LET dNegEfectVolAcue 		= 0.00;
	LET dNegEfectMontAcue 		= 0.00;
	LET vDia = ''; LET vMes = ''; LET vAnio = '';
	LET cFechCortInmAnt_2 = ''; LET cFechCortMesSig_2 = '';
	LET vSucursal         = '';
	LET vSuma             = 0.00;
	LET vNegEfecMonCom    = 0.00;
	LET vMonAcue          = 0.00;
	LET vPartNum_min = 0; LET vPartNum_max = 0;
	LET dtFechaInicio = pFechaInicio; 
	LET dtFechaFin =	pFechaFin;	
	---- Inicialización Variables del anexo de columnas a la tabla tme_encabezadosexcel.
	LET	iNumCtesVdo		= 0;
	LET	iNumConvenios	= 0;
	LET	dPorcCtesConv	= 0.0;
	LET	dPesosConvenios	= 0.0;
	LET	dPesosPago		= 0.0;
	LET	dPorcRecConv	= 0.0;
	--LET vSucursalCAT = '9999';
	LET vRegs = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			-- Se eliminan las tablas temporales
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;

				DELETE FROM bdicred:"informix".sd_consulta_acue_comp WHERE usuario = pUsuario;
				DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2 WHERE usuario = pUsuario;
                
				--SI EXISTEN SE ELIMINAN TABLAS TEMPORALES.				PROD= 3145810
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdos' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tmeacuerdos;
				END IF;				
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tmeacuerdosaompromisos2;
				END IF;				
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos3' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tmeacuerdosaompromisos3;
				END IF;															
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tempcomacue;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tempcomacue2;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom1' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tempcom1;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom4' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:tempcom4;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:bit_realiza_filtrada;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:bit_realiza_filtrada2;
				END IF;
				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada3' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE IF EXISTS bdicred:bit_realiza_filtrada3;
				END IF;
                
				IF cTabla="S" THEN   
					DROP  TABLE IF EXISTS bdicred:tme_encabezadosexcel;
				END IF;

				RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '', cRuta;

			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarcompromisosacuerdos2.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicred:"informix".sd_consulta_acue_comp WHERE usuario =  pUsuario;    ---MACF
		DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2 WHERE usuario =  pUsuario;  

		SELECT MIN(partnum) INTO vPartNum_min
		FROM sysmaster:SysTabNames;

		SELECT MAX(partnum) INTO vPartNum_max
		FROM sysmaster:SysTabNames;

		-- REALIZA VALIDACIONES GENERALES
		IF (NVL(pEmpresa,"") = "") OR (pNumDivision IS NULL) OR (pNumRegion IS NULL) OR (pNumSucursal IS NULL) OR (NVL(pFechaInicio,"") = "") 
				OR (NVL(pFechaFin,"") = "") OR (NVL(pUsuario,"") = "") 	OR (pTipoEjecucion NOT IN (1,2,3)) THEN
			
			LET cCodRet = "000001";
			LET cMensajeRet = "PARAMETRO INVALIDO";						
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '', cRuta;
			
		END IF;

		--SI EXISTEN SE ELIMINAN TABLAS TEMPORALES.				   PROD= 3145810
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdos' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tmeacuerdos;
		END IF;				
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tmeacuerdosaompromisos2;
		END IF;				
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos3' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tmeacuerdosaompromisos3;
		END IF;															
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tempcomacue;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tempcomacue2;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom1' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tempcom1;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom4' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:tempcom4;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:bit_realiza_filtrada;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:bit_realiza_filtrada2;
		END IF;
		
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada3' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP TABLE IF EXISTS bdicred:bit_realiza_filtrada3;
		END IF;

		SELECT DBINFO('sessionid')
		INTO iNumSesion
		FROM "informix".systables
		WHERE tabname = 'systables';
		
		IF pTipoEjecucion = 3 THEN
		
			SET ISOLATION TO DIRTY READ;
			LET pRegistros = pRegistros + 2;
				
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion nom_division, nom_region, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp, neg_efecmonto_comp, porc_cump_comp, num_rdos_acue, 
						neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv, 
						MDY(MONTH(to_date(fecha_acuecomp, '%d-%m-%Y')), DAY(to_date(fecha_acuecomp, '%d-%m-%Y')), YEAR(to_date(fecha_acuecomp, '%d-%m-%Y')))
					INTO vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp, dNegEfectMontComp, dPorc_Cump_Comp, iNum_Rdos_Acue,
						dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp
					FROM bdicred:tme_encabezadosexcel
					
				RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
				
				LET iContador = iContador + 1; 
							
			END FOREACH;
			
			

			LET pRegistros = pRegistros - 2;
			
			IF iContador = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '000002';
				ELIF pRegistros > 0 THEN
					LET cCodRet = '001001';
				END IF;
				
				RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
			END IF;
		
		END IF;
		
				--Se obtiene la ruta donde se almacenara el archivo generado.
		SELECT  TRIM(valor_alfabetico) 
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11  
			AND  grupo_parametro = 'RUTAS'
			AND num_parametro =1;

		IF NVL(cRuta,"") = "" THEN
			LET cCodRet= "000004";
			LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";						
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '', cRuta;
		END IF;	

		IF pTipoEjecucion = 2 THEN 
			LET cNombreArchivo= TRIM(pUsuario)||iNumSesion||DAY(CURRENT) || LPAD(TRIM(MONTH(CURRENT)::CHAR(2)),2,'0') || YEAR(CURRENT) || pProducto;
			LET cConsulta = "SELECT fecha_acuecomp,sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp,imp_rec_comp, neg_efecmonto_comp, porc_cump_comp, num_rdos_acue, neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv FROM tme_encabezadosexcel";
        
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query.sql';
			SYSTEM TRIM(cSql);
        
			LET cSql = '';
			LET cSql = '/informix/bin/dbaccess bdicred ' ||TRIM(cRuta)||'query.sql';
			SYSTEM cSql;
			LET cSql = '';
			SYSTEM cSql; 
			
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSql = 'rm ' || TRIM(cRuta)||'query.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			
			LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';				
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '', cRuta;
		END IF; 

		IF pTipoEjecucion = 1  AND pRegistros = 0 THEN 
			IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tme_encabezadosexcel' AND dbsname='bdicred' AND partnum > 3145810) THEN
				DROP  TABLE IF EXISTS bdicred:tme_encabezadosexcel;
				--DELETE FROM bdicred:tme_encabezadosexcel;
				
			END IF;

			CREATE TABLE tme_encabezadosexcel(
				fecha_acuecomp     CHAR(10),
				sucursal   		   CHAR(10),
				num_rdos_comp	   CHAR(20),
				neg_efecvol_comp   CHAR(40),
				imp_neg_comp       CHAR(20),
				imp_rec_comp	   CHAR(20),
				neg_efecmonto_comp CHAR(40),
				porc_cump_comp     CHAR(20),
				num_rdos_acue      CHAR(20),
				neg_efecvol_acue   CHAR(40),
				imp_neg_acue       CHAR(20),
				imp_rec_acue       CHAR(20),
				neg_efecmonto_acue CHAR(40),
				porc_cump_acue     CHAR(20),
				num_ctes_con_vdo   CHAR(40),
				num_convenios      CHAR(20),
				porc_ctes_conv     CHAR(20),
				pesos_convenios    CHAR(20),
				pesos_pago         CHAR(20),
				porc_rec_conv      CHAR(20),
				nom_division       CHAR(100),
				nom_region         CHAR(30)
			);
			
			LET cTabla="S";

			--se agrega encabezado para el archivo excel
			INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp, neg_efecmonto_comp, porc_cump_comp,num_rdos_acue, neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv)
			VALUES("","COMPROMISOS","","","","","","","ACUERDOS","","","","","","RECUPERADO POR CONVENIO","","","","","");
			
			INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv)
			VALUES("FECHA","SUCURSAL","No. REALIZADOS","NEG. EFECTIVA (VOLUMEN) %","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","NEG. EFECTIVA (MONTO) %","% CUMPLIMIENTO","No. REALIZADOS","NEG. EFECTIVA (VOLUMEN) %","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","NEG. EFECTIVA (MONTO) %","% CUMPLIMIENTO","# CTES. C/VDO.","# CONV.","% CTES. CONV.","$ CONV. (MILES)","$ PAGO (MILES)","% REC. CONVENIO");

		--END IF;

		--se obtiene el numero de registros a retornar en la consulta
		SELECT NVL(valor_numerico,0)::INTEGER
		INTO iRegistros
		FROM bdicobranza:"informix".cb_param_campania
		WHERE empresa = '001'
		AND tipo_campania = 21 
		AND grupo_parametro = 'ESTADCOYAC'
		AND num_parametro = 1;

		IF NVL(iRegistros,0) = 0 THEN
			LET cCodRet= "000003";
			LET cMensajeRet = "No se pudo obtener el numero de registros a retornar";						
			
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '', cRuta;
		END IF;	 
        
		IF pOrigen = 3 THEN
		
			IF pProducto = '6001' THEN 
				SELECT COUNT(*) INTO iNRows
				FROM  bdicobranza:"informix".cb_compac_his com
				WHERE (com.fecha_insert >= dtFechaInicio AND fecha_insert <= dtFechaFin)
					AND com.empresa = '001'
					AND com.tipo_compac = "1"
					AND com.origen = 3
					AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred	WHERE num_producto = pProducto AND num_credito = com.numcuenta);	
			ELSE
				SELECT COUNT(*) INTO iNRows
				FROM  bdicobranza:"informix".cb_compac_his com
				WHERE (com.fecha_insert >= dtFechaInicio AND fecha_insert <= dtFechaFin)
					AND com.empresa = '001'
					AND com.tipo_compac = "1"
					AND com.origen = 3
					AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = com.numcuenta);
			END IF;
        
			IF iNRows <= 0 THEN
				LET cCodRet = "000002";
				LET cMensajeRet = "NO EXISTEN DATOS PARA ESTA CONSULTA";
				RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,0,0,0,0,0,MDY(1,1,1900), cRuta;
			END IF; 
        
			---division, nom_division, region, nom_region  0,'CAT',0,'CAT'
			IF pProducto = '6001' THEN 
			
				INSERT INTO bdicred:"informix".sd_consulta_acue_comp_2 (sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp, imp_rec_comp, porc_cump_comp, usuario, id_sesion)

				SELECT ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2),  
					  SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2), pUsuario, iNumSesion
				  FROM bdicobranza:cb_compac_his ch INNER JOIN bdicred:"informix".sd_maecred cr ON cr.empresa=ch.empresa AND  cr.num_credito=ch.numcuenta
				 WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
				   AND ch.empresa = '001'
				   AND ch.tipo_compac = "1"
				   AND ch.origen = 3
				   AND cr.num_producto=pProducto
				 GROUP BY ch.sucursal, ch.fecha_insert;
			ELSE 
				INSERT INTO bdicred:"informix".sd_consulta_acue_comp_2 (sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp, imp_rec_comp, porc_cump_comp, usuario, id_sesion)

				SELECT ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2),  
					  SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2), pUsuario, iNumSesion
				FROM bdicobranza:cb_compac_his ch INNER JOIN bdicred:"informix".sd_maecredcrd cr ON cr.empresa=ch.empresa AND  cr.num_credito=ch.numcuenta
				WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
				   AND ch.empresa = '001'
				   AND ch.tipo_compac = "1"
				   AND ch.origen = 3
				   AND cr.num_producto=pProducto
				 GROUP BY ch.sucursal, ch.fecha_insert;
			END IF;
						
			IF pProducto = '6001'     THEN    
				SELECT ch.sucursal as sucursal, ch.fecha_insert as fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue, SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,  
						SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2) AS porc_cump_acue, pUsuario AS usuario, iNumSesion AS id_sesion
				FROM bdicobranza:cb_compac_his ch 
				WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND ch.empresa = '001'
					AND ch.tipo_compac = "2"
					AND ch.origen = 3
					AND ch.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = ch.numcuenta)
				GROUP BY ch.sucursal, ch.fecha_insert
				INTO TEMP tmeacuerdos WITH NO LOG;
			ELSE 
				SELECT ch.sucursal as sucursal, ch.fecha_insert as fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue, SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,  
						SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2) AS porc_cump_acue, pUsuario AS usuario, iNumSesion AS id_sesion
				FROM bdicobranza:cb_compac_his ch 
				WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND ch.empresa = '001'
					AND ch.tipo_compac = "2"
					AND ch.origen = 3
					AND ch.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = ch.numcuenta)
				GROUP BY ch.sucursal, ch.fecha_insert
				INTO TEMP tmeacuerdos WITH NO LOG;
			END IF;
			
			SELECT t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue, t2.porc_cump_acue , t1.usuario , t1.id_sesion
			FROM bdicred:sd_consulta_acue_comp_2 t1, bdicred:tmeacuerdos t2
			WHERE t1.sucursal = t2.sucursal 
				AND t1.fecha_acuecomp = t2.fecha
				AND t1.usuario   =  pUsuario
				AND t1.id_sesion = iNumSesion
			INTO TEMP tmeacuerdosaompromisos2 WITH NO LOG;
			
			DROP TABLE IF EXISTS tme_acuerdosaompromisos2;
			
			SELECT sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
					FROM bdicred:tmeacuerdosaompromisos2
					WHERE usuario  = pUsuario
					AND id_sesion = iNumSesion
			INTO TEMP tme_acuerdosaompromisos2 WITH NO LOG;		
			
			MERGE INTO  {+INDEX(bdicred:sd_consulta_acue_comp_2 inx_pk_consulta_acue_comp2)} bdicred:sd_consulta_acue_comp_2 a
			USING tme_acuerdosaompromisos2 b ON a.sucursal=b.sucursal AND b.fecha= a.fecha_acuecomp AND  a.usuario  = pUsuario AND a.id_sesion =  iNumSesion
			WHEN MATCHED THEN
			UPDATE SET a.num_rdos_acue = b.num_rdos_acue ,
					   a.imp_neg_acue = b.imp_neg_acue ,
					   a.imp_rec_acue = b.imp_rec_acue ,
					   a.porc_cump_acue = b.porc_cump_acue;
			
			SELECT t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue, t2.porc_cump_acue, t2.usuario, t2.id_sesion
			FROM bdicred:sd_consulta_acue_comp_2 t1 
			RIGHT OUTER JOIN bdicred:tmeacuerdos t2 ON ( t1.sucursal = t2.sucursal AND 
				t1.fecha_acuecomp = t2.fecha AND 
				t1.usuario = t2.usuario AND 
				t1.id_sesion = t2.id_sesion )
			INTO TEMP tmeacuerdosaompromisos3 WITH NO LOG;
        
		
			MERGE INTO  {+INDEX(bdicred:sd_consulta_acue_comp_2 inx_pk_consulta_acue_comp2)} bdicred:sd_consulta_acue_comp_2 a
			USING tmeacuerdosaompromisos3 b ON a.sucursal=b.sucursal AND a.fecha_acuecomp=b.fecha AND a.usuario=pUsuario AND a.id_sesion=b.id_sesion
			WHEN MATCHED THEN
			UPDATE SET a.num_rdos_acue = b.num_rdos_acue ,
					   a.imp_neg_acue = b.imp_neg_acue ,
					   a.imp_rec_acue = b.imp_rec_acue ,
					   a.porc_cump_acue = b.porc_cump_acue
			WHEN NOT MATCHED THEN
				INSERT (a.sucursal, a.fecha_acuecomp, a.num_rdos_acue, a.imp_neg_acue, a.imp_rec_acue, a.porc_cump_acue, a.usuario, a.id_sesion)
				VALUES(b.sucursal, b.fecha, b.num_rdos_acue, b.imp_neg_acue, b.imp_rec_acue, b.porc_cump_acue, b.usuario, b.id_sesion);
			
		ELSE
			----------------------------------------------------    CONSULTA DE COMPROMISOS   ----------------------------------------------------
			IF pProducto = '6001' THEN 
				INSERT INTO bdicred:"informix".sd_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp, imp_rec_comp, porc_cump_comp, usuario, id_sesion )
				SELECT reg.division, par.descripcion, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2), 
						SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2), pUsuario, iNumSesion
				FROM bdicobranza:"informix".cb_compac_his ch, 
					bdinteg:"informix".si_ciudades ciu, 
					bdinteg:"informix".si_catciudades cat,
					bdinteg:"informix".si_regiones reg,
					bdinteg:"informix".si_sucursales suc,
					bdicobranza:"informix".cb_param_campania par
				WHERE suc.estado  = ciu.estado
					AND suc.ciudad  = ciu.ciudad
					AND ch.sucursal = suc.sucursal
					AND cat.numerociudad  = ciu.ciudad_coppel
					AND cat.numero_region = reg.numero_region
					AND ch.tipo_compac = "1" 
					AND ch.empresa = pEmpresa
					AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
					AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
					AND par.num_parametro = reg.division
					AND par.grupo_parametro = "DIVISIONES"
					AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
					AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
					AND ch.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = ch.numcuenta)
				GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion;
			ELSE 
				
				INSERT INTO bdicred:"informix".sd_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp, imp_rec_comp, porc_cump_comp, usuario, id_sesion )
				SELECT reg.division, par.descripcion, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2), 
						SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2), pUsuario, iNumSesion
				FROM bdicobranza:"informix".cb_compac_his ch, 
					bdinteg:"informix".si_ciudades ciu, 
					bdinteg:"informix".si_catciudades cat,
					bdinteg:"informix".si_regiones reg,
					bdinteg:"informix".si_sucursales suc,
					bdicobranza:"informix".cb_param_campania par
				WHERE suc.estado  = ciu.estado
					AND suc.ciudad  = ciu.ciudad
					AND ch.sucursal = suc.sucursal
					AND cat.numerociudad  = ciu.ciudad_coppel
					AND cat.numero_region = reg.numero_region
					AND ch.tipo_compac = "1" 
					AND ch.empresa = pEmpresa
					AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
					AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
					AND par.num_parametro = reg.division
					AND par.grupo_parametro = "DIVISIONES"
					AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
					AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
					AND ch.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = ch.numcuenta)
				GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion;
			END IF;
			----------------------------------------------------    CONSULTA DE ACUERDOS   ----------------------------------------------------
			IF pProducto = '6001' THEN 
				SELECT reg.division AS division, par.descripcion AS nom_division, cat.numero_region AS region, reg.nombre_region AS nom_region, ch.sucursal AS sucursal,
						ch.fecha_insert AS fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue,SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,
						SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2) AS porc_cump_acue,
						pUsuario AS usuario, iNumSesion AS id_sesion 
				FROM bdicobranza:"informix".cb_compac_his ch, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catciudades cat,
					bdinteg:"informix".si_regiones reg, bdinteg:"informix".si_sucursales suc,  bdicobranza:"informix".cb_param_campania par
				WHERE suc.estado = ciu.estado
					AND suc.ciudad = ciu.ciudad
					AND ch.sucursal = suc.sucursal
					AND cat.numerociudad = ciu.ciudad_coppel
					AND cat.numero_region = reg.numero_region
					AND ch.tipo_compac = "2" 
					AND ch.empresa = pEmpresa
					AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
					AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
					AND par.num_parametro = reg.division
					AND par.grupo_parametro = "DIVISIONES"
					AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
					AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
					AND ch.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = ch.numcuenta)				
				GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion 
				INTO TEMP tmeacuerdos WITH NO LOG;
			ELSE 
				SELECT reg.division AS division, par.descripcion AS nom_division, cat.numero_region AS region, reg.nombre_region AS nom_region, ch.sucursal AS sucursal,
					ch.fecha_insert AS fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue,SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,
					SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(8,2) AS porc_cump_acue,
					pUsuario AS usuario, iNumSesion AS id_sesion 
				FROM bdicobranza:"informix".cb_compac_his ch, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catciudades cat,
					bdinteg:"informix".si_regiones reg, bdinteg:"informix".si_sucursales suc,  bdicobranza:"informix".cb_param_campania par
				WHERE suc.estado = ciu.estado
					AND suc.ciudad = ciu.ciudad
					AND ch.sucursal = suc.sucursal
					AND cat.numerociudad = ciu.ciudad_coppel
					AND cat.numero_region = reg.numero_region
					AND ch.tipo_compac = "2" 
					AND ch.empresa = pEmpresa
					AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
					AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
					AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
					AND par.num_parametro = reg.division
					AND par.grupo_parametro = "DIVISIONES"
					AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
					AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
					AND ch.numcuenta =  (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = ch.numcuenta)		
				GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion 
				INTO TEMP tmeacuerdos WITH NO LOG;
			END IF;
        
			SELECT t1.division, t2.region, t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue,
				t2.porc_cump_acue , t1.usuario , t1.id_sesion
			FROM bdicred:"informix".sd_consulta_acue_comp t1, bdicred:tmeacuerdos t2
			WHERE t1.division = t2.division 
				AND t1.region   = t2.region 
				AND t1.sucursal = t2.sucursal 
				AND t1.fecha_acuecomp = t2.fecha
				AND t1.usuario   =  pUsuario
				AND t1.id_sesion = iNumSesion
			INTO TEMP tmeacuerdosaompromisos2 WITH NO LOG;
			
			DROP TABLE IF EXISTS tme_acuerdosaompromisos2;
			
		        	SELECT division, region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
					FROM bdicred:tmeacuerdosaompromisos2
					WHERE usuario  = pUsuario
						AND id_sesion = iNumSesion
			INTO TEMP tme_acuerdosaompromisos2 WITH NO LOG;
			
			MERGE INTO  {+INDEX(bdicred:"informix".sd_consulta_acue_comp inx_pk_consulta_acue_comp)} bdicred:"informix".sd_consulta_acue_comp a
			USING tme_acuerdosaompromisos2 b ON b.division=a.division AND  b.region= a.region AND a.sucursal=b.sucursal AND a.fecha_acuecomp=b.fecha AND  a.usuario  = pUsuario AND a.id_sesion =  iNumSesion
			WHEN MATCHED THEN	
			UPDATE SET a.num_rdos_acue = b.num_rdos_acue ,
					   a.imp_neg_acue = b.imp_neg_acue ,
					   a.imp_rec_acue = b.imp_rec_acue ,
					   a.porc_cump_acue = b.porc_cump_acue;
				
			SELECT t2.division, t2.nom_division, t2.region, t2.nom_region, t2. sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue,  
				t2.imp_rec_acue, t2.porc_cump_acue, t1.division AS division2, t2.usuario, t2.id_sesion
			FROM bdicred:"informix".sd_consulta_acue_comp t1
			RIGHT OUTER JOIN bdicred:tmeacuerdos t2 ON (t1.division = t2.division AND t1.region = t2.region AND t1.sucursal = t2.sucursal 
					AND t1.fecha_acuecomp = t2.fecha AND t1.usuario = t2.usuario AND t1.id_sesion = t2.id_sesion)
			WHERE  t2.usuario = pUsuario
				AND t2.id_sesion = iNumSesion
			INTO TEMP tmeacuerdosaompromisos3 WITH NO LOG;
        
			INSERT INTO bdicred:"informix".sd_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion)
			SELECT division, nom_division, region, nom_region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion
			FROM bdicred:tmeacuerdosaompromisos3 
			WHERE division2 IS NULL
				AND usuario   =  pUsuario
				AND id_sesion = iNumSesion; 
        
		END IF;
        
		IF pOrigen <> 3 THEN																					
			--********************SE CALCULA LAS FECHAS PARA NEGOCIACIÓN EFECTIVA (Volumen-Monto)***********************
			--**********************************************************************************************************
			--SE OBTIENE LA FECHA DE HOY DEL SISTEMA.
			SELECT fecha_hoy
			INTO dtFechaHoy
			FROM bdicred:"informix".sd_fechas
			WHERE empresa = pEmpresa;  
			
			IF pProducto = '6001' THEN
			--SE VALIDA EL DIA DE LA FECHA DE HOY PARA CALCULAR LA FECHA CORTE INMEDIATA ANTERIOR Y FECHA CORTE MES SIGUIENTE.
						IF DAY(dtFechaHoy) > 20 THEN
							------------------------------------FECHA CORTE INMEDIATA ANTERIOR------------------------------------
							LET dtFechCortInmAnt = (MONTH(dtFechaHoy) UNITS MONTH || 21 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR)::DATE ;
							------------------------------------FECHA CORTE MES SIGUIENTE------------------------------------
							LET dtFechCortMesSig = (MONTH(dtFechaHoy) UNITS MONTH || 20 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE + 1 UNITS MONTH;
					
							LET vDia = day(dtFechCortInmAnt);
							IF month(dtFechCortInmAnt) < 10 then
								LET vMes = '0' || month(dtFechCortInmAnt);
							ELSE
								LET vMes = month(dtFechCortInmAnt);
							END IF;
							LET vAnio = year(dtFechCortInmAnt);
							LET cFechCortInmAnt_2 = vAnio || '/' || vMes || '/' || vDia;
					
							LET vDia = day(dtFechCortMesSig);
							IF month(dtFechCortMesSig) < 10 then
								LET vMes = '0' || month(dtFechCortMesSig);
							ELSE
								LET vMes = month(dtFechCortMesSig);
							END IF;
							LET vAnio = year(dtFechCortMesSig);
							LET cFechCortMesSig_2 = vAnio || '/' || vMes || '/' || vDia;
						ELSE		
							------------------------------------FECHA CORTE INMEDIATA ANTERIOR------------------------------------
							LET dtFechCortInmAnt = (MONTH(dtFechaHoy) UNITS MONTH || 21 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE - 1 UNITS MONTH;
							------------------------------------FECHA CORTE MES SIGUIENTE------------------------------------
							LET dtFechCortMesSig = (MONTH(dtFechaHoy) UNITS MONTH || 20 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE ;
					
							LET vDia = day(dtFechCortInmAnt);
							IF month(dtFechCortInmAnt) < 10 then
								LET vMes = '0' || month(dtFechCortInmAnt);
							ELSE
								LET vMes = month(dtFechCortInmAnt);
							END IF;
							LET vAnio = year(dtFechCortInmAnt);
							LET cFechCortInmAnt_2 = vAnio || '/' || vMes || '/' || vDia;
					
							LET vDia = day(dtFechCortMesSig);
							IF month(dtFechCortMesSig) < 10 then
								LET vMes = '0' || month(dtFechCortMesSig);
							ELSE
								LET vMes = month(dtFechCortMesSig);
							END IF;
							LET vAnio = year(dtFechCortMesSig);
							LET cFechCortMesSig_2 = vAnio || '/' || vMes || '/' || vDia;
						END IF; 
			ELSE
							------------------------------------FECHA CORTE INMEDIATA ANTERIOR------------------------------------
							LET dtFechCortInmAnt = (MONTH(dtFechaHoy) UNITS MONTH || (pDiaCorte+1) UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE - 1 UNITS MONTH;
							------------------------------------FECHA CORTE MES SIGUIENTE------------------------------------
							LET dtFechCortMesSig = (MONTH(dtFechaHoy) UNITS MONTH || (pDiaCorte) UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE ;
					
							LET vDia = day(dtFechCortInmAnt);
							IF month(dtFechCortInmAnt) < 10 then
								LET vMes = '0' || month(dtFechCortInmAnt);
							ELSE
								LET vMes = month(dtFechCortInmAnt);
							END IF;
							LET vAnio = year(dtFechCortInmAnt);
							LET cFechCortInmAnt_2 = vAnio || '/' || vMes || '/' || vDia;
					
							LET vDia = day(dtFechCortMesSig);
							IF month(dtFechCortMesSig) < 10 then
								LET vMes = '0' || month(dtFechCortMesSig);
							ELSE
								LET vMes = month(dtFechCortMesSig);
							END IF;
							LET vAnio = year(dtFechCortMesSig);
							LET cFechCortMesSig_2 = vAnio || '/' || vMes || '/' || vDia;
						    
			
			END IF;
			
			--**************************NEGOCIACIÓN EFECTIVA (volumen) PARA COMPROMISOS Y ACUERDOS********************************			
			----------------------------SE OBTIENE No. COMPROMISOS Y ACUERDOS REALIZADOS -----------------------------------------		
			--SE OBTIENE EL NUMERO DE COMPROMISOS Y ACUERDOS ENTRE UN RANGO DE FECHAS.
			-- Agrego que no se tomen los Compromisos y Acuerdos mismo día
			IF pProducto = '6001' THEN 
				SELECT Suc AS sucursal,COUNT(TotalComp) AS TotalCompromisos,COUNT(TotalAcue)  AS TotalAcuerdos		
					FROM TABLE (MULTISET (SELECT CASE WHEN t1.tipo_compac = "1" THEN t1.empresa END AS TotalComp,
						CASE WHEN t1.tipo_compac = "2" THEN t1.empresa END AS TotalAcue,
							t1.sucursal AS Suc																					
						FROM bdicobranza:"informix".cb_compac_his t1		 								  
						WHERE t1.tipo_compac in ("1","2")
							AND t1.origen = DECODE(pOrigen, 0, t1.origen, pOrigen)                           
							AND t1.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig  
							AND t1.fecha_insert <> t1.fecha_compac
							AND t1.plazo <> 1 
							AND t1.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = t1.numcuenta)))		
					GROUP BY Suc
					INTO TEMP tempcom1 WITH NO LOG;
			ELSE 
					SELECT Suc AS sucursal,COUNT(TotalComp) AS TotalCompromisos,COUNT(TotalAcue)  AS TotalAcuerdos		
					FROM TABLE (MULTISET (SELECT CASE WHEN t1.tipo_compac = "1" THEN t1.empresa END AS TotalComp,
						CASE WHEN t1.tipo_compac = "2" THEN t1.empresa END AS TotalAcue,
							t1.sucursal AS Suc																					
						FROM bdicobranza:"informix".cb_compac_his t1 INNER JOIN bdicred:"informix".sd_maecredanexocrd anexo ON anexo.num_credito=t1.numcuenta AND anexo.dia_corte=pDiaCorte	 								  
						WHERE t1.tipo_compac in ("1","2")
							AND t1.origen = DECODE(pOrigen, 0, t1.origen, pOrigen)                           
							AND t1.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig  
							AND t1.fecha_insert <> t1.fecha_compac
							AND t1.plazo <> 1 
							AND t1.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = t1.numcuenta)))						
				GROUP BY Suc
				INTO TEMP tempcom1 WITH NO LOG;
			END IF;

        
			---------------------------SE OBTIENE EL TOTAL DE CTES QUE ACUDIERON A REALIZAR COMPROMISOS Y ACUERDOS-----------------
			--- MACF: Agrego que filtre por origen en compac_his, pq en compac_bit_realiza solo se cuentan a los q se les ofrece convenio en Sucursal
			--- Modifico radicalmente este query pq solo debe obtenerse el conteo de cb_compac_bit_realiza rea 		
			--- totnumcte =num de veces que al cliente se le ofreció realizar un convenio cuando acudió a ventanilla. 
			IF pProducto = '6001' THEN
				SELECT {+INDEX(bdicobranza:"informix".cb_compac_bit_realiza idx_compacbitrealiza_fh)} rea.sucursal AS sucursal, --forzar por indice
					rea.numcliente AS numcte, fh_movimiento AS fechmov, COUNT(rea.numcliente) AS totnumcte,1 AS num_compacs  
				FROM bdicobranza:"informix".cb_compac_bit_realiza rea,
					 bdicred:"informix".sd_maecred cr
				WHERE fh_movimiento >= TO_DATE(cFechCortInmAnt_2, "%Y/%m/%d")
					AND fh_movimiento <= TO_DATE(cFechCortMesSig_2, "%Y/%m/%d")  
					AND rea.numcuenta = cr.num_credito 
					AND cr.num_producto = pProducto 
				GROUP BY rea.sucursal, fh_movimiento, rea.numcliente
				ORDER BY 1		
				INTO TEMP bit_realiza_filtrada WITH NO LOG;
			ELSE
				SELECT {+INDEX(bdicobranza:"informix".cb_compac_bit_realiza idx_compacbitrealiza_fh)} rea.sucursal AS sucursal, --forzar por indice
					rea.numcliente AS numcte, fh_movimiento AS fechmov, COUNT(rea.numcliente) AS totnumcte,1 AS num_compacs  
				FROM bdicobranza:"informix".cb_compac_bit_realiza rea,
				     bdicred:"informix".sd_maecredcrd crd,
					 bdicred:"informix".sd_maecredanexocrd anexo
				WHERE fh_movimiento >= TO_DATE(cFechCortInmAnt_2, "%Y/%m/%d")
					AND fh_movimiento <= TO_DATE(cFechCortMesSig_2, "%Y/%m/%d")  
					AND anexo.num_credito=rea.numcuenta AND anexo.dia_corte=pDiaCorte	 	
					AND rea.numcuenta = crd.num_credito 
					AND crd.num_producto = pProducto
				GROUP BY rea.sucursal, fh_movimiento, rea.numcliente
				ORDER BY 1		
				INTO TEMP bit_realiza_filtrada WITH NO LOG;
			END IF;
			---------------------------SE AGRUPA POR SUCURSAL Y SE HACE EL CONTEO DE COMPROMISOS Y DE ACUERDOS-------------------
			SELECT sucursal, count(num_compacs) as TotNumCompacs  
			FROM bit_realiza_filtrada
			GROUP by sucursal
			INTO TEMP bit_realiza_filtrada2 WITH NO LOG; 
			
			SELECT sucursal, count(totnumcte) as totnumcte  
			FROM bit_realiza_filtrada
			GROUP by sucursal
			INTO TEMP bit_realiza_filtrada3 WITH NO LOG;
        
        
			--SE REALIZA EL CALCULO PARA OBTENER LA NEGOCIACION EFECTIVA(VOLUMEN) Y SE OBTIENE 
			--LOS TOTALES DE NEGOCIACIÓN EFECTIVA(Volumen) TANTO PARA COMPROMISOS COMO PARA ACUERDOS.
			SELECT t3.sucursal as sucursal, 
				CASE WHEN t3.TotNumCompacs = 0 THEN 0 ELSE ROUND((t1.TotalCompromisos/t3.TotNumCompacs) * 100,2) END AS neg_com_por_suc,
				CASE WHEN t3.TotNumCompacs = 0 THEN 0 ELSE ROUND((t1.TotalAcuerdos/t3.TotNumCompacs) * 100,2) END AS neg_acue_por_suc,
				NVL(t4.totnumcte,0) AS totnumcte
			FROM tempcom1 t1, bit_realiza_filtrada2 t3, bit_realiza_filtrada3 t4
			WHERE t1.sucursal = t3.sucursal
				AND t4.sucursal = t3.sucursal
			GROUP BY 1,2,3,4
			INTO TEMP tempcom4 WITH NO LOG; 
        
        
							
			--************************NEGOCIACIÓN EFECTIVA (Monto)PARA COMPROMISOS Y ACUERDOS******************************* 																			
			--------------------------SE OBTIENE IIMPORTE RECUPERADO Y MONTO VENCIDO DE COMPROMISOS-------------------------
			--- MACF: Agrego que filtre por origen en compac_his, pq en compac_bit_realiza solo se cuentan a los q se les ofrece convenio en Sucursal
			--SELECT com.sucursal AS sucursal,CASE WHEN SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) <> 0 THEN  ROUND(NVL(SUM(NVL(com.imp_pagado,0.00))/ SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) * 100,0.00),2) ELSE 0 END AS NegEfecMonCom,0.00 AS NegEfecMonAcue
			IF pProducto = '6001' THEN 
				SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS NegEfecMonCom, 0.00 AS NegEfecMonAcue 
				FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para compromisos
					bdicred:"informix".sd_maesdoshist mae			 
				WHERE mae.empresa = '001'
					AND com.numcuenta = mae.num_credito
					AND com.tipo_compac = "1"
					AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
					AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
					AND com.fecha_insert <> com.fecha_compac
					AND com.plazo <> 1
					AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = com.numcuenta)			
				GROUP BY com.sucursal
				ORDER BY com.sucursal
				INTO TEMP tempcomacue WITH NO LOG;
			ELSE 
			
				SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS NegEfecMonCom, 0.00 AS NegEfecMonAcue 
				FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para compromisos
					 bdicred:"informix".sd_maesdoshistcrd mae,
					 bdicred:"informix".sd_maecredanexocrd anexo					
				WHERE mae.empresa = '001'
					AND com.numcuenta = mae.num_credito
					AND anexo.num_credito=com.numcuenta AND anexo.dia_corte=pDiaCorte 
					AND com.tipo_compac = "1"
					AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
					AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
					AND com.fecha_insert <> com.fecha_compac
					AND com.plazo <> 1
					AND com.numcuenta =  (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = com.numcuenta)			
				GROUP BY com.sucursal
				ORDER BY com.sucursal
				INTO TEMP tempcomacue WITH NO LOG;
			END IF;
        
			----OBTENER PARA CADA GRUPO DE CREDITOS DE CADA SUCURSAL CONTENIDO EN LA TABLA DE cb_compac_his
			IF pProducto = '6001' THEN 
				SET LOCK MODE TO WAIT 3;
				
				DROP TABLE IF EXISTS tmp_sd_movhis;
				DROP TABLE IF EXISTS tmp_sd_movhis_cuenta;
				
				SELECT com.sucursal, com.numcuenta
						FROM bdicobranza:"informix".cb_compac_his com
						WHERE com.tipo_compac = "1" 							
							AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
							AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
							AND com.fecha_insert <> com.fecha_compac
							AND com.plazo <> 1
							AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = com.numcuenta)
				INTO TEMP tmp_sd_movhis_cuenta WITH NO LOG;		
					

				SELECT com.sucursal, {+INDEX(bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0) suma 
				FROM bdicred:"informix".sd_movhis mov LEFT JOIN tmp_sd_movhis_cuenta com ON  mov.num_credito = com.numcuenta
				WHERE mov.empresa = '001' 
					and mov.codigo_fun in (select cod_fun from sd_conceptospagomanual) and codigo_ref = 1  
					and mov.fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig 
					and reversado = 'N'		
				GROUP BY com.sucursal			
				INTO TEMP tmp_sd_movhis WITH NO LOG;		
					
				/*UPDATE tempcomacue a SET 
				a.NegEfecMonCom = (SELECT  ROUND(b.suma / a.NegEfecMonCom* 100,2) FROM tmp_sd_movhis b WHERE b.sucursal=a.sucursal)
				WHERE a.NegEfecMonCom > 0 AND a.sucursal IN (SELECT sucursal from tmp_sd_movhis where suma > 0);*/
				
				MERGE INTO  tempcomacue a
				USING tmp_sd_movhis b ON a.sucursal=b.sucursal AND a.NegEfecMonCom>0 AND b.suma > 0
				WHEN MATCHED THEN
				UPDATE SET a.NegEfecMonCom=ROUND(b.suma / a.NegEfecMonCom* 100,2);
						
					
			ELSE 
					
				SET LOCK MODE TO WAIT 3;
				DROP TABLE IF EXISTS tmp_sd_movhis;
				DROP TABLE IF EXISTS tmp_sd_movhis_cuenta;
			
				SELECT com.sucursal, com.numcuenta
						FROM bdicobranza:"informix".cb_compac_his com INNER JOIN bdicred:"informix".sd_maecredanexocrd anexo ON anexo.num_credito=com.numcuenta AND anexo.dia_corte=pDiaCorte
						WHERE com.tipo_compac = "1" 							
							AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
							AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
							AND com.fecha_insert <> com.fecha_compac
							AND com.plazo <> 1
							AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = com.numcuenta)
				INTO TEMP tmp_sd_movhis_cuenta WITH NO LOG;		
				

				SELECT com.sucursal, {+INDEX(bdicred:"informix".sd_movhiscrd inx_movhis)} NVL(SUM(monto),0) suma 
				FROM bdicred:"informix".sd_movhiscrd mov LEFT JOIN tmp_sd_movhis_cuenta com ON  mov.num_credito = com.numcuenta
				WHERE mov.empresa = '001' 
					and mov.codigo_fun in (select cod_fun from sd_conceptospagomanualcrd where num_producto=pProducto) and codigo_ref = 1
					and mov.fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig 
					and reversado = 'N'		
				GROUP BY com.sucursal			
				INTO TEMP tmp_sd_movhis WITH NO LOG;		
					
				/*UPDATE tempcomacue a SET 
				a.NegEfecMonCom = (SELECT  ROUND(b.suma / a.NegEfecMonCom* 100,2) FROM tmp_sd_movhis b WHERE b.sucursal=a.sucursal)
				WHERE a.NegEfecMonCom > 0 AND a.sucursal IN (SELECT sucursal FROM tmp_sd_movhis b WHERE b.sucursal=a.sucursal AND suma > 0);*/
			
				MERGE INTO  tempcomacue a
				USING tmp_sd_movhis b ON a.sucursal=b.sucursal AND a.NegEfecMonCom>0 AND b.suma > 0
				WHEN MATCHED THEN
				UPDATE SET a.NegEfecMonCom=ROUND(b.suma / a.NegEfecMonCom* 100,2);
					
			END IF;
        
			-----------------CAMBIO EN QUERY DE ARRIBA QUEDA ASI
			IF pProducto = '6001' THEN 
				SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS MonAcue 
				FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para Acuerdos
					bdicred:"informix".sd_maesdoshist mae			 
				WHERE com.tipo_compac = "2" 					
					AND com.numcuenta = mae.num_credito
					AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
					AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
					AND com.fecha_insert <> com.fecha_compac
					AND com.plazo <> 1
					AND com.numcuenta =  (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = com.numcuenta)				
				GROUP BY com.sucursal
				ORDER BY com.sucursal
				INTO TEMP tempcomacue2 WITH NO LOG;
			ELSE 
			
				SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS MonAcue 
				FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para Acuerdos
					 bdicred:"informix".sd_maesdoshistcrd mae,
					 bdicred:"informix".sd_maecredanexocrd anexo					
				WHERE com.tipo_compac = "2" 					
					AND com.numcuenta = mae.num_credito
					AND anexo.num_credito=com.numcuenta AND anexo.dia_corte=pDiaCorte
					AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
					AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
					AND com.fecha_insert <> com.fecha_compac
					AND com.plazo <> 1
					AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = com.numcuenta)		
				GROUP BY com.sucursal
				ORDER BY com.sucursal
				INTO TEMP tempcomacue2 WITH NO LOG;
			END IF;
        
			---se barre tempcomacue2 por Sucursal para sacar los pagos
			IF pProducto = '6001' THEN 
					
						DROP TABLE IF EXISTS temp_sd_movhis;
						DROP TABLE IF EXISTS tmp_sd_movhis_cuenta;
				
						SELECT com.sucursal, com.numcuenta
								FROM bdicobranza:"informix".cb_compac_his com
								WHERE com.tipo_compac = "2" 							
									AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
									AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
									AND com.fecha_insert <> com.fecha_compac
									AND com.plazo <> 1
									AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecred WHERE num_producto = pProducto AND num_credito = com.numcuenta)
						INTO TEMP tmp_sd_movhis_cuenta WITH NO LOG;		
				
						SELECT  com.sucursal,  {+INDEX(bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0)  suma
						FROM bdicred:"informix".sd_movhis mov LEFT JOIN tmp_sd_movhis_cuenta com ON  mov.num_credito = com.numcuenta
						WHERE mov.empresa = '001' 
							and mov.codigo_fun in (select cod_fun from sd_conceptospagomanual) and codigo_ref = 1 
							and mov.fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig and reversado = 'N'
						GROUP BY  com.sucursal		
						INTO  TEMP temp_sd_movhis;
						
						/*UPDATE tempcomacue2 a SET 
						a.MonAcue=(select  ROUND(b.suma/a.MonAcue * 100,2) from temp_sd_movhis b where a.sucursal=b.sucursal)
						WHERE a.MonAcue > 0
						AND a.sucursal IN (SELECT sucursal from temp_sd_movhis where suma > 0.00);*/
						
						MERGE INTO  tempcomacue2 a
						USING temp_sd_movhis b ON a.sucursal=b.sucursal AND a.MonAcue>0 AND b.suma > 0
						WHEN MATCHED THEN
						UPDATE SET a.MonAcue=ROUND(b.suma/a.MonAcue * 100,2);
			
			ELSE 
					SET LOCK MODE TO WAIT 3;
					
					    DROP TABLE IF EXISTS temp_sd_movhis;
						DROP TABLE IF EXISTS tmp_sd_movhis_cuenta;
				
						SELECT com.sucursal, com.numcuenta
								FROM bdicobranza:"informix".cb_compac_his com INNER JOIN bdicred:"informix".sd_maecredanexocrd anexo ON anexo.num_credito=com.numcuenta AND anexo.dia_corte=pDiaCorte
								WHERE com.tipo_compac = "2" 							
									AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
									AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
									AND com.fecha_insert <> com.fecha_compac
									AND com.plazo <> 1
									AND com.numcuenta = (SELECT num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_producto = pProducto AND num_credito = com.numcuenta)
						INTO TEMP tmp_sd_movhis_cuenta WITH NO LOG;		
				
						SELECT  com.sucursal,  {+INDEX(bdicred:"informix".sd_movhiscrd inx_movhis)} NVL(SUM(monto),0)  suma
						FROM bdicred:"informix".sd_movhiscrd mov LEFT JOIN tmp_sd_movhis_cuenta com ON  mov.num_credito = com.numcuenta
						WHERE mov.empresa = '001' 
							and mov.codigo_fun in (select cod_fun from sd_conceptospagomanualcrd where num_producto=pProducto) and codigo_ref = 1
							and mov.fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig and reversado = 'N'
						GROUP BY  com.sucursal		
						INTO  TEMP temp_sd_movhis;
												
						MERGE INTO  tempcomacue2 a
						USING temp_sd_movhis b ON a.sucursal=b.sucursal AND a.MonAcue>0 AND b.suma > 0
						WHEN MATCHED THEN
						UPDATE SET a.MonAcue=ROUND(b.suma/a.MonAcue * 100,2);
						
			END IF;
		END IF;
        
		IF pOrigen = 3 THEN
			IF pTipoEjecucion = 1  THEN
				IF pRegistros = 0 THEN
								
					INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp,sucursal,num_rdos_comp,neg_efecvol_comp,imp_neg_comp,imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue,neg_efecmonto_acue,porc_cump_acue,num_ctes_con_vdo,num_convenios,porc_ctes_conv,pesos_convenios,pesos_pago,porc_rec_conv, nom_division,nom_region)
					SELECT DAY(fecha_acuecomp)||'-'||MONTH(fecha_acuecomp)||'-'||YEAR(fecha_acuecomp), sucursal, NVL(num_rdos_comp,0), 0, NVL(imp_neg_comp,0), NVL(imp_rec_comp,0), 0, NVL(porc_cump_comp,0), NVL(num_rdos_acue,0), 0, NVL(imp_neg_acue,0), NVL(imp_rec_acue,0), 0, NVL(porc_cump_acue,0), 0, NVL(num_rdos_comp,0)+ NVL(num_rdos_acue,0), 0, NVL(imp_neg_comp,0)+NVL(imp_neg_acue,0), NVL(imp_rec_comp,0)+NVL(imp_rec_acue,0),
									((( NVL(imp_rec_comp ,0)+ NVL(imp_rec_acue,0)) / ( NVL(imp_neg_comp,0) + NVL(imp_neg_acue,0))) * 100) ,'', ''
					FROM bdicred:"informix".sd_consulta_acue_comp_2
					WHERE usuario   = pUsuario
						AND id_sesion = iNumSesion
					ORDER BY fecha_acuecomp,sucursal;
			
					LET iContador = (SELECT COUNT(*) FROM bdicred:tme_encabezadosexcel); 
					
					
				END IF;
				SET ISOLATION TO DIRTY READ;
				
				LET pRegistros = pRegistros + 2;
								
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion nom_division, nom_region, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp, neg_efecmonto_comp, porc_cump_comp, num_rdos_acue, 
							neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv, 
							MDY(MONTH(to_date(fecha_acuecomp, '%d-%m-%Y')), DAY(to_date(fecha_acuecomp, '%d-%m-%Y')), YEAR(to_date(fecha_acuecomp, '%d-%m-%Y')))
						INTO vcNomDivision, cNomRegion,cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp, dNegEfectMontComp, dPorc_Cump_Comp, iNum_Rdos_Acue,
							dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp
						FROM bdicred:tme_encabezadosexcel
					
					RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
				
					LET iContador = iContador + 1; 
					
				END FOREACH;
			
				LET pRegistros = pRegistros - 2;
			
				IF iContador = 0 THEN
					IF pRegistros = 0 THEN
						LET cCodRet = '000002';
					ELIF pRegistros > 0 THEN
						LET cCodRet = '001001';
					END IF;
				
					RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
		END IF;
						
		END IF
        
			
		ELSE  
		
			IF pRegistros = 0 THEN
				IF pTipoEjecucion = 1  THEN					
					--**************SE OBTINENE LAS 4 COLUMNAS DE VOLUMEN Y MONTO EN LA TABLA FINAL DE TRABAJO************
			
					INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp,sucursal,num_rdos_comp,neg_efecvol_comp,imp_neg_comp,imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue,neg_efecmonto_acue,porc_cump_acue,num_ctes_con_vdo,num_convenios,porc_ctes_conv,pesos_convenios,pesos_pago,porc_rec_conv,nom_division,nom_region)
					SELECT  DAY(consul.fecha_acuecomp)||'-'||MONTH(consul.fecha_acuecomp)||'-'||YEAR(consul.fecha_acuecomp) fecha_acuecomp, consul.sucursal,NVL(consul.num_rdos_comp,0),
								NVL(t3.neg_com_por_suc,0), NVL(consul.imp_neg_comp,0), NVL(consul.imp_rec_comp,0), NVL(t1.NegEfecMonAcue,0),NVL(consul.porc_cump_comp,0), NVL(consul.num_rdos_acue,0),
								NVL(t3.neg_acue_por_suc,0),NVL(consul.imp_neg_acue,0), NVL(consul.imp_rec_acue,0),NVL(t2.MonAcue,0),NVL(consul.porc_cump_acue,0),
								NVL(t3.totnumcte,0) num_ctes_con_vdo,
								(NVL(consul.num_rdos_comp,0) + NVL(consul.num_rdos_acue,0)) num_convenios,
								ROUND( ((  NVL(consul.num_rdos_comp,0) + NVL(consul.num_rdos_acue,0)) / t3.totnumcte),2) porc_ctes_conv,
								( NVL(consul.imp_neg_comp,0) + NVL(consul.imp_neg_acue,0)) pesos_convenios,
								( NVL(consul.imp_rec_comp,0)+  NVL(consul.imp_rec_acue,0)) pesos_pago,
								ROUND(((( NVL(consul.imp_rec_comp,0) + NVL(consul.imp_rec_acue,0)) / ( NVL(consul.imp_neg_comp,0) + NVL(consul.imp_neg_acue,0))) * 100),2) porc_rec_conv,
								consul.nom_division, consul.nom_region
						FROM bdicred:"informix".sd_consulta_acue_comp consul
							LEFT OUTER JOIN tempcom4 t3 ON(consul.sucursal = t3.sucursal)
							LEFT OUTER JOIN	tempcomacue t1 ON(consul.sucursal = t1.sucursal)
							LEFT OUTER JOIN	tempcomacue2 t2 ON(consul.sucursal = t2.sucursal)								
						WHERE consul.usuario   = pUsuario
							AND consul.id_sesion = iNumSesion
						ORDER BY consul.fecha_acuecomp,consul.sucursal;
						
						LET iContador=(SELECT COUNT(*) FROM bdicred:tme_encabezadosexcel);
						
				
			  END IF;
			  
			END IF;
			
			-- BARRE LA TABLA DE TRABAJO PARA OBTENER LOS RESULTADOS
		IF pRegistros = 0 THEN 
			SET ISOLATION TO DIRTY READ;
			LET pRegistros = pRegistros + 2;
				
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion nom_division, nom_region, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp, neg_efecmonto_comp, porc_cump_comp, num_rdos_acue, 
						neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv, 
						MDY(MONTH(to_date(fecha_acuecomp, '%d-%m-%Y')), DAY(to_date(fecha_acuecomp, '%d-%m-%Y')), YEAR(to_date(fecha_acuecomp, '%d-%m-%Y')))
					INTO vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp, dNegEfectMontComp, dPorc_Cump_Comp, iNum_Rdos_Acue,
						dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp
					FROM bdicred:tme_encabezadosexcel
					
				RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
				
				LET iContador = iContador + 1; 
							
			END FOREACH;
			
			

			--LET pRegistros = pRegistros - 2;
			
			IF iContador = 0 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '000002';
				ELIF pRegistros > 0 THEN
					LET cCodRet = '001001';
				END IF;
				
				RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
						NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)),'' WITH RESUME;	
			END IF;
	END IF;		

		

		END IF;
		
	END IF;
        
		LET iNRows = dbinfo("sqlca.sqlerrd2");
		
		IF iNRows = 0 THEN
			LET cCodRet = "000002";
			LET cMensajeRet = "NO EXISTEN DATOS PARA ESTA CONSULTA";
		
			DROP TABLE IF EXISTS bdicred:"informix".tempcomacue;	
			DROP TABLE IF EXISTS bdicred:"informix".tempcomacue2;		
			DROP TABLE IF EXISTS bdicred:"informix".tempcom1;		
			DROP TABLE IF EXISTS bdicred:"informix".tempcom4;
			DROP TABLE IF EXISTS bdicred:"informix".bit_realiza_filtrada;
			DROP TABLE IF EXISTS bdicred:"informix".bit_realiza_filtrada2;
			
			DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdos;
			DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos2;
			DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos3; 	
			
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,0,0,0,0,0,MDY(1,1,1900),'';
        
		ELSE
		
			IF pOrigen = 3 THEN
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdos;
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos2;
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos3;
			ELSE	     
				DELETE FROM bdicred:"informix".sd_consulta_acue_comp  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
				DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
				--SE ELIMINAN TABLAS TEMPORALES.
				DROP TABLE IF EXISTS bdicred:"informix".tempcomacue;	
				DROP TABLE IF EXISTS bdicred:"informix".tempcomacue2;		
				DROP TABLE IF EXISTS bdicred:"informix".tempcom1;		
				DROP TABLE IF EXISTS bdicred:"informix".tempcom4;
				DROP TABLE IF EXISTS bdicred:"informix".bit_realiza_filtrada;
				DROP TABLE IF EXISTS bdicred:"informix".bit_realiza_filtrada2;
				DROP TABLE IF EXISTS bdicred:"informix".bit_realiza_filtrada3;
				           
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdos;
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos2;
				DROP TABLE IF EXISTS bdicred:"informix".tmeacuerdosaompromisos3; 	
			END IF;
		END IF;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento principal para la obtención de los datos de compromisos y convenios.', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20100827.1152',
'MODIFICACION: Se modifico para que muestre los datos ordenados por Fecha y Sucursal.Tambien se agrego la validacion',
' del tipo de consulta, REGION ,DIVISION O SUCURSAL, ya que por sucursal se mostraran agrupados por fecha, y region y division agrupada por sucursal', 
'AUTOR: Guadalupe Payan, Abigail Vasavilbazo Cañedo ',
'FECHA: Septiembre 2010',
'VERSION: 20101018.1117',
'MODIFICACION: Se modificó para que se pueda trabajar con el aplicativo en varias sesiones al mismo tiempo sin marcar ningun error',
'y se agrega la opcion para generar un archivo excel con la informacion de la consulta, y que solo regrese un cierto numero de registros de muestra',
'AUTOR: Héctor Manuel Bojórquez Ruelas,Jesús Manuel Aguilar Heredia',
'FECHA: Junio 2011',
'VERSION: 20110630.1010',
'MODIFICACION: Se modifica para que se aguarde la fecha a formato dd-mm-yyyy en la generacion del archivo',
'AUTOR: Jesús Manuel Aguilar Heredia',
'FECHA: Julio 2011',
'VERSION: 20110708.0949',
'DESCRIPCION MODIFICACION: Se modifico para calcular y retornar la Negociación Efectiva(volumen) y la Negociación Efectiva(monto) tanto para Compromisos',
'						   como para Acuerdos',
'FECHA MODIFICACION: 03 de Mayo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120503.1508',
'BD: bdicred',
'FECHA: 2012-07-26',
'MODIFICACION: Filtrar para que solamente tome el origen 2 (sucursal) en query principal. Autor:MACF',
'DESCRIPCION MODIFICACION: Se modifica para agregar nuevas coulmas tales como: ' ,
'numero clientes vencido, numero convenios, porcentaje clientes convenios, pesos convenios, pesos pago, porcentaje rec convenios',
'FECHA MODIFICACION: 27 de Agosto del 2012',
'AUTOR MODIFICACION: Mohamed Carreón',
'VERSION: 20120827.1248',
'BD: bdicred',
'FECHA: 2012-08-27',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica para la realizacion de la consulta por medio de producto, ademas de la creacion d las tablas temporales',
'FECHA: 17/05/2016',
'FECHA : 11/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica el nombre del sql que se genera internamente',
'FECHA : 30/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica la recuperacion de datos por bloque',
'FECHA: 05/10/2016',
'AUTOR: L. Montserrat León Amador',
'DESCRIPCIÓN MODIFICACIÓN: Se modifica spl para realizar el cambio de tablas al momento de hacer el filtrado por productos diferentes a tarjetas de credito,',
'Se cambian las tablas sd_maesdoshist por sd_maesdoshistcrd, y sd_movhis por sd_movhiscrd.',
'FECHA: 19/10/2016',
'AUTOR: L. Montserrat León Amador',
'DESCRIPCIÓN MODIFICACIÓN: Se realiza la separacion de tablas que consultan número total de registros de la tabla bdicobranza:cb_compac_his.',
'FECHA: 31/10/2016',
'AUTOR: Martha Salgado Mendoza',
'DESCRIPCIÓN MODIFICACIÓN: Se agrego consulta para campo codigo_fun, se agrega parametro de entrada pDiaCorte. Se agrega calculo de fechas para cFechCortInmAnt_2 y cFechCortMesSig_2 para otros productos',
'FECHA: 11/11/2016',
'AUTOR: Martha Salgado Mendoza',
'DESCRIPCIÓN MODIFICACIÓN: Se agrega cruce con tabla sd_maecredanexocrd por medio del numero de credito y dia de corte',
'FECHA: 17/11/2016',
'AUTOR: Martha Salgado Mendoza',
'DESCRIPCIÓN MODIFICACIÓN: Se modifica formato para el campo  porc_cump_acue(decimal(8,2)), Se agrega cruce de tabla cb_compac_bit_realiza',
'FECHA: 22/11/2016',
'AUTOR: Martha Salgado Mendoza',
'DESCRIPCIÓN MODIFICACIÓN: Se agrega crece a  tabla cb_compac_bit_realiza con sd_maecredanexocrd';

CREATE PROCEDURE "informix".sp_cre_consultarcompromisosacuerdoscat(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumDivision  INTEGER, pNumRegion  INTEGER, pNumSucursal CHAR(4),  pFechaInicio CHAR(10), pFechaFin CHAR(10),pTipoEjecucion SMALLINT, pOrigen SMALLINT, pProducto CHAR(4),pDiaCorte SMALLINT,pRegistros INTEGER, pRecuperacion   INTEGER)
        RETURNING CHAR(5)        AS cod_ret,
		CHAR(80)       AS descripcion,
		CHAR(100)      AS division,
		CHAR(30)       AS region,
		CHAR(4)        AS sucursal,
		INTEGER        AS num_rdos_comp,
		DECIMAL(18,2)  AS neg_efec_vol_comp,
		DECIMAL(18,2)  AS imp_neg_comp,
		DECIMAL(18,2)  AS imp_rec_comp,
		DECIMAL(18,2)  AS neg_efec_mont_comp,
		DECIMAL(8,2)   AS porc_cump_comp,
		INTEGER        AS num_rdos_acue,
		DECIMAL(18,2)  AS neg_efec_vol_acrd,
		DECIMAL(18,2)  AS imp_neg_acue,
		DECIMAL(18,2)  AS imp_rec_acue,
		DECIMAL(18,2)  AS neg_efec_mont_acrd,
		DECIMAL(8,2)   AS porc_cump_acue,
		INTEGER                AS num_ctes_con_vdo,
		INTEGER        AS num_convenios,
		DECIMAL(8,2)   AS porc_ctes_conv,
		DECIMAL(18,2)  AS pesos_convenios,
		DECIMAL(18,2)  AS pesos_pago,
		DECIMAL(8,2)   AS porc_rec_conv,
		DATE           AS fecha_acue_comp,
		CHAR (80) 	   AS ruta;
		      
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6); 
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;        
        DEFINE cEmpresa CHAR(3);        
        DEFINE cDescripcion CHAR(80);
        DEFINE cMensajeRet CHAR(85);
        DEFINE vcNomDivision VARCHAR(100);
        DEFINE cNomRegion CHAR(30);
        DEFINE cSucursal CHAR(4);
        DEFINE iNum_Rdos_Comp INTEGER;
        DEFINE dImp_Neg_Comp DECIMAL(18,2);
        DEFINE dImp_Rec_Comp DECIMAL(18,2);
        DEFINE dPorc_Cump_Comp DECIMAL(8,2);
        DEFINE iNum_Rdos_Acue INTEGER;
        DEFINE dImp_Neg_Acue DECIMAL(18,2);
        DEFINE dImp_Rec_Acue DECIMAL(18,2);
        DEFINE dPorc_Cump_Acue DECIMAL(8,2);
        DEFINE dtFechaAcueComp DATE;
        DEFINE iNumCtesVdo INTEGER;
        DEFINE iNumConvenios INTEGER;
        DEFINE dNegEfectVolComp DECIMAL(18,2);
        DEFINE dNegEfectMontComp DECIMAL(18,2);
        DEFINE dNegEfectVolAcue DECIMAL(18,2);
        DEFINE dNegEfectMontAcue DECIMAL(18,2);
        DEFINE dPorcCtesConv DECIMAL(8,2);
        DEFINE dPesosConvenios DECIMAL(18,2);
        DEFINE dPesosPago DECIMAL(18,2);
        DEFINE dPorcRecConv DECIMAL(8,2);
		DEFINE cRuta CHAR(80); 
        
        LET cCodRet = '00000';
        LET iCodRetSp = 0;
        LET iNoRegistros = 0;
        LET iSqlErr = 0;
        LET cCodRetSp = '000000';        
        LET cMensajeRet = "";
        LET cDescripcion = "";    
        LET cEmpresa = '001';
        LET vcNomDivision = "";
        LET cNomRegion = "";
        LET cSucursal = "";
        LET iNum_Rdos_Comp = 0;
        LET iNumCtesVdo = 0;
        LET iNumConvenios   = 0;
        LET dImp_Neg_Comp = 0.0;
        LET dImp_Rec_Comp = 0.0;
        LET dPorc_Cump_Comp = 0.0;
        LET iNum_Rdos_Acue = 0;
        LET dImp_Neg_Acue = 0.0;
        LET dImp_Rec_Acue = 0.0;
        LET dPorc_Cump_Acue = 0.0;
        LET dNegEfectVolComp = 0.00;
        LET dNegEfectMontComp = 0.00;
        LET dNegEfectVolAcue = 0.00;
        LET dNegEfectMontAcue = 0.00;
        LET dtFechaAcueComp = '';
        LET dPorcCtesConv = 0.0;
        LET dPesosConvenios = 0.0;
        LET dPesosPago = 0.0;
        LET dPorcRecConv = 0.0;
		LET cRuta = '';
        
        BEGIN
            ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;				
				
                RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
            END EXCEPTION;
			
			ON EXCEPTION IN (-268)
				LET cCodRet = '00284';
				
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;				
				
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END EXCEPTION;
			
			ON EXCEPTION IN (-214)
				LET cCodRet = '00114';
				
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;				
				
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END EXCEPTION;

			DELETE FROM bdicnweb:"informix".sw_cr_tipostatus WHERE usuario_inserta = pUsuario;
			
			INSERT INTO bdicnweb:"informix".sw_cr_tipostatus(id_status, desc_status, usuario_inserta, fecha)
			VALUES ('I', 'INICIA_PROCESO', pUsuario, CURRENT);
			 
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultarcompromisosacuerdoscat.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = ''  OR pNumDivision IS NULL OR pNumRegion IS NULL  OR pFechaInicio = '' OR pFechaFin = '' OR pTipoEjecucion NOT IN (1,2,3) OR pOrigen NOT IN (1,2,3) OR pProducto = '' OR pDiaCorte IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';

				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
			
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END IF;
			
			-- VALIDACION DE LA PAGINACION
			IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';

				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;

				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH									
				EXECUTE PROCEDURE bdicred:"informix".sp_consultarcompromisosacuerdos2(cEmpresa,pNumDivision,pNumRegion , pNumSucursal, pFechaInicio, pFechaFin,pUsuario, pTipoEjecucion, pOrigen,pProducto, pDiaCorte, pRegistros, pRecuperacion)
				INTO cCodRetSp, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta
										
				LET iCodRetSp = cCodRetSp::INTEGER;				
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_consultarcompromisosacuerdos2";
				ELIF iCodRetSp = 1  THEN
						LET cCodRet = '00003';
				ELIF iCodRetSp = 2  THEN
						LET cCodRet = '00017';
				ELIF iCodRetSp = 3  THEN
						LET cCodRet = '00017';
				ELIF iCodRetSp = 4  THEN
						LET cCodRet = '00773';
				END IF;
				
				IF iCodRetSp <> 0 THEN
					UPDATE bdicnweb:"informix".sw_cr_tipostatus
					SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
					WHERE usuario_inserta = pUsuario;
					
					RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
					
				ELIF iCodRetSp = 0 THEN 			
					UPDATE bdicnweb:"informix".sw_cr_tipostatus
					SET id_status = 'F', desc_status = 'FINALIZA_PROCESO'
					WHERE usuario_inserta = pUsuario;
				END IF;
					
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta WITH RESUME;               
				
			END FOREACH;

			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				UPDATE bdicnweb:"informix".sw_cr_tipostatus
				SET id_status = 'T', desc_status = 'PROCESO_TRUNCADO'
				WHERE usuario_inserta = pUsuario;
				RETURN cCodRet, cDescripcion, vcNomDivision, cNomRegion, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue, dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv, dtFechaAcueComp, cRuta;
			END IF;                         
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 25/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta de estadística, compromisos y acuerdos de calificacion conv cat cobranza cat',
'BD: bdicred',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 12/07/2016',
'DESCRIPCION: Se modifica la ruta para la descarga del archivo generado.',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 15/08/2016',
'DESCRIPCION: Se modifica procedimiento donde se inserta el status de proceso inici_proceso, proceso_truncado y finaliza_proceso para diferenciar los tiempos.',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 17/08/2016',
'DESCRIPCION: Se modifica procedimiento en lugar de insertar debe actualizar el registro para el status de proceso inici_proceso, proceso_truncado y finaliza_proceso para diferenciar los tiempos.',
'FECHA: 31/10/2016',
'AUTOR: Martha Salgado Mendoza',
'DESCRIPCIÓN MODIFICACIÓN: Se agrega parametro de entrada pDiaCorte.';

CREATE PROCEDURE "informix".sp_cre_consultarcompromisosacuerdoscat_totales(pUsuario CHAR(8),pIdFuncion CHAR(10),pNumDivision  INTEGER, pNumRegion  INTEGER, pNumSucursal CHAR(4), pFechaInicio CHAR(10),pFechaFin CHAR(10),pTipoEjecucion SMALLINT,pOrigen  SMALLINT,pProducto CHAR(4))
                RETURNING  CHAR(5) AS codret,
                INTEGER AS total;

	---DECLARACIONES
	DEFINE cCodRet CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iSqlErr = 0;

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN  cCodRet,iNoRegistros;
        END EXCEPTION;

		ON EXCEPTION IN (-268)
			LET cCodRet = '00284';
			RETURN  cCodRet,iNoRegistros;
		END EXCEPTION;

       --SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultarcompromisosacuerdoscat_totales.out';
       --TRACE ON;

        IF pUsuario = '' OR pIdFuncion = ''  OR pNumDivision IS NULL OR pNumRegion IS NULL  OR pFechaInicio = '' OR pFechaFin = '' OR pTipoEjecucion NOT IN (1) OR pOrigen NOT IN (1,2,3) OR pProducto = ''  THEN
            LET cCodRet = '00003';
            RETURN  cCodRet,iNoRegistros;
        END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet,iNoRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
			
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicred:tme_encabezadosexcel
		WHERE fecha_acuecomp NOT IN ('', 'FECHA');
		
		DELETE bdicnweb:"informix".sw_cr_tipostatus
		WHERE usuario_inserta = pUsuario;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;

		RETURN cCodRet,iNoRegistros;
    END;

END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 25/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: ADMINISTRACION DE CAMPAÑAS',
'DESCRIPCION: SPL que realiza la consulta de los total de estadística, compromisos y acuerdos de calificacion conv cat cobranza',
'BD: bdicred',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 12/07/2016',
'DESCRIPCION: Se modifica la ruta para la descarga del archivo generado.',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 15/08/2016',
'DESCRIPCION: Se modifica para disminuir el tiempo del proceso de totales.';

CREATE PROCEDURE "informix".sp_cre_genreporteindicadorconveniocat(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoReporte INTEGER, pFechaInicio DATE, pFechaFin DATE, pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		 CHAR(80) AS Nombre_archivo,
		 CHAR(80) AS ruta; 
		 
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNombreArchivo CHAR(80);
	DEFINE cMensajeRet CHAR(80);
	DEFINE cRuta CHAR(80);
	DEFINE bTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET cNombreArchivo = '';
	LET cMensajeRet = '';
	LET cRuta = '';
	LET bTransaccion = 'f';
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreArchivo,cRuta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bTransaccion = 't';
		END EXCEPTION WITH RESUME;
				
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreporteindicadorconveniocat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipoReporte IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pProducto ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo,cRuta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo,cRuta;
		END IF;
		
		BEGIN;
		IF bTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE "informix".sp_compac_genera_reporte_tmp2(cEmpresa,pTipoReporte,pFechaInicio,pFechaFin, pProducto)		
		INTO cCodRetSp, cMensajeRet, cNombreArchivo, cRuta;
		
		IF bTransaccion = 't' THEN
			BEGIN;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicred:sp_compac_genera_reporte_tmp2';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00773';
			ELIF cCodRetSp::INTEGER = 997 THEN  
				LET cCodRet = '00774';
			END IF;
			
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo,cRuta;
		END IF;
		
		RETURN cCodRet, cNombreArchivo,cRuta;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 12/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CONSULTA ESTADÍSTICA, COMPROMISOS Y ACUERDOS',
'DESCRIPCION:SPL para la generacion de archivos de los tipos de reportes de estadistica convenios sucursal',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_pagomin_sdovenc_sucursal(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(5)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;

---DECLARACIONES
DEFINE cCodRet          CHAR(5); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNombreArchivo     CHAR(80);
DEFINE cNombreArchivo2  CHAR(30);
DEFINE iNumArchivo                INTEGER;
DEFINE cTipoArchivo         CHAR(80);
DEFINE cConsulta                    CHAR(2200);
DEFINE cConsulta2                   CHAR(500);
DEFINE cConsulta3                   CHAR(500);
DEFINE cSql                                   CHAR(2500);
DEFINE cParam1                CHAR(20);
DEFINE cParam2                CHAR(20);
DEFINE cParam3                CHAR(20);
DEFINE cRuta                    CHAR(80);
DEFINE cTabla                   CHAR(1);
DEFINE cTabla_2         CHAR(1);
DEFINE cTabla_3         CHAR(1);
DEFINE dtFecha                DATE;
DEFINE dtFechaIni       DATE;
DEFINE dtFechaFin       DATE;
DEFINE vEmpresa         CHAR(3);
DEFINE vSucursal        CHAR(4); 
DEFINE vUsuario         CHAR(8);
DEFINE vNumPagosMinOk   INTEGER;
DEFINE vNumPagosMinNok  INTEGER;
DEFINE vNumPagosVencOk  INTEGER;
DEFINE vNumPagosVencNok INTEGER;
DEFINE dtFecha_ayer     DATE;

DEFINE vfecha_insert          DATE;
DEFINE vcant_a_recup_pm    INTEGER;
DEFINE vcant_recup_pm      INTEGER;
DEFINE vPct_PM_Recup       DECIMAL(10,2);  
DEFINE vcount_con_pagomin  INTEGER;
DEFINE vcount_sin_pagomin  INTEGER; 
DEFINE vPct_cumpl_PM       DECIMAL(10,2);
DEFINE vcant_a_recup_sv    INTEGER;     
DEFINE vcant_recup_sv      INTEGER;
DEFINE vPct_SV_Recup                     DECIMAL(10,2); 
DEFINE vcount_con_sv       INTEGER;
DEFINE vcount_sin_sv       INTEGER; 
DEFINE vPct_cumpl_SV       DECIMAL(10,2);
DEFINE d_cant_a_recup_pm   DECIMAL(14,2);  
DEFINE d_cant_recup_pm     DECIMAL(14,2);
DEFINE d_cant_a_recup_sv   DECIMAL(14,2);
DEFINE d_cant_recup_sv     DECIMAL(14,2);
DEFINE vPct_Cump_Recup_Cartera       DECIMAL(10,2);
DEFINE vPct_PM_Recup_total DECIMAL(10,2);                 
DEFINE vPct_SV_Recup_total DECIMAL(10,2);
DEFINE v_numero_producto   CHAR(4);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "00000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo                     = 0;
--LET cNombreArchivo              = "rep_pm_sdovenc_";
LET cNombreArchivo                = '';
LET cTipoArchivo          = "";
LET cConsulta                         = "";
LET cConsulta2                      = "";
LET cConsulta3                      = "";
LET cParam1                                   = "";
LET cParam2                                   = "";
LET cParam3                                   = "";
LET cRuta                                       = "";
LET cTabla                                    = "N";
LET cTabla_2                          = "N";
LET cTabla_3                          = "N";
LET dtFecha                                   = DATE(1);
LET vEmpresa            = '';
LET vSucursal           = ''; 
LET vUsuario            = '';
LET vNumPagosMinOk      = 0;
LET vNumPagosMinNok     = 0;
LET vNumPagosVencOk     = 0;
LET vNumPagosVencNok    = 0;
LET dtFechaIni          = DATE(1);
LET dtFechaFin          = DATE(1);
LET cNombreArchivo2     = 'reporte';
         
LET vfecha_insert        = DATE(1);         
LET vcant_a_recup_pm     = 0;
LET vcant_recup_pm       = 0;
LET vPct_PM_Recup        = 0;
LET vcount_con_pagomin   = 0;
LET vcount_sin_pagomin   = 0;
LET vPct_cumpl_PM        = 0;
LET vcant_a_recup_sv     = 0;
LET vcant_recup_sv       = 0;
LET vPct_SV_Recup                         = 0;
LET vcount_con_sv        = 0; 
LET vcount_sin_sv        = 0;
LET vPct_cumpl_SV        = 0;
LET d_cant_a_recup_pm    = 0;
LET d_cant_recup_pm      = 0;
LET d_cant_a_recup_sv    = 0;
LET d_cant_recup_sv      = 0;
LET vPct_Cump_Recup_Cartera = 0;
LET vPct_PM_Recup_total  = 0;                 
LET vPct_SV_Recup_total  = 0;
LET dtFecha_ayer = DATE(1);
LET v_numero_producto='';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet= iSqlErr;
        LET cMensajeRet = cErrorInfo;
        
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

  --SET DEBUG FILE TO '/informix/macf/sp_pagomin_sdovenc_sucursal.trc';
  --TRACE ON;

  LET dtFechaIni  = pFechaIni - 1 units day;
  LET dtFechaFin  = pFechaFin - 1 units day;


    IF NVL(pEmpresa,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
        LET cCodRet= "00001";
        LET cMensajeRet = "Parametro no valido para realizar la consulta";
        RETURN cCodRet, cMensajeRet;
    END IF;

    --se obtiene la ruta donde se almacenara el archivo generado.
    SELECT  TRIM(valor_alfabetico) 
        INTO cRuta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE tipo_campania = 11  
        AND  grupo_parametro = 'RUTAS'
        AND num_parametro =1;
        
        
    IF NVL(cRuta,"") = "" THEN
        LET cCodRet= "00002";
        LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
        RETURN cCodRet, cMensajeRet;
    END IF;     

                SELECT fecha_hoy, fecha_ant   
                INTO dtFecha, dtFecha_ayer 
                FROM bdicred:"informix".sd_fechas
                WHERE empresa=pEmpresa;

        --LET cNombreArchivo= TRIM(cNombreArchivo2)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);
    
   truncate "informix".sd_pagos_temp;
   truncate "informix".sd_rep_pagos_pmsv_det;

   BEGIN;
      DELETE "informix".sd_rep_pagos_pmsv WHERE fecha_insert between dtFechaIni and dtFechaFin;
   COMMIT;
   UPDATE statistics medium FOR TABLE "informix".sd_rep_pagos_pmsv;
   
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
    
          FOREACH WITH HOLD
         
        SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, 
               case when a.pago_min > 0 then 1 else 0 end as num_pagos_min_ok,
               case when a.pago_min > 0 then case when pago_realizado >= pago_min then 1 else 0 end else 0 end num_pagos_min_nok,

               case when a.saldo_vencido > 0 then 1 else 0 end as num_pagos_venc_ok, 
               case when a.saldo_vencido > 0 then ( case when a.pago_realizado >= a.saldo_vencido then 1 else  0 end) else 0 end num_pagos_venc_nok, NVL(crd.num_producto,cr.num_producto) num_producto
        INTO vEmpresa, vSucursal, vfecha_insert, vUsuario, vNumPagosMinOk, vNumPagosMinNok, vNumPagosVencOk, vNumPagosVencNok ,v_numero_producto
        from bdicobranza:cb_evaluacion_objetiva_his a
		LEFT OUTER JOIN bdicred:"informix".sd_maecred cr  ON cr.empresa=a.empresa AND  cr.num_credito=a.num_credito 
		LEFT OUTER JOIN bdicred:"informix".sd_maecredcrd crd ON crd.empresa=a.empresa AND  crd.num_credito=a.num_credito
        WHERE a.fecha_insert >= dtFechaIni and fecha_insert <= dtFechaFin
          AND a.reversado = 'N'
          AND a.pago_min > 0
       
        
        begin;
          INSERT INTO "informix".sd_pagos_temp(empresa, sucursal, fecha, usuario, num_pagos_min_ok, num_pagos_min_nok, num_pagos_venc_ok, num_pagos_venc_nok, num_producto)
          VALUES(vEmpresa, vSucursal, vfecha_insert, vUsuario, vNumPagosMinOk, vNumPagosMinNok,vNumPagosVencOk,vNumPagosVencNok,v_numero_producto);
        commit;
      
        LET vSucursal = ''; LET vfecha_insert = '01/01/1900'; LET vUsuario = ''; LET vNumPagosMinOk = 0; LET vNumPagosMinNok = 0; LET vNumPagosVencOk = 0; LET vNumPagosVencNok = 0;LET v_numero_producto='';
      
    END FOREACH;    
    
    
    FOREACH with hold
        SELECT a.sucursal, a.fecha_insert, a.pago_min,
               case when pago_min > 0 then pago_realizado else 0 end,
               pct_cump_pm,
               saldo_vencido,
               case when saldo_vencido > 0 then pago_realizado else 0 end,
               pct_cump_sv, NVL(crd.num_producto,cr.num_producto) num_producto
          INTO vSucursal, vfecha_insert, d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup, d_cant_a_recup_sv,  d_cant_recup_sv, vPct_SV_Recup,v_numero_producto
          FROM bdicobranza:cb_evaluacion_objetiva_his a
		  LEFT OUTER JOIN bdicred:"informix".sd_maecred cr  ON cr.empresa=a.empresa AND  cr.num_credito=a.num_credito 
		  LEFT OUTER JOIN bdicred:"informix".sd_maecredcrd crd ON crd.empresa=a.empresa AND  crd.num_credito=a.num_credito
         WHERE fecha_insert >= dtFechaIni 
           AND fecha_insert <= dtFechaFin
           AND reversado = 'N'
           AND pago_min > 0
           
           begin;
             INSERT INTO "informix".sd_rep_pagos_pmsv_det(sucursal, fecha_insert, cant_a_recup_pm, cant_recup_pm, Pct_PM_Recup, cant_a_recup_sv, cant_recup_sv, Pct_SV_Recup, num_producto )
              VALUES(vSucursal, vfecha_insert, d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup, d_cant_a_recup_sv, d_cant_recup_sv, vPct_SV_Recup, v_numero_producto);
           commit;
           
    END FOREACH;
     
    FOREACH with hold
         SELECT sucursal, fecha_insert,num_producto, round(sum(cant_a_recup_pm),2), round(sum(cant_recup_pm),2), round(sum(Pct_PM_Recup),2),
                round(sum(cant_a_recup_sv),2), round(sum(cant_recup_sv),2), round(sum(Pct_SV_Recup),2)
           INTO vSucursal, vfecha_insert,v_numero_producto,d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup, d_cant_a_recup_sv, d_cant_recup_sv, vPct_SV_Recup
           FROM "informix".sd_rep_pagos_pmsv_det
           WHERE fecha_insert >= dtFechaIni 
             AND fecha_insert <= dtFechaFin
           GROUP BY 1,2,3
           
         SELECT sum(num_pagos_min_ok), sum(num_pagos_min_nok),
                case when (round( (sum(num_pagos_min_nok) / sum(num_pagos_min_ok)* 100),2)) > 100 then 100 else (round( (sum(num_pagos_min_nok) /sum(num_pagos_min_ok)* 100),2)) end Pct_cumpl_PM,

                sum(num_pagos_venc_ok), sum(num_pagos_venc_nok),
                --case when (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) > 100 then 100 else (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) end Pct_cumpl_SV
                case when sum(num_pagos_venc_ok) = 0 then 0 else 
                                                                  case when (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) > 100 then 100 
                                                                       else (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) 
                                                                  end 
                end Pct_cumpl_SV
           INTO vcount_con_pagomin, vcount_sin_pagomin, vPct_cumpl_PM, vcount_con_sv, vcount_sin_sv, vPct_cumpl_SV
           FROM "informix".sd_pagos_temp
          WHERE empresa  = '001'
            AND sucursal = vSucursal
            AND fecha    = vfecha_insert; 
           
            
            IF vPct_PM_Recup > 0 THEN
              LET vPct_PM_Recup_total = round(vPct_PM_Recup/vcount_con_pagomin,2);
            ELSE
              LET vPct_PM_Recup_total = 0;
            END IF;
                           
            IF vPct_SV_Recup > 0 THEN
              LET vPct_SV_Recup_total  = round(vPct_SV_Recup/vcount_con_sv,2);
            ELSE
              LET vPct_SV_Recup_total = 0;
            END IF;
            
            IF d_cant_a_recup_sv > 0 THEN
               LET vPct_Cump_Recup_Cartera = round((vPct_PM_Recup_total + vPct_SV_Recup_total + vPct_cumpl_PM + vPct_cumpl_SV)/4,2);
            ELSE
               LET vPct_Cump_Recup_Cartera = round((vPct_PM_Recup_total +  vPct_cumpl_PM)/2,2);    
            END IF;
            
                 
           BEGIN;
              INSERT INTO "informix".sd_rep_pagos_pmsv(sucursal, fecha_insert, cant_a_recup_pm, cant_recup_pm, Pct_PM_Recup, count_con_pagomin, count_sin_pagomin,
                                          Pct_cumpl_PM, cant_a_recup_sv, cant_recup_sv, Pct_SV_Recup, count_con_sv, count_sin_sv, Pct_cumpl_SV, Pct_cump_recup_cartera, num_producto)
              VALUES(vSucursal, vfecha_insert, d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup_total, vcount_con_pagomin, vcount_sin_pagomin, vPct_cumpl_PM, 
                     d_cant_a_recup_sv, d_cant_recup_sv, vPct_SV_Recup_total, vcount_con_sv, vcount_sin_sv, vPct_cumpl_SV, vPct_Cump_Recup_Cartera,v_numero_producto);
           COMMIT; 
          
          LET d_cant_a_recup_pm = 0; LET d_cant_recup_pm = 0; LET vPct_PM_Recup = 0; LET d_cant_a_recup_sv = 0; LET d_cant_recup_sv = 0; LET vPct_SV_Recup = 0;
          LET vcount_con_pagomin = 0; LET vcount_sin_pagomin = 0; LET vPct_cumpl_PM = 0; LET vcount_con_sv = 0; LET vcount_sin_sv = 0; LET vPct_cumpl_SV = 0;
          LET vPct_Cump_Recup_Cartera = 0;  LET vPct_PM_Recup_total = 0;   LET vPct_SV_Recup_total = 0;LET v_numero_producto='';
          
    END FOREACH;
                 
                
                RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 27/04/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAT - CALIFICACION DE CONVENIOS CAT COBRANZA',
'DESCRIPCION:SE agrego la modificacion para q las consultas obtengan el num_ptoducto de la tablas sd_maecred y sd_maecredcrd que ambientan los reportes de convenios soc. ', 
'BD: bdicred';

CREATE PROCEDURE "informix".sp_rep_convenios_sif2_tmp(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsr CHAR(8), pProducto CHAR(4))
RETURNING CHAR(6)  AS codigo_retorno,
        CHAR(80) AS mensaje_retorno,
		CHAR(80) AS Nombre_archivo,
		CHAR(80) AS ruta;
		
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE iNumArchivo		  INTEGER;
DEFINE cTipoArchivo	    CHAR(80);
DEFINE cConsulta3		    CHAR(300);
DEFINE cSql		 		      CHAR(3000);
DEFINE cRuta		        CHAR(80);
DEFINE cTabla		        CHAR(1);
DEFINE dtFecha		      DATE;
DEFINE cFechaIni        CHAR(10);
DEFINE cFechaFin        CHAR(10);
DEFINE cSucursal        CHAR(4);
DEFINE iNumctes_vencido INTEGER;
DEFINE cNumcte          CHAR(20);
DEFINE dFecha_Reg       DATE;
DEFINE iRegistros       INTEGER;
DEFINE dFecha_ini       DATE;
DEFINE dFecha_fin       DATE;
DEFINE iCantidad        INTEGER;
DEFINE vPlaza       CHAR(40);
DEFINE vCiudad      CHAR(60);
DEFINE vSucursal    CHAR(4);
DEFINE vOrigen      CHAR(8);
DEFINE vTipoCompac  CHAR(1);
DEFINE vPlazo       CHAR(2);
DEFINE vImporte     DECIMAL(14,2);
DEFINE vImpPagado   DECIMAL(14,2);
DEFINE vCumplido    CHAR(11);
DEFINE vFechaCompac DATE;
DEFINE vFechaIns    DATE;
DEFINE dFecha_ini_2     DATE;
DEFINE dFecha_fin_2     DATE;
DEFINE dFecha_temp      DATE;
DEFINE dFecha_temp2     DATE; 
DEFINE vNumcuenta       CHAR(20); 
DEFINE cPagoProgramado  CHAR(1);
DEFINE iNumSesion       INTEGER;
DEFINE cArmaTabla       char(500);
DEFINE cValor           char(1);
DEFINE vFechaMov        DATE;
DEFINE cSuc             CHAR(10);
DEFINE v_count_emp      CHAR(10);
DEFINE cImporte         CHAR(20);
DEFINE cImpPagado       CHAR(20);
DEFINE cFechaCompac     CHAR(20);
DEFINE cFechaIns        CHAR(20);
DEFINE cPagoProgramado_2 CHAR(45);
DEFINE cUsuario         CHAR(8);
DEFINE vNumCuenta_2     LIKE sd_convs_detalle.numcuenta;
DEFINE vFecha_venc      DATE;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			    = 0;
LET cNombreArchivo		  = "reporte_convenios_";
LET cTipoArchivo     	  = "";
LET cConsulta3			    = "";
LET cRuta				        = "";
LET cTabla				      = "N";
LET dtFecha				      = DATE(1);
LET cFechaIni           = ''; 
LET cFechaFin           = '';
LET cSucursal           = '';
LET iNumctes_vencido    = 0;
LET cNumcte             = '';
LET dFecha_Reg          = DATE(1);
LET iRegistros          = 0;
LET dFecha_ini          = DATE(1);
LET dFecha_fin          = DATE(1);
LET dFecha_temp         = DATE(1);
LET dFecha_temp2        = DATE(1);
LET iCantidad           = 0;

LET vPlaza              = '';
LET vCiudad             = '';
LET vSucursal           = '';
LET vOrigen             = '';
LET vTipoCompac         = '';
LET vPlazo              = '';
LET vImporte            = 0;
LET vImpPagado          = 0;
LET vCumplido           = '';
LET vFechaCompac        = DATE(1);
LET vFechaIns           = DATE(1);     
LET dFecha_ini_2        = DATE(1);
LET dFecha_fin_2        = DATE(1);
LET dFecha_temp         = DATE(1);
LET vNumcuenta          = '';
LET cPagoProgramado     = '';
LET iNumSesion          = 0;
LET cArmaTabla          = '';
LET cValor              = '';
LET cNumcte             = '';
LET vFechaMov           = DATE(1);
LET cSuc                = '';
LET v_count_emp         = '';
LET cImporte            = '';
LET cImpPagado          = '';
LET cFechaCompac        = '';
LET cFechaIns           = '';
LET cPagoProgramado_2   = '';
LET cUsuario            = '';
LET vFecha_venc         = date(1);

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	LET cMensajeRet = cErrorInfo;
      	
    	
      RETURN cCodRet, cMensajeRet,"", cRuta;
  END EXCEPTION;

  --SET DEBUG FILE TO '/tmp/mfinis/sp_rep_convenios_sif2_tmp.out';
  --TRACE ON;

  LET dFecha_ini = pFechaIni;
  LET dFecha_fin = pFechaFin;
  LET cUsuario   = pUsr;
  
  LET dFecha_temp = dFecha_ini + 1 UNITS MONTH;
  
  LET dFecha_ini_2 = mdy(month(dFecha_ini),1,year(dFecha_ini));  
  LET dFecha_fin_2 = mdy(month(dFecha_temp),1,year(dFecha_temp)) - 1 UNITS DAY;
  

	SELECT {+ INDEX (bdicobranza:cb_param_campania idx_cb_paramcampania_params1)} TRIM(valor_alfabetico) 
	  INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND  grupo_parametro = 'RUTAS'
	   AND num_parametro =1;

  IF NVL(pEmpresa,"") = "" OR  NVL(dFecha_ini,"") = "" OR  NVL(dFecha_fin,"") = "" OR pProducto = '' THEN
  	LET cCodRet= "000001";
  	LET cMensajeRet = "Parametro no valido para realizar la consulta";
  	RETURN cCodRet, cMensajeRet,"", cRuta;
  END IF;

		SELECT fecha_hoy  INTO dtFecha 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;
		 
		 
    SELECT {+ INDEX (bdicobranza:cb_param_archivos idx_cb_param_archivos_numarch)} tipo_archivo
		  INTO  cTipoArchivo		
		  FROM  bdicobranza:"informix".cb_param_archivos 
		 WHERE num_archivo = 1;

	LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha) || '_' || (pProducto);

  LET cFechaIni = year(dFecha_ini) || '/' || lpad(month(dFecha_ini),2,0) || '/' || lpad(day(dFecha_ini),2,0);
  LET cFechaFin = year(dFecha_fin) || '/' || lpad(month(dFecha_fin),2,0) || '/' || lpad(day(dFecha_fin),2,0);

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
   BEGIN;
      DELETE "informix".sd_convs_encabezados WHERE usuario = cUsuario;
   COMMIT;
   
   UPDATE statistics medium for table "informix".sd_convs_encabezados;
   
   BEGIN;
		DELETE "informix".sd_convs_detalle  WHERE  usuario = cUsuario;
   COMMIT;
	
 	INSERT INTO "informix".sd_convs_encabezados (numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario) 
	VALUES("NumCtes_Con_Venc", "NumCtes_convenios", "plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento", "Pago_Programado",cUsuario);
      
     LET cConsulta3 = ' SELECT numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,nvl(plazo,0),total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento, pago_programado ' ||
                       ' FROM "informix".sd_convs_encabezados ' || 
                       ' WHERE usuario = ' || "'" || cUsuario || "' order by plazo desc";
	
	IF pProducto = '6001' THEN 
            INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)                               
			SELECT 1,{+ INDEX  (bdicobranza:cb_compac_his idx_param)} cch.numcuenta, 
			DECODE(cch.origen,3,'CAT',sp.nombre) plaza, 
			DECODE(cch.origen,3,'CAT',sc.nombre) ciudad, 
			DECODE(cch.origen,3,'CAT',cch.sucursal) sucursal,
			DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
				cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado
				, DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), cch.fecha_compac, cch.fecha_insert, cch.pago_programado,cUsuario
			FROM bdicobranza:cb_compac_his cch 
					LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
					LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) 
					LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
					LEFT OUTER JOIN bdicred:"informix".sd_maecred cr  ON cr.num_credito = cch.numcuenta 
			WHERE cch.empresa= '001' 
				AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin
				AND cr.num_producto = pProducto;
		
			
		
	ELSE 	
			INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
			SELECT 1,cch.numcuenta, 
			DECODE(cch.origen,3,'CAT',sp.nombre) plaza, 
			DECODE(cch.origen,3,'CAT',sc.nombre) ciudad, 
			DECODE(cch.origen,3,'CAT',cch.sucursal) sucursal,
			DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
					cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado, 
					DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), 
					cch.fecha_compac, cch.fecha_insert, cch.pago_programado,cUsuario
			FROM bdicobranza:cb_compac_his cch 
				LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
				LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) 
				LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
				LEFT OUTER JOIN bdicred:"informix".sd_maecredcrd crd ON crd.num_credito = cch.numcuenta
			WHERE cch.empresa= '001' 
				AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin
				AND crd.num_producto = pProducto;
    END IF;
	
	UPDATE "informix".sd_convs_detalle SET
	cumplido='MISMO DIA'
	WHERE origen ='SUCURSAL' and 
	fecha_compac = fecha_vencimiento
	AND usuario = cUsuario;
  
	INSERT INTO "informix".sd_convs_encabezados(numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
	SELECT 0,0,plaza, ciudad, sucursal, origen, tipo_compac, plazo, COUNT(empresa), SUM(importe), SUM(importe_pagado), cumplido,
			   to_char(fecha_compac, '%d/%m/%Y'), to_char(fecha_vencimiento, '%d/%m/%Y'), case when pago_programado = 'S' then 'Intento Convenio Pago Programado' else '' end  pago_programado, cUsuario 
		  FROM "informix".sd_convs_detalle
		 WHERE fecha_vencimiento BETWEEN dFecha_ini AND dFecha_fin   
		   AND usuario = cUsuario
	group by plaza, ciudad, sucursal, origen, tipo_compac, plazo, cumplido, fecha_compac, fecha_vencimiento, pago_programado;
		
	DROP TABLE IF EXISTS bdicred: tme_sum_convenios_sif;	
	DROP TABLE IF EXISTS bdicred: tme_sum_convenios_sif2;	
	
	--UPDATE numctes_con_vencido 	
	SELECT DISTINCT(sucursal) sucursal,sum(numctes_vencido)  numctes_vencido
	from "informix".sd_vencidos_suc 
	where fecha_reg BETWEEN dFecha_ini AND dFecha_fin
	group by sucursal
	INTO TEMP tme_sum_convenios_sif WITH NO LOG;

	UPDATE "informix".sd_convs_encabezados enc SET 
	enc.numctes_con_vencido = (select numctes_vencido from tme_sum_convenios_sif tme where tme.sucursal=enc.sucursal)
	WHERE enc.sucursal >= '0000' and enc.sucursal <> 'sucursal'
	AND enc.usuario = cUsuario;	
   
   --UPDATE numctes_convenios
    select DISTINCT(sucursal) sucursal,sum(cantidad) cantidad  
	from "informix".sd_convenios_sucursal
	where fecha between dFecha_ini AND dFecha_fin
	group by sucursal
	INTO TEMP tme_sum_convenios_sif2 WITH NO LOG;

    UPDATE "informix".sd_convs_encabezados enc SET 
	enc.numctes_convenios = (select cantidad from tme_sum_convenios_sif2 tme where tme.sucursal=enc.sucursal)
	WHERE sucursal >= '0000' and enc.sucursal <> 'sucursal'
	AND enc.usuario = cUsuario;	
   
	LET cSql = '';
	
	LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cConsulta3)||'" > '|| TRIM(cRuta) ||'query4.sql';
	
	SYSTEM trim(cSql);
	
	LET cSql = '';
	LET cSql = '/informix/bin/dbaccess bdicred ' ||trim(cRuta)||'query4.sql';
	SYSTEM trim(cSql);

	-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
	LET cSql = '';
	LET cSQL = "rm " ||trim(cRuta)||'query4.sql';
	SYSTEM trim(cSql); 
	LET cSql = '';

	LET cNombreArchivo= trim(cNombreArchivo)||'.'||trim(cTipoArchivo);
    
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
       
		RETURN cCodRet, cMensajeRet,cNombreArchivo , cRuta;
END
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'DESCRIPCION:Se agrego el producto como parametro de entrada y que muestre la ruta al generar los reportes.',
'MODIFICACION: Martha Salgado Mendoza',
'FECHA: 01/08/2016',
'DESCRIPCION: Se modifico Delete de la tabla sd_convs_detalle para eliminar solo por usuario',
'BASE: dbicred ',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 03/08/2016',
'DESCRIPCION: Se modifico la direccion para que tenga acceso a la ruta especificada',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/08/2016',
'DESCRIPCION: Se modifico update de la tabla sd_convs_detalle , se agrego el usuario',
'BASE: dbicred ',
'FECHA : 11/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica el nombre del sql que se genera internamente';

CREATE PROCEDURE "informix".sp_traspasocuentas_cred2(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);

--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vi_MaxSec        INTEGER;
DEFINE iExiste      SMALLINT;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vi_MaxSec = 0;
LET iExiste=0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
			
							
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_si_refclienteTraspasaCtas')THEN
				DROP TABLE tmp_si_refclienteTraspasaCtas;
			END IF;
			
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sirefdireccionesCliente')THEN
				DROP TABLE tmp_sirefdireccionesCliente;
			END IF;
			
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/JesusBueno/sp_traspasocuentas_cred2.out";
--TRACE ON;

	 --**INICIA TRASPASO DE COBRANZA
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN	
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'CART_QUEBRANTAR',"cb_rep_cart_quebrantar",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_rep_cart_quebrantar  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusrep_cart_quebrantar (num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte)
	    SELECT num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte
		FROM bdicobranza:"informix".cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_rep_cart_quebrantar SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    END IF;
    --**
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_MC
    SET ISOLATION TO DIRTY READ; 
     SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)}  'SOLICITUDES_MC',"ss_solicitudes_mc",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_mc  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_mc  (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta) 
        SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta
		FROM bdisolic:"informix".ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;

        UPDATE{+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} bdisolic:"informix".ss_solicitudes_mc SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
	
	END IF;
    
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_SIC
    
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  'SOLICITUDES_SIC',"ss_solicitudes_sic",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_sic  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_sic (empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic) 
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic
		FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} bdisolic:"informix".ss_solicitudes_sic SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
 
    END IF;
    --***
    --***INICIA TRASPASO DE TABLA SS_SOLICITUDES_CAC
    SET ISOLATION TO DIRTY READ; 
       SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  'SOLICITUDES_CAC',"ss_solicitudes_cac",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_cac  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fussolicitudes_cac (empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado
		FROM bdisolic:"informix".ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  bdisolic:"informix".ss_solicitudes_cac SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
    
	--***INICIA TRASPASO DE TABLA
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} COUNT(num_credito) INTO iExiste FROM bdicred:sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  'CAMPAÑAS INACTIVAS',"sd_camp_inactiv_nuncas",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM "informix".sd_camp_inactiv_nuncas  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscamp_inactiv_nuncas (empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago
		FROM bdicred:"informix".sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  bdicred:"informix".sd_camp_inactiv_nuncas SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC
    SET ISOLATION TO DIRTY READ; 
  SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac WHERE empresa ='001' AND  numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
    
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  'COMPAC COBRANZA',"cb_compac",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac  WHERE empresa ='001' AND  numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo )
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac WHERE empresa ='001' AND numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac idx_compac2)} bdicobranza:"informix".cb_compac SET numcliente = pClienteTitular where empresa ='001' AND  numcliente=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC_HIS
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_his WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'COMPAC COBRANZA HIS',"cb_compac_his",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_his  WHERE numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac_his (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo)
		SELECT empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac_his WHERE  numcliente=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_compac_his SET numcliente = pClienteTitular where   numcliente=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT  {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  'DIRECTORIO COBRANZA',"cb_cat_directorio_cte",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp)
        SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp
		FROM bdicobranza:"informix".cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} bdicobranza:"informix".cb_cat_directorio_cte SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	--***
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE_HIST
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'DIRECTORIO COBRANZA HIS',"cb_cat_directorio_cte_his",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte_his  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte_his (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica)
		SELECT empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica
		FROM bdicobranza:"informix".cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE bdicobranza:"informix".cb_cat_directorio_cte_his SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_COMPAC_ERROR
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_error WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} 'COMPAC COBRANZA ERROR',"cb_compac_error",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_error  WHERE  empresa ='001'  AND numcliente= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscompac_error (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal 
		FROM bdicobranza:"informix".cb_compac_error WHERE numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} bdicobranza:"informix".cb_compac_error SET numcliente = pClienteTitular where numcliente=pClienteTraspasaCtas;

    END IF;
	--***INICIA TRASPASO DE TABLA ADICOPPEL
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} COUNT(numcte) INTO iExiste FROM bdinteg:si_adiccoppel WHERE empresa ='001' AND numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		-- BD -- SELECT  {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)}  'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		SELECT 'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusadiccoppel(empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert)
	    SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert
		FROM bdinteg:"informix".si_adiccoppel WHERE empresa='001' AND numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} bdinteg:"informix".si_adiccoppel SET numcte = pClienteTitular WHERE empresa ='001'  AND numcte=pClienteTraspasaCtas;
    
    END IF;
	
--***INICIA TRASPASO DE TABLA REFDIRECCIONES
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas;

	IF iExiste > 0  THEN
			
			SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTitular;
			
			IF vi_MaxSec >0  THEN 
				
				CREATE TEMP TABLE tmp_sirefdireccionesCliente 
				  (
					posicion_secuencia serial,
					numcte CHAR(20) NOT NULL ,
					secuencia INTEGER ,
					tipo_dir CHAR(1),
					calle CHAR(40),
					colonia CHAR(60),
					entre_calles CHAR(40),
					pais CHAR(3),
					estado CHAR(2),
					ciudad CHAR(3),
					municipio CHAR(5),
					cod_postal CHAR(5),
					apart_postal CHAR(11),
					tipo_telef1 CHAR(1),
					telefono1 CHAR(13),
					tipo_telef2 CHAR(1),
					telefono2 CHAR(13),
					tipo_telef3 CHAR(1),
					telefono3 CHAR(13),
					extension CHAR(5),
					estado_inegi CHAR(2),
					municipio_inegi CHAR(3),
					localidad_inegi CHAR(4),
					numerociudad SMALLINT,
					numeroextcalle CHAR(10),
					numerointcalle CHAR(10),
					departamento CHAR(6),
					numerocalle INTEGER,
					numerocolonia INTEGER,
					puntocardinal CHAR(1),
					unidadhabitac CHAR(1),
					manzana SMALLINT,
					otros SMALLINT,
					andador SMALLINT,
					etapa SMALLINT,
					lote SMALLINT,
					edificio SMALLINT,
					entrada SMALLINT,
					observaciones CHAR(80),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE,
					ind_cofeteltel1 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel2 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel3 CHAR(1) 
						DEFAULT 'F',
					movil_fijo1 CHAR(1) 
						DEFAULT '0',
					status_stel1 CHAR(1) 
						DEFAULT '',
					movil_fijo2 CHAR(1) 
						DEFAULT '0',
					status_stel2 CHAR(1) 
						DEFAULT '',
					movil_fijo3 CHAR(1) 
						DEFAULT '0',
					status_stel3 CHAR(1) 
						DEFAULT ''
				  );
				
				
				INSERT INTO tmp_sirefdireccionesCliente(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM bdinteg:"informix".si_refdirecciones
				WHERE  numcte = pClienteTraspasaCtas;

				
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_sirefdireccionesCliente  WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg: si_refdirecciones (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT pClienteTitular,vi_MaxSec+posicion_secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				DROP TABLE tmp_sirefdireccionesCliente;
				DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTraspasaCtas;			
			
		ELSE 
			
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
									
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM  bdinteg:"informix".si_refdirecciones
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_refdirecciones  WHERE numcte= pClienteTraspasaCtas;
							
				UPDATE  bdinteg:"informix".si_refdirecciones SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			END IF;	
 END IF;

--**********INICIA TRASPASO DE TABLA REFCLIENTES 
	
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas;
		
	IF iExiste > 0 THEN 
						SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refclientes  WHERE numcte=pClienteTitular;
			IF vi_MaxSec> 0  THEN
				
				CREATE TEMP TABLE tmp_si_refclienteTraspasaCtas 
				  (	
					posicion_secuencia serial,
					empresa CHAR(3),
					num_solicitud CHAR(20) 
						DEFAULT '' NOT NULL ,
					numcte CHAR(20),
					sucursal CHAR(4),
					secuencia INTEGER ,
					apell_paterno CHAR(26),
					apell_materno CHAR(26),
					nombre1 CHAR(26),
					nombre2 CHAR(26),
					rfc CHAR(13),
					fecha_nac DATE,
					curp CHAR(20),
					sexo CHAR(1),
					estado_civil CHAR(2),
					nacionalidad CHAR(3),
					no_fm3 CHAR(18),
					codidentifi CHAR(2),
					numidentifi CHAR(30) 
						DEFAULT '',
					pers_domicilio CHAR(2),
					email CHAR(60),
					parentesco CHAR(2),
					apellido_cas CHAR(26),
					numcte_ref CHAR(20),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE
				  );
				
				INSERT INTO tmp_si_refclienteTraspasaCtas (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM bdinteg:"informix".si_refclientes
				WHERE  numcte = pClienteTraspasaCtas;
				

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_si_refclienteTraspasaCtas  WHERE numcte= pClienteTraspasaCtas;
				
				
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_refclientes (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				
				SELECT empresa,num_solicitud,pClienteTitular,sucursal,vi_MaxSec+posicion_secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				
				DROP TABLE tmp_si_refclienteTraspasaCtas;
				DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:"informix".si_refclientes WHERE numcte=pClienteTraspasaCtas;
			
		ELSE 
			
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
									
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM  bdinteg:si_refclientes
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:si_refclientes  WHERE numcte= pClienteTraspasaCtas;
				
				UPDATE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} bdinteg:si_refclientes SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
		END IF;
	END IF;

	--******INICIA TRASPASO DE TABLA INGRESOS 
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN
		SELECT COUNT(*) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTitular;
			
			LET vc_tabla = "si_ingresos";
            LET vc_proceso='INGRESOS';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'INGRESOS',"si_ingresos",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||sec_ingreso||"|"||TRIM(tipo_ingreso),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_ingresos   WHERE numcte= pClienteTraspasaCtas;
			
            INSERT INTO bdinteg:"informix".si_fusingresos (empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext)
			SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext
			FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
				
			IF iExiste=0 THEN
					UPDATE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} bdinteg:"informix".si_ingresos SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas ;
				ELSE
					DELETE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
			END IF;		
    END IF;	   
    IF vc_CodRet = "00000" THEN
		RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE
DOCUMENT
'Folio: 1447',
'Autor: 95347143 ',
'Fecha: 22/07/2014',
'Descripción: Optmizar sp sp_traspasocuentas_cred para reducir tiempos y costos de ejecución. Se secciono el sp, la segunda parte se llama',
'sp_traspasocuentas_cred2. Se eliminaron selec *, se eliminaron ciclos foreach (lo mas posible) y hacer uso de indices. ',
'Sustento: Analisis RQI64012 Optimizacion de proceso de fusion automatica.pdf',
'Solicita: Jose Angel Lopez Adams',
'BD: bdicred',
'----------------------------------------------',
'AUTOR: Rocio Karina Márquez Coronel',
'FECHA: 14/04/2015',
'DESCRIPCION: Se modificó estructuras de la fusión ya que se agregó un campo nuevo a la tabla cb_compac_his',
'SUSTENTO: RQI 64 081',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_elimina_sd_prospectos()
RETURNING CHAR(6);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(6);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "000";
LET vsqlerr = 0;
LET numcredito="";
LET icontador=1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_elimina_sd_prospectos.out";
--TRACE ON;

  FOREACH WITH HOLD 

        SELECT num_credito
          INTO numcredito
	      FROM "informix".sd_prospectos 
		 WHERE num_producto = '6900'
		   AND num_promo = '7'		 

        IF icontador = 1 THEN
          BEGIN WORK;
        END IF;

        DELETE FROM "informix".sd_prospectos WHERE num_credito = numcredito AND num_producto = '6900' AND num_promo = '7';		
     
    IF icontador = 2000 then
        COMMIT WORK; 
        LET icontador = 1;
    ELSE
        LET icontador = icontador + 1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  UPDATE statistics medium FOR TABLE "informix".sd_prospectos;


  RETURN scod_ret;
END
END PROCEDURE;