CREATE PROCEDURE "informix".sp_rpt_segmentacion_clientes_tdc()
returning 
          CHAR(6) as resultado,
          CHAR(100) as mensaje;
		  
	DEFINE cMensajeRet      CHAR(100);
	DEFINE iCodRet          INTEGER;
	DEFINE SCodRet          CHAR(6);
	DEFINE  dtFechaHoy     	DATE;
	DEFINE  dtFechaAnt     	DATE;
	DEFINE  dtFechaRep     	CHAR(8);
	DEFINE  cRuta			CHAR(100);
	DEFINE  cNomArchRep 	CHAR(50);
	DEFINE  cSQL            CHAR(4000);
	DEFINE  cSQLEnc1		CHAR(300);
	DEFINE  cSQLEnc2		CHAR(300);
	DEFINE  cSQLEnc3		CHAR(300);
	DEFINE  cSQLEncFinal	CHAR(300);
	
	--SET DEBUG FILE TO "/informix/marcov/sp_rep_segmentacion_clientes_tdc.out";
    --TRACE ON; 
	
	
--Inicialización de variables
	LET cMensajeRet = 'El Reporte de segmentación de Clientes de TDC se realizó correctamente';
	LET iCodRet     = 0;
	LET SCodRet     ='000000';
	LET dtFechaHoy  = DATE(1);
	LET dtFechaAnt  = DATE(1);
	LET dtFechaRep  = '';
	LET cRuta       = '';
	LET cNomArchRep = '';
	LET cSQL        = '';
	LET cSQLEnc1	= '';
	LET cSQLEnc2	= '';
	LET cSQLEnc3	= '';
	LET cSQLEncFinal = '';
	
	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF iCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en la ejecución del Reporte de segmentación de Clientes de TDC';
	END IF;
	RETURN SCodRet,cMensajeRet;
	END EXCEPTION;
	
	--Seleccionamos la ruta de donde se tomará el archivo asi como donde se guardará el reporte una vez generado  /resplogifx/archivoscartera/
	SELECT TRIM(valor_alfabetico) INTO cRuta 
	FROM bdicobranza:"informix".cb_param_campania WHERE empresa = '001' and tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;
	
	--let cRuta = '/informix/marcov/';
	
	--Seleccionamos Fecha de hoy
	SELECT NVL(fecha_hoy ,today) 
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	
	
	--Seleccionamos Fecha del cierre mes anterior
	LET dtFechaAnt = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 1 units day;
	
	--Obtenemos Fecha para nombre de archivos
	LET dtFechaRep = year(dtFechaAnt) || lpad(month(dtFechaAnt),2,0) || lpad(day(dtFechaAnt),2,0);
	
	--Armar el nombre del archivo que contiene reporte Final
    LET cNomArchRep = 'RptSegmentacionClientesTDC'||dtFechaRep ||'.txt';
	
	---Para Armar encabezado que consta de 3 partes 
	LET cSQLEnc1='';
	LET cSQLEnc1 = 'echo " '||'|'||' '||'|'||'Joven'||'|'||' '||'|'||' '||'|'||' '||'|'||'Adulto'||'|'||' '||'|'||' '||'|'||' '||'|'||'Maduro'||'|'||' '||'|'||' '||'|'||'" >'||TRIM(cRuta)||'queryencab1.txt';			 
	SYSTEM cSQLEnc1; 
	
	LET cSQLEnc2='';
	LET cSQLEnc2 = 'echo " '||'|'||'Hombre'||'|'||' '||'|'||'Mujer'||'|'||' '||'|'||'Hombre'||'|'||' '||'|'||'Mujer'||'|'||' '||'|'||'Hombre'||'|'||' '||'|'||'Mujer'||'|'||' '||'|'||'" >'||TRIM(cRuta)||'queryencab2.txt';			 
	SYSTEM cSQLEnc2; 
	
	LET cSQLEnc3='';
	LET cSQLEnc3 = 'echo "Linea'||'|'||'Casado'||'|'||'Soltero'||'|'||'Casado'||'|'||'Soltero'||'|'||'Casado'||'|'||'Soltero'||'|'||'Casado'||'|'||'Soltero'||'|'||'Casado'||'|'||'Soltero'||'|'||'Casado'||'|'||'Soltero'||'|'||'" >'||TRIM(cRuta)||'queryencab3.txt';			 
	SYSTEM cSQLEnc3; 
	
	LET cSQLEncFinal='';
	LET cSQLEncFinal= "sed 's/|$//g' " ||TRIM(cRuta)||"queryencab3.txt "||" >> "||TRIM(cRuta)||"queryencab2.txt;"
	||" sed 's/|$//g' "||TRIM(cRuta)||"queryencab2.txt"||" >> "||TRIM(cRuta)||"queryencab1.txt";
	SYSTEM cSQLEncFinal;
		
    --Obtener y guardar en tabla temporal la información en base a los criterios de segmentación
    Let  cSQL = 'echo "set isolation to dirty read;'
		||' select (CASE' 
		||' WHEN  (year(today) - year(pf.fecha_nac)) >= 18 and (year(today) - year(pf.fecha_nac))<=30  then ''JOVEN'''
		||' WHEN  (year(today) - year(pf.fecha_nac)) >= 31 and (year(today) - year(pf.fecha_nac))<=55  then ''ADULTO''' 
		||' else ''MADURO'' end) EDAD,' 
		||'		(CASE '
		||'		 WHEN  sdo.monto_otorgado = 0  then ''R0_CERO'''
		||'		 WHEN  sdo.monto_otorgado > 0 and sdo.monto_otorgado <= 1200  then ''R1_M_CERO'''
		||'		 WHEN  sdo.monto_otorgado > 1200 and sdo.monto_otorgado <= 3000  then ''R2_M_1200''' 
		||'		 WHEN  sdo.monto_otorgado > 3000 and sdo.monto_otorgado <= 5000  then ''R3_M_3000''' 
		||'		 WHEN  sdo.monto_otorgado > 5000 and sdo.monto_otorgado <= 10000  then ''R4_M_5000''' 
		||'		 WHEN  sdo.monto_otorgado > 10000 and sdo.monto_otorgado <= 15000  then ''R5_M_10000''' 
		||'		 WHEN  sdo.monto_otorgado > 15000 and sdo.monto_otorgado <= 30000  then ''R6_M_15000'''
		||'		 WHEN  sdo.monto_otorgado > 30000 and sdo.monto_otorgado <= 60000  then ''R7_M_30000'''
		||'		else ''R8_M_60000'' end) RANGO,'
		||'		pf.sexo,(CASE WHEN pf.estado_civil IN (''C'',''U'') THEN ''C'' ELSE ''S''END) estado_civil , count(cre.numcte) cantidadctes '
		||' from bdicred:sd_maecredcont cre, bdicred:sd_maesdoscont sdo, bdinteg:si_ctepf pf'
		||' where cre.empresa = sdo.empresa'
		||' and cre.num_credito = sdo.num_credito'
		||' and cre.numcte = pf.numcte'
		||' and cre.status_cred in (''BA'',''AA'',''BT'',''E1'',''E2'',''E3'')'
        ||' and cre.campo_trab3= '''''
		||'	and cre.fecha = sdo.fecha'
		||'	and sdo.fecha = '''||dtFechaAnt||''''
		||' group by 1,2,3,4'
		||' into temp infoagrup with no log;'
	
		--Guardar información de tabla temporal de acuerdo al layout del reporte
		||' select Rango,'
		||' sum(CASE WHEN edad= ''JOVEN'' and sexo = ''M'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as JovenHombreCasado,'
		||' sum(CASE WHEN edad= ''JOVEN'' and sexo = ''M'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as JovenHombreSoltero,'
		||' sum(CASE WHEN edad= ''JOVEN'' and sexo = ''F'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as JovenMujerCasado,'
		||' sum(CASE WHEN edad= ''JOVEN'' and sexo = ''F'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as JovenMujerSoltero,'
		||' sum(CASE WHEN edad= ''ADULTO'' and sexo = ''M'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as AdultoHombreCasado,'
		||' sum(CASE WHEN edad= ''ADULTO'' and sexo = ''M'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as AdultoHombreSoltero,'
		||' sum(CASE WHEN edad= ''ADULTO'' and sexo = ''F'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as AdultoMujerCasado,'
		||' sum(CASE WHEN edad= ''ADULTO'' and sexo = ''F'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as AdultoMujerSoltero,'
		||' sum(CASE WHEN edad= ''MADURO'' and sexo = ''M'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as MaduroHombreCasado,'
		||' sum(CASE WHEN edad= ''MADURO'' and sexo = ''M'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as MaduroHombreSoltero,'
		||' sum(CASE WHEN edad= ''MADURO'' and sexo = ''F'' and estado_civil = ''C'' THEN cantidadctes ELSE 0 END) as MaduroMujerCasado,'
		||' sum(CASE WHEN edad= ''MADURO'' and sexo = ''F'' and estado_civil = ''S'' THEN cantidadctes ELSE 0 END) as MaduroMujerSoltero'
		||' from infoagrup' 
		||' group by rango'
		||' into temp infoagrup2 with no log;'
	
		--Ordenar la información de acuerdo al rango y generar reporte
		||' unload to ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'queryinformacion.txt' || ' DELIMITER ' || '''|'''
		||' select (CASE WHEN rango = ''R0_CERO'' THEN '||'''$''||''0'''|| ' WHEN rango = ''R1_M_CERO'' THEN ' ||'''$''||''1 - $''||''1,200'''
		||' WHEN rango = ''R2_M_1200'' THEN '||'''$''||''1,201 - $''||''3,000'''
		||' WHEN rango = ''R3_M_3000'' THEN '||'''$''||''3,001 - $''||''5,000'''
		||' WHEN rango = ''R4_M_5000'' THEN '||'''$''||''5,001 - $''||''10,000''' 
		||' WHEN rango = ''R5_M_10000'' THEN '||'''$''||''10,001 - $''||''15,000'''
		||' WHEN rango = ''R6_M_15000'' THEN '||'''$''||''15,001 - $''||''30,000'''
		||' WHEN rango = ''R7_M_30000'' THEN '||'''$''||''30,001 - $''||''60,000'''
		||' ELSE '||'''> $''||''60,000'''||' END ::char(50) ) Linea,' 
		||' jovenhombrecasado ::integer,jovenhombresoltero ::integer,jovenmujercasado ::integer,jovenmujersoltero ::integer,'
		||' adultohombrecasado ::integer,adultohombresoltero ::integer,adultomujercasado ::integer,adultomujersoltero ::integer,'
		||' madurohombrecasado ::integer,madurohombresoltero ::integer,maduromujercasado ::integer,maduromujersoltero ::integer'
		||' from  infoagrup2' 
		||' order by rango;'
		||'" > '||TRIM(cRuta) ||'query.sql';
	
	System cSQL;
	LET cSQL = "dbaccess bdicred "||TRIM(cRuta) ||"query.sql";
	System cSQL;
	
	--Se une el ancabezado con la información para conformar el reporte
	let cSQL = '';
	LET cSQL= "sed 's/|$//g' " ||TRIM(cRuta)||"queryinformacion.txt"||" >> "||TRIM(cRuta)||"queryencab1.txt;"
	||" sed 's/|$//g' "||TRIM(cRuta)||"queryencab1.txt"||" >> "||TRIM(cRuta)||SUBSTR(cNomArchRep,1,LENGTH(cNomArchRep));
	SYSTEM cSQL;
	
	--borrar archivo .sql y .txt que ya no se utilizarán
	let cSQL = '';
    let cSQL = "rm " || SUBSTR(cRuta,1,LENGTH(cRuta)) || "query.sql "|| SUBSTR(cRuta,1,LENGTH(cRuta)) || "queryencab1.txt " 
					 || SUBSTR(cRuta,1,LENGTH(cRuta)) ||"queryencab2.txt "|| SUBSTR(cRuta,1,LENGTH(cRuta)) || "queryencab3.txt " 
					 || SUBSTR(cRuta,1,LENGTH(cRuta)) ||"queryinformacion.txt";
    System cSQL;
	
	 RETURN SCodRet,cMensajeRet;
	 END;
				
END PROCEDURE 
DOCUMENT
'Se  realiza procedimiento para generar reporte de segmentación de clientes de TDC para establecer parametros de uso de la tarjeta y evaluar los planes de negocio de acuerdo a cada tipo de clientes',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 06/03/2013',
'BD    : BDICRED',
'Version: ',
'Modificación : ',
'AUTOR : ',
'FECHA :',
'BD    : ';

CREATE PROCEDURE "informix".sp_clona_tdc_upgrade_nocturno(pEmpresa CHAR(3), pFecha DATE)
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE vCodRet 		 CHAR(6);
DEFINE vMsjRetorno   VARCHAR(100,1);
DEFINE cod_ret       CHAR(3);
DEFINE cnumcreditoupgrade CHAR(20);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cnum_credito CHAR(20);
DEFINE CstatusSol    CHAR(2);

---CLONACION DE TDC Oro
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE vDiaCorte             SMALLINT;
DEFINE cbandclonadocompleto CHAR(1);

---CLONACION DE TDC Oro

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizÃ³ la consulta correctamente.';
LET vCodRet       = '';
LET vMsjRetorno	  = '';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET CstatusSol    = '';
LET cnumcreditoupgrade = '';
LET cnum_credito = '';
LET V_TASA_INTERES 		= 0.0;
LET V_TASA_MORA			= 0.0;
LET V_SOBRETASA   		= 0;
LET V_TASA_FAVOR  		= 0;
LET V_SOBRETASA_FAV 	= 0;
LET V_FACTOR			= "";
LET V_FECHA_APERT 		= DATE(1);
LET V_FACTOR_FAV 		= "";
LET vDiaCorte 			= 0;
LET cbandclonadocompleto= "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/Malena/sp_clona_tdc_upgrade.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:"informix".si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pFecha,''))=''  THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parÃ¡metro no es valido';

  RETURN cCodRet, cMensajeRet;
END IF;

		--clonado del credito
		SELECT fecha_hoy
		  INTO V_FECHA_APERT
		  FROM sd_fechas
		 WHERE empresa = cEmpresa;

	   -- **************************************************
	   -- Extrae informacion del Credito *
	   -- **************************************************	   	
	FOREACH WITH HOLD
		
		SELECT a.num_credito,b.num_credito, a.num_producto, b.bclonadocompleto
		INTO cnumcreditoupgrade,cnum_credito, cNumProducto, cbandclonadocompleto
		FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_credito_upgrade b
		WHERE a.empresa = cEmpresa
		AND a.num_credito = b.numero_credito_upgrade
		AND a.fecha_apertura = pFecha	

			  -- ****************************
			  -- Determina Tasas de Interes *
			  -- ****************************
			--INTERES ORDINARIO
			SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota
			  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte
			  FROM bdicred:"informix".sd_definicion a,  bdinteg:"informix".si_fechavalor c
			 WHERE a.empresa = cEmpresa
			   AND a.num_producto = cNumProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					   WHERE r.empresa = cEmpresa
						 AND r.tasa = a.cod_tasa_base);


			IF v_factor = "+" THEN
				LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
			ELIF v_factor = "-" THEN
				LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
			ELIF v_factor = "*" THEN
				LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
			ELSE
				LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
			END IF

			--INTERES MORATORIO
			SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
			  FROM bdicred:"informix".sd_definicion a, bdinteg:"informix".si_fechavalor c
			 WHERE a.empresa = cEmpresa
			   AND a.num_producto = cNumProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_mora
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							   WHERE r.empresa = cEmpresa
								 AND r.tasa = a.cod_tasa_mora);

			IF v_factor = "+" THEN
					LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA;
			ELIF v_factor = "-" THEN
					LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA;
			ELIF v_factor = "*" THEN
					LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA;
			ELSE
					LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			  INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
			  FROM bdicred:"informix".sd_anexodefinicion a, bdinteg:"informix".si_fechavalor c
			 WHERE a.empresa = cEmpresa
			   AND a.num_producto = cNumProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							   WHERE r.empresa = cEmpresa
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

			-- Se valida la bandera que indica si el clonado esta completo o no para realizar los insert de las tablas faltantes.
			IF cbandclonadocompleto = '0' THEN

				--CLONADO DE TABLA DE SD_MAECREDCONT
				INSERT INTO bdicred:"informix".sd_maecredcont(fecha, empresa, num_credito, num_producto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2)
				SELECT fecha, empresa, cnumcreditoupgrade, cNumProducto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2
				FROM bdicred:"informix".sd_maecredcont
				WHERE empresa=cEmpresa 
				AND num_credito = cnum_credito;   

				--CLONADO DE TABLA de SD_MAESDOSCONT
				INSERT INTO bdicred:"informix".sd_maesdoscont(fecha,empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4,act)
				SELECT fecha,empresa,cnumcreditoupgrade, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4,act
				FROM bdicred:"informix".sd_maesdoscont WHERE empresa= cEmpresa and num_credito =cnum_credito;

				--CLONADO DE TABLA DE SD_MAESDOSHIST
				INSERT INTO bdicred:"informix".sd_maesdoshist(fecha,
				empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4,act)
				SELECT mdy(month(fecha),vDiaCorte,year(fecha)),
				empresa,cnumcreditoupgrade, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4,act
				FROM bdicred:"informix".sd_maesdoshist WHERE empresa= cEmpresa and num_credito =cnum_credito;

				--CLONADO DE TABLA DE SD_HIST_RESERVA
				INSERT INTO bdicred:"informix".sd_hist_reserva(empresa, fecha_corte,	num_credito, fecha_cierre,grado_riesgo,
				fecha_apertura,antecedente_buro,status_cred,linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,
				saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr)
				SELECT 
				empresa, mdy(month(fecha_corte),vDiaCorte,year(fecha_corte)),
				cnumcreditoupgrade, fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,
				linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr    
				FROM   bdicred:"informix".sd_hist_reserva 
				WHERE  empresa= cEmpresa and num_credito =cnum_credito;
				
				-- ActualizaciÃ³n de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:"informix".sd_credito_upgrade  SET bclonadocompleto='1'
				WHERE num_credito =cnum_credito;
				
			END IF;

			
		END FOREACH;
	RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento nocturno para el clonado de las tablas historicas TDC clasica a la nueva TDC ORO que se ejecutarÃ¡',
'al cierre de las sucursales para que quede completo el clonado del upgrade al fin de dÃ­a',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 25/08/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".cobranza (pempresa char(3),pnum_credito char(20),v_fechahoy date)
RETURNING CHAR(5),char(51);

--Modificacion 05112009
--Homologar uso de valor "tipo de casa" (habita_en) a nuevo catalogo (claves en letras) en paso 02 alta unica

--DECLARACION DE VARIABLES:


DEFINE cod_ret         		CHAR(5);
DEFINE sql_err         		INTEGER;
DEFINE v_cl_cobranza        CHAR(51);

DEFINE v_tp_cliente         CHAR(2);
DEFINE v_situacion          CHAR(1);
DEFINE v_estado_civil       CHAR(1);
DEFINE v_tp_casa            CHAR(1);
DEFINE v_sexo               CHAR(1);
DEFINE v_cantidad           CHAR(2);
DEFINE v_antiguedad         CHAR(2);
DEFINE v_nacimiento         CHAR(2);
DEFINE v_mto_tot_adeudo     CHAR(5);
DEFINE v_adeudo_vencido     CHAR(5);
DEFINE v_fec_ult_pago       CHAR(4);
DEFINE v_fec_ult_pago_month CHAR(2);
DEFINE v_fec_ult_pago_year  CHAR(2);
DEFINE v_cuantos_avisos		INTEGER;

DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_avisos 	    	CHAR(1);
DEFINE v_nivel_eficiencia     	CHAR(2);


DEFINE v_numcte             CHAR(10);


DEFINE v_sec_ingreso        CHAR(2);
DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		    	VARCHAR(40);
DEFINE v_clave2		    	VARCHAR(40);
DEFINE v_clave3		    	VARCHAR(40);
DEFINE v_clave4		    	VARCHAR(40);
DEFINE v_clave5         	VARCHAR(40);


--INICIALIZO VARIABLES:

LET cod_ret        		 = "";
LET sql_err        		 = "";
LET v_cl_cobranza        = "";

LET v_tp_cliente         = "";
LET v_situacion          = "";
LET v_estado_civil       = "";
LET v_tp_casa            = "";
LET v_sexo               = "";
LET v_cantidad           = "";
LET v_antiguedad         = "";
LET v_nacimiento         = "";
LET v_mto_tot_adeudo     = "";
LET v_adeudo_vencido     = "";
LET v_fec_ult_pago       = "";
LET v_fec_ult_pago_month = "";
LET v_fec_ult_pago_year  = "";

LET v_monto_ult_convenio = "";
LET v_fecha_ult_convenio = "";
LET v_est_cumpl_convenio = "";
LET v_avisos 	    	 = "0";

LET v_numcte             = "";

LET v_sec_ingreso        = "";
LET v_salario            = 0;
LET v_monto_adeudo		 = 0;
LET v_mto_adeudo_venc    = 0;

LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5         	= "";
LET v_cuantos_avisos	= 0;
LET v_nivel_eficiencia	= 0;


--SET DEBUG FILE TO "cobranza.out";
--TRACE ON;

BEGIN


  ----------------------CONTROLO LOS ERRORES------------------------------------------
  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret,'';
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    --------------------------------------------------------
    --	1.--TIPO DE CLIENTE: (2 Numero)
    --------------------------------------------------------
	SELECT numcte,'01',
			CASE 
                WHEN ((a.status_cred in ('AA','E1')) and (b.mto_venc_trasp + b.monto_vencido <= 0)) THEN '0'
                WHEN ((a.status_cred in ('BA','E1')) and (b.mto_venc_trasp + b.monto_vencido > 0)) THEN '1'
                WHEN ((a.status_cred in ('BT','E2','E3')) and (b.mto_venc_trasp + b.monto_vencido > 0)) THEN '2'
                ELSE '0'
           END
		INTO   v_numcte,v_tp_cliente,v_avisos
	FROM   bdicred:sd_maecred a
    inner join bdicred:sd_maesdos b ON (a.num_credito = b.num_credito)
		WHERE a.num_credito = pnum_credito
		AND a.empresa = pempresa;

  	IF LENGTH(TRIM(v_tp_cliente)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "206";
  		END IF
  	END IF
    --------------------------------------------------------
    --	2.--SITUACION ESPECIAL: (1 letra)
    --------------------------------------------------------
	LET v_situacion = " ";
    --------------------------------------------------------
    --3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Año Nacimiento (2 Numeros)
    --------------------------------------------------------
	SELECT 	TRIM(NVL(estado_civil,'')),
			--TRIM(NVL(SUBSTR(habita_en, 2,1),'1')), --usado hasta antes de paso2 de alta unica, catalogo con valores 01, 02, etc
            nvl(substr(TRIM(habita_en),1,1), 'P'),  --Cambio a catalgo, ahora usa letras, paso 02 alta unica, default propia
		  	TRIM(NVL(sexo,'')),
		  	NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	INTO 	v_estado_civil,
			v_tp_casa,
			v_sexo,
			v_nacimiento
    FROM   bdinteg:si_ctepf
	WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_estado_civil)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "207	";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_tp_casa)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "208";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_sexo)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "209";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_nacimiento)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "210";
		END IF
  	END IF
    --------------------------------------------------------
    --6.--SALARIO (2 NUMEROS):
    --------------------------------------------------------
    SELECT NVL(ingreso_mensual,0) / (SELECT valor FROM bdisolic:ss_param where secuencia = 303)
		INTO   v_salario
	FROM   bdisolic:ss_resum_scor_fin
		WHERE  empresa = pempresa
		AND num_solicitud = pnum_credito ;

	IF v_salario <= 0  OR v_salario IS NULL THEN
  		IF cod_ret = "000" THEN
	  		LET cod_ret = "211";
	  	END IF
	ELSE
        IF v_salario >= 20 THEN
            LET v_cantidad = LPAD(20,2,'0');
		ELSE
			LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
		END IF
	END IF
    --------------------------------------------------------
    --7.-ANTIGUEDAD: (2 NUMEROS)
    --------------------------------------------------------
	SELECT NVL(SUBSTR(YEAR(fecha_alta), 3, 2),'')
		INTO   v_antiguedad
	FROM   bdinteg:si_cliente
		WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF
    --------------------------------------------------------
    --9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)
    --------------------------------------------------------
	SELECT NVL(sdo_cap_insoluto,0),NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)
		INTO   v_monto_adeudo,v_mto_adeudo_venc
	FROM   bdicred:sd_maesdoshist
		WHERE  fecha = v_fechahoy
		AND empresa = pempresa
		AND num_credito = pnum_credito;

	IF v_monto_adeudo >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_monto_adeudo < 0 THEN
			LET v_mto_tot_adeudo = LPAD(0,5,'0');
		ELSE
			LET v_mto_tot_adeudo = LPAD(v_monto_adeudo::INTEGER::VARCHAR(5),5,'0');
		END IF

	END IF
    --------------------------------------------------------
    --10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_mto_adeudo_venc >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "214";
  		END IF
	ELSE
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF
    --------------------------------------------------------
    --11.-FECHA DE ULT. PAGO: (4 NUMEROS)
    --------------------------------------------------------
	SELECT MONTH(MAX(fecha_mov)) , SUBSTR(YEAR(MAX(fecha_mov)),3,2)
	INTO v_fec_ult_pago_month,v_fec_ult_pago_year
	FROM sd_movhisedocta
	WHERE empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun IN ('033','334')
		AND codigo_ref = 1
      	AND reversado <> "S";


	IF v_fec_ult_pago_month IS NULL OR v_fec_ult_pago_year IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF


    --------------------------------------------------------
    --12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)
    --------------------------------------------------------
	LET v_monto_ult_convenio =  LPAD("0",5,'0');
    --------------------------------------------------------
    --13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)
    --------------------------------------------------------
	LET v_fecha_ult_convenio =  "NDND";
    --------------------------------------------------------
    --14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)
    --------------------------------------------------------
	LET v_est_cumpl_convenio =  "-";
    --------------------------------------------------------
    --15.-NUMERO DE AVISOS: (1 LETRA)
    --------------------------------------------------------

	LET v_avisos = 0;

	SELECT COUNT(*)
		INTO v_cuantos_avisos
	FROM sd_amortiza_credito
		WHERE empresa = pempresa
		AND num_credito = pnum_credito
		AND	capital_status IN ('2','7','6');

	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos >= 5 THEN
		LET v_avisos =  "4";
	END IF;

	if v_cuantos_avisos = 0 or v_cuantos_avisos = 1 or v_cuantos_avisos = 2 then
		let v_nivel_eficiencia = "01";
        elif v_cuantos_avisos = 3 then
		let v_nivel_eficiencia = "02";
	elif v_cuantos_avisos = 4 then
		let v_nivel_eficiencia = "03";
        elif v_cuantos_avisos = 5 or v_cuantos_avisos = 6 then
		let v_nivel_eficiencia = "04";
	elif v_cuantos_avisos > 6 then
		let v_nivel_eficiencia = "05";
	end if;



    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = v_antiguedad		||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos  ;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;
    --------------------------------------------------------
    --	GENERO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	IF TRIM(v_cl_cobranza) = "" OR v_cl_cobranza IS NULL THEN
  		IF cod_ret = "000" THEN
	    	LET cod_ret = "215";
	    END IF
	END IF
END
RETURN cod_ret,v_cl_cobranza;
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".cons_cred_bpi_app(pempresa char(3),
                                     pnum_cte char(20),
                                     pmoneda char(2))
   returning char(5),char(20),char(20), char(2),char(20),char(1),char(40),char(1);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_numcte,v_cuenta, v_numtarjeta char(20);
   define v_status_tar char(1);
   define v_status_cred char(2);
   define v_nombre_prod char(40);
   define v_secuencia integer;
   DEFINE vstatus_serv CHAR(1);
   define iCont		integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cuenta      = null;
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_status_tar = ' ';
   let v_status_cred = " ";
   let v_nombre_prod = " ";
   LET vstatus_serv	= "";
   let iCont =0;
   
   -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Estados de Cuenta Electronicos
   -- Creado por:			Autor desconocido
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2014/03/24    
   -- Razón:				Se agrega parámetro de salida del status del servicio
   --						de emisión de estados de cuenta CFDI
   -- *****************************************************************************************************
   -- Obejtivo:            Mostrar mas de 1 tarjeta en bpi (VISA y PLATINO)
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2015/01/12    
   -- Razón:				Se agrega FOREACH para recorrer todas las posibles cuentas de credito de un cliente.
   --						
   -- *****************************************************************************************************

--set debug file to "/home/informix/bibiana/cons_cre_bpi.out";
--trace on;

LET v_numcte = pnum_cte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv;
      end if
   end exception;


       SET ISOLATION DIRTY READ ;
       set lock mode to wait 3;
		--Se agrega FOREACH para consultar mas de 1 tarjeta de credito.
	   FOREACH
       SELECT mc.num_credito, 
              mc.status_cred, 
              tr.num_tarjeta, tr.status_tar, 
              TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod) AS nombre_prod
        into v_cuenta, 
             v_status_cred, 
             v_numtarjeta, 
             v_status_tar, 
             v_nombre_prod
       FROM bdicred:"informix".sd_maecred mc
       join bdicred:"informix".sd_tarjeta tr on (tr.empresa = pempresa and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT','E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
       join bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
       WHERE mc.numcte = pnum_cte
	   --Se busca para saber si tiene activo el servicio de estados de cuenta CFDI
	  SELECT status_serv_elec
	  INTO vstatus_serv
	  FROM bdiedoelec:"informix".edelec_alta_serv
	  WHERE cuenta = v_cuenta;
		
		LET iCont = iCont + 1;
		IF(iCont < 10 ) THEN
			return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"") WITH RESUME;
		END IF;	
    END FOREACH;
    
	IF ( iCont = 0 ) THEN
        LET cod_ret = '101'; --- Cliente No tiene cuentas
        RETURN cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"");
    END IF  

end
end procedure;