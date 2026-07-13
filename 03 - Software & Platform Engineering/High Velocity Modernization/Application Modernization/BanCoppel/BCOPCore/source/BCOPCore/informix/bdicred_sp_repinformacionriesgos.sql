CREATE PROCEDURE "informix".sp_repinformacionriesgos()

RETURNING       CHAR(6);

DEFINE cCodret         CHAR(6);
DEFINE sql_err         Integer;
DEFINE cNombre_Archivo CHAR(100);
DEFINE cSql            CHAR(2024);
DEFINE Nom_mes         CHAR(10);
DEFINE Num_mes         INTEGER;
DEFINE Num_anio        INTEGER;
DEFINE vruta           char(30);

DEFINE vnum_credito            CHAR(25);  
DEFINE vlimite_credito         CHAR(25);
DEFINE vfecha_corte_calculada  CHAR(25);
DEFINE vfecha_limite_pago      CHAR(25);
DEFINE vsaldo                  CHAR(25);
DEFINE vpago_minimo            CHAR(25);
DEFINE vsdo_cap_insoluto       CHAR(25);        
DEFINE vsdo_capital            CHAR(25);
DEFINE vcap_tras_no_venci      CHAR(25);
DEFINE vmonto_vencido          CHAR(25);
DEFINE vmto_venc_trasp         CHAR(25);
DEFINE vpagos_entiempo         CHAR(25);
DEFINE vpagos_adicionales      CHAR(25); 
DEFINE vtasa                   CHAR(25);
DEFINE vfecha_corte 		   date;
DEFINE vfecha					DATE;

LET cCodret         = "000000";
LET sql_err         = 0;
LET cNombre_Archivo = "";
LET cSql            = "";
LET Num_anio        = 0;
LET Num_mes         = 0;
LET Nom_mes         = "";
LET vruta           = "";

LET vnum_credito            = "";
LET vlimite_credito         = "";
LET vfecha_corte_calculada  = "";
LET vfecha_limite_pago      = "";
LET vsaldo                  = "";
LET vpago_minimo            = "";
LET vsdo_cap_insoluto       = "";      
LET vsdo_capital            = "";
LET vcap_tras_no_venci      = "";
LET vmonto_vencido          = "";
LET vmto_venc_trasp         = "";
LET vpagos_entiempo         = "";
LET vpagos_adicionales      = "";
LET vtasa                   = "";
LET vfecha_corte 		    =date(1);
LET vfecha					=date(1);

BEGIN

 ON EXCEPTION SET sql_err
             LET cCodret = sql_err;
             RETURN cCodret;
  END EXCEPTION;

--SET DEBUG FILE TO "sp_repinformacionriesgos.out";
--TRACE ON;

LET Num_mes = month(today);
LET Num_anio = year(today);


IF Num_mes = 1 THEN
   LET Nom_mes = 'Enero';
END IF;
IF Num_mes = 2 THEN
   LET Nom_mes = 'Febrero';
END IF;
IF Num_mes = 3 THEN
   LET Nom_mes = 'Marzo';
END IF;
IF Num_mes = 4 THEN
   LET Nom_mes = 'Abril';
END IF;
IF Num_mes = 5 THEN
   LET Nom_mes = 'Mayo';
END IF;
IF Num_mes = 6 THEN
   LET Nom_mes = 'Junio';
END IF;
IF Num_mes = 7 THEN
   LET Nom_mes = 'Julio';
END IF;
IF Num_mes = 8 THEN
   LET Nom_mes = 'Agosto';
END IF;
IF Num_mes = 9 THEN
   LET Nom_mes = 'Septiembre';
END IF;
IF Num_mes = 10 THEN
   LET Nom_mes = 'Octubre';
END IF;
IF Num_mes = 11 THEN
   LET Nom_mes = 'Noviembre';
END IF;
IF Num_mes = 12 THEN
   LET Nom_mes = 'Diciembre';
END IF;

--asigna nombre del archivo concatenando mes y año 
LET  cNombre_Archivo= 'Seguimiento_riesgos' || trim(Nom_mes) || Num_anio || '.txt';

  SELECT TRIM(valor) 
    INTO vruta 
    FROM bdicred:sd_param 
   WHERE empresa = '001'
     AND cod_param = '49';

Set isolation to dirty read;
SET LOCK MODE TO WAIT 3;
	
--valida que no exista la tabla a crear
	IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_repinformacionriesgos' ) THEN
		IF not exists (select fecha_corte from  temp_repinformacionriesgos where month(fecha_corte) = month(today)) THEN
			DROP TABLE temp_repinformacionriesgos;
		END IF;    
	END IF;
	
	IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_repinformacionriesgos' ) THEN
		CREATE TABLE  temp_repinformacionriesgos      
		(num_credito            CHAR(25),  
		limite_credito         CHAR(25),
		fecha_corte_calculada  CHAR(25),
		fecha_limite_pago      CHAR(25),
		saldo                  CHAR(25),
		pago_minimo            CHAR(25),
		sdo_cap_insoluto       CHAR(25),        
		sdo_capital            CHAR(25),
		cap_tras_no_venci      CHAR(25),
		monto_vencido          CHAR(25),
		mto_venc_trasp         CHAR(25),
		pagos_entiempo         CHAR(25),
		pagos_adicionales      CHAR(25),  
		tasa                   CHAR(25), fecha_corte date 
		); 
	END IF;
  
	-----------------------------------------------------poner today
	--let vfecha = mdy(month(mdy(month('04-20-2012'),'01',year('04-20-2012')) - 1),'20',year(mdy(month('04-20-2012'),'01',year('04-20-2012')) - 1));

FOREACH WITH HOLD

	SELECT a.num_credito,  ROUND(monto_otorgado) limite_credito,
    YEAR(fecha + 1 units month)||LPAD(MONTH(fecha + 1 units month),2,0)|| LPAD(DAY(fecha + 1 units month),2,0) fecha_corte_calculada, -- 20 Junio
    YEAR(fecha + 1 units month)||LPAD((MONTH(fecha + 1 UNITS MONTH)),2,0)||16 fecha_limite_pago, -- 16 Junio
    ROUND(sdo_cap_insoluto) saldo, -- 20 Mayo
    case when sdo_cap_insoluto < sdo_trab4 and sdo_cap_insoluto >= 0 then ROUND(sdo_cap_insoluto) else
    (case when ROUND(sdo_trab4) < 0 then 0 else ROUND(sdo_trab4) end) end pago_minimo, -- 20 Mayo
    sdo_cap_insoluto, sdo_capital, cap_tras_no_venci, monto_vencido, mto_venc_trasp,
	round((SELECT nvl(SUM(monto),0)
                 FROM bdicred:sd_movhis
                WHERE a.empresa = empresa
                  AND a.num_credito = num_credito
                  AND fecha_mov BETWEEN date(fecha + 1) AND date(fecha + 1 units month) - 4
                  AND codigo_fun IN ('033','334','335','336','337')
                  AND codigo_ref= 1
                  AND reversado = 'N')) Pagos_entiempo, -- 21 mayo - 16 junio
              round((SELECT nvl(SUM(monto),0)
                 FROM bdicred:sd_movhis
                WHERE a.empresa = empresa
                  AND a.num_credito = num_credito
                  AND fecha_mov BETWEEN date(fecha + 1 units month) - 3 AND date(fecha + 1 units month)
                  AND codigo_fun IN ('033','334','335','336','337')
                  AND codigo_ref= 1
                  AND reversado = 'N')) Pagos_adicionales, -- 17 junio - 20 junio
    case when fecha <= mdy('06','20','2008') then '54.00' else '59.23' end tasa
	INTO vnum_credito,vlimite_credito,vfecha_corte_calculada,vfecha_limite_pago,vsaldo,vpago_minimo,vsdo_cap_insoluto,
	vsdo_capital,vcap_tras_no_venci, vmonto_vencido,vmto_venc_trasp,vpagos_entiempo,vpagos_adicionales,vtasa
    FROM bdicred:sd_maecred b,    bdicred:sd_maesdoshist a
    WHERE fecha = mdy(month(mdy(month(today),'01',year(today)) - 1),'20',year(mdy(month(today),'01',year(today)) - 1))
        AND b.empresa = a.empresa
        AND b.num_credito = a.num_credito
		and a.num_credito not in (select num_credito from temp_repinformacionriesgos)
		
	--carga informacion en la tabla
	begin work;
		INSERT INTO  temp_repinformacionriesgos
		VALUES(vnum_credito,vlimite_credito,vfecha_corte_calculada,vfecha_limite_pago,vsaldo,vpago_minimo,vsdo_cap_insoluto,
		vsdo_capital,vcap_tras_no_venci, vmonto_vencido,vmto_venc_trasp,vpagos_entiempo,vpagos_adicionales,vtasa,today);
	commit work;
END FOREACH;
--Se genera archivo con la informacion del reporte 

LET cSql = '';
LET cSql = 'echo "UNLOAD TO ' || trim(vruta) || 'ReporteRiesgosRegistros.unl' || ' DELIMITER ' || '''|'''|| 
           ' select num_credito,limite_credito,fecha_corte_calculada,fecha_limite_pago,saldo,pago_minimo,sdo_cap_insoluto,'|| 
		   ' sdo_capital,cap_tras_no_venci, monto_vencido,mto_venc_trasp,pagos_entiempo,pagos_adicionales,tasa'||
		   ' from bdicred:temp_repinformacionriesgos;'|| 
           ' " > '|| trim(vruta) || 'ReporteInformacionRegistros.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicred ' || trim(vruta) || 'ReporteInformacionRegistros.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'ReporteRiesgosRegistros.unl' || " > " || trim(vruta) || cNombre_Archivo;
SYSTEM cSql;
     
LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'ReporteInformacionRegistros.sql ' || trim(vruta) || 'ReporteRiesgosRegistros.unl';
SYSTEM cSql;
         
RETURN cCodret;

DROP TABLE  temp_repinformacionriesgos;  
END
END PROCEDURE
DOCUMENT
'Realiza un reporte de facturacion del periodo del 21 al 20 del mes en que se ejecuta ',
'FECHA : 22/01/2009',
'BD : bdicred ';

CREATE PROCEDURE "informix".encabezado_edocta(pEmpresa CHAR(3), pTarjeta CHAR(20), pFechaEmision char(10))
	RETURNING CHAR(5), DATE, CHAR(20), CHAR(20), CHAR(20),
			  CHAR(150), CHAR(200), CHAR(120), CHAR(120), CHAR(120),
			  CHAR(120), CHAR(150), CHAR(20), DATE, CHAR(5),
			  CHAR(60), CHAR(13), CHAR(47), CHAR(40), CHAR(80);
	
	--****************************************************--
	-- MODIFICADO: J. Rodolfo Uriarte R.				**--
	--		FECHA: 24 de Diciembre de 2008				**--
	-- MODIFICACION: Se aumento la longitud del regreso	**--
	--				 de la variable v_cl_cobra			**--
	--				 de 51 a 60							**--
	--****************************************************--
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	DEFINE sql_err				SMALLINT;
	DEFINE sCodRet				CHAR(5);
	DEFINE v_fecha_emision		DATE ;
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_num_tarjeta		CHAR(20); 
	DEFINE v_nombre_cte			CHAR(150);
	DEFINE v_direccion_cn		CHAR(200);
	DEFINE v_direccion_col		CHAR(120);
	DEFINE v_direccion_del		CHAR(120);
	DEFINE v_edo_cd 			CHAR(120);
	DEFINE v_sucursal_nombre	CHAR(120);
	DEFINE v_sucursal_gerente	CHAR(150);
	DEFINE v_sucursal_tel		CHAR(20);
	DEFINE v_fecha_corte		DATE;
	DEFINE v_cp					CHAR(5);
	DEFINE v_cl_cobra			CHAR(63);
	DEFINE v_rfc				CHAR(13);
	DEFINE v_ruta				CHAR(47);
	DEFINE v_entre_calles		CHAR(40);
	DEFINE v_observaciones		CHAR(80);
	--jom ini
	DEFINE vValor				CHAR(1);
	DEFINE vaniovalido			CHAR(4);
	DEFINE vmesvalido			CHAR(2);
	--jom fin
	
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	LET sql_err				= 0;
	LET sCodRet				= '000';
	LET v_fecha_emision		= "";
	LET v_num_credito		= "";
	LET v_numcte			= "";
	LET v_num_tarjeta		= "";
	LET v_nombre_cte		= "";
	LET v_direccion_cn		= "";
	LET v_direccion_col		= "";
	LET v_direccion_del		= "";
	LET v_edo_cd			= "";
	LET v_sucursal_nombre	= "";
	LET v_sucursal_gerente	= "";
	LET v_sucursal_tel		= "";
	LET v_fecha_corte		= "";
	LET v_cp				= "";
	LET v_cl_cobra			= "";
	LET v_rfc				= "";
	LET v_ruta				= "";
	LET v_entre_calles		= "";
	LET v_observaciones		= "";
	--jom ini
	LET vValor				= "";
	LET vaniovalido			= "";
	LET vmesvalido			= "";
	--jom fin
	
	--SET DEBUG FILE TO "encabezado_edocta.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			LET sCodRet = sql_err;
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END EXCEPTION;
		
		
		-------------------------------------------------------------
		--VALIDACION DE TARJETA
		-------------------------------------------------------------
		SELECT num_credito INTO v_num_credito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T'; --AND status_tar = "A"; -- JOM INI
	
		LET pTarjeta= pTarjeta;
		
		IF v_num_credito IS NULL THEN
			LET sCodRet = "186";
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;
		
		-- Mostrar edo. de cuenta si/no  ini
		
		SELECT SUBSTR(valor, 1, 1), SUBSTR(valor, 2, 4), SUBSTR(valor, 6, 2)
		INTO vValor, vaniovalido, vmesvalido  
		FROM bdicred:sd_param WHERE cod_param = '80';
		
		IF (vValor = "1" AND vaniovalido = LPAD(YEAR(pFechaEmision), 4, '0') AND vmesvalido = LPAD(MONTH(pFechaEmision), 2, '0')) THEN
			LET sCodRet = "185";
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;
		
		-- Mostrar edo. de cuenta si/no  fin
		
		-------------------------------------------------------------
		--GENERACION ENCABEZADO EDO CUENTA
		-------------------------------------------------------------
		SELECT
			fecha_emision, num_credito, numcte, num_tarjeta, nombre_cte,
			direccion_cn, direccion_col, direccion_del, edo_cd, sucursal_nombre,
			sucursal_gerente, sucursal_tel, fecha_corte, cp, NVL(cl_cobra,cl_cobra_prev),
			rfc, ruta, entre_calles, observaciones
		INTO
			v_fecha_emision, v_num_credito, v_numcte, v_num_tarjeta, v_nombre_cte,
			v_direccion_cn, v_direccion_col, v_direccion_del, v_edo_cd, v_sucursal_nombre,
			v_sucursal_gerente, v_sucursal_tel, v_fecha_corte, v_cp, v_cl_cobra,
			v_rfc, v_ruta, v_entre_calles, v_observaciones
		 FROM bdicred@pld_tcp:sd_encabezado_edocta
        WHERE fecha_emision = pFechaEmision AND num_credito = v_num_credito;
--		 WHERE fecha_emision = pFechaEmision AND num_tarjeta = pTarjeta; -- JOM INI
		
        let v_num_tarjeta = pTarjeta;

		IF v_num_credito IS NULL THEN
			LET sCodRet = "185";
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;
		
		RETURN sCodRet, NVL(v_fecha_emision,''), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
			   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
			   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,''), NVL(v_cp, ""),
			   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
	END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".encabezado_edocta_sif(pEmpresa CHAR(3), pTarjeta CHAR(20), pFechaEmision char(10))
	RETURNING CHAR(5), DATE, CHAR(20), CHAR(20), CHAR(20),
			  CHAR(150), CHAR(200), CHAR(120), CHAR(120), CHAR(120),
			  CHAR(120), CHAR(150), CHAR(20), DATE, CHAR(5),
			  CHAR(60), CHAR(13), CHAR(47), CHAR(40), CHAR(80);
	
	--****************************************************--
	-- MODIFICADO: J. Rodolfo Uriarte R.		     **--
	--		FECHA: 24 de Diciembre de 2008	     **--
	-- MODIFICACION: Se aumento la longitud del regreso  **--
	--				 de la variable v_cl_cobra **--
	--				 de 51 a 60		**--
	--****************************************************--
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	DEFINE sql_err				SMALLINT;
	DEFINE sCodRet				CHAR(5);
	DEFINE v_fecha_emision		DATE ;
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_num_tarjeta		CHAR(20); 
	DEFINE v_nombre_cte			CHAR(150);
	DEFINE v_direccion_cn		CHAR(200);
	DEFINE v_direccion_col		CHAR(120);
	DEFINE v_direccion_del		CHAR(120);
	DEFINE v_edo_cd 			CHAR(120);
	DEFINE v_sucursal_nombre	CHAR(120);
	DEFINE v_sucursal_gerente	CHAR(150);
	DEFINE v_sucursal_tel		CHAR(20);
	DEFINE v_fecha_corte		DATE;
	DEFINE v_cp					CHAR(5);
	DEFINE v_cl_cobra			CHAR(63);
	DEFINE v_rfc				CHAR(13);
	DEFINE v_ruta				CHAR(47);
	DEFINE v_entre_calles		CHAR(40);
	DEFINE v_observaciones		CHAR(80);
	--jom ini
	DEFINE vValor				CHAR(1);
	DEFINE vaniovalido			CHAR(4);
	DEFINE vmesvalido			CHAR(2);
	--jom fin
	
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
	LET sql_err				= 0;
	LET sCodRet				= '000';
	LET v_fecha_emision		= "";
	LET v_num_credito		= "";
	LET v_numcte			= "";
	LET v_num_tarjeta		= "";
	LET v_nombre_cte		= "";
	LET v_direccion_cn		= "";
	LET v_direccion_col		= "";
	LET v_direccion_del		= "";
	LET v_edo_cd			= "";
	LET v_sucursal_nombre	= "";
	LET v_sucursal_gerente	= "";
	LET v_sucursal_tel		= "";
	LET v_fecha_corte		= "";
	LET v_cp				= "";
	LET v_cl_cobra			= "";
	LET v_rfc				= "";
	LET v_ruta				= "";
	LET v_entre_calles		= "";
	LET v_observaciones		= "";
	--jom ini
	LET vValor				= "";
	LET vaniovalido			= "";
	LET vmesvalido			= "";
	--jom fin
	
	--SET DEBUG FILE TO "encabezado_edocta.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			LET sCodRet = sql_err;
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END EXCEPTION;
		
		
		-------------------------------------------------------------
		--VALIDACION DE TARJETA
		-------------------------------------------------------------
		SELECT num_credito INTO v_num_credito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T'; --AND status_tar = "A"; -- JOM INI
	
		LET pTarjeta= pTarjeta;
		
		IF v_num_credito IS NULL THEN
			LET sCodRet = "186";
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;
		
		-- Mostrar edo. de cuenta si/no  ini
		
		SELECT SUBSTR(valor, 1, 1), SUBSTR(valor, 2, 4), SUBSTR(valor, 6, 2)
		INTO vValor, vaniovalido, vmesvalido  
		FROM bdicred:sd_param WHERE cod_param = '80';
		
		IF (vValor = "1" AND vaniovalido = LPAD(YEAR(pFechaEmision), 4, '0') AND vmesvalido = LPAD(MONTH(pFechaEmision), 2, '0')) THEN
			LET sCodRet = "185";
			
			RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
				   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
				   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
				   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
		END IF;
		
		-- Mostrar edo. de cuenta si/no  fin
		
		-------------------------------------------------------------
		--GENERACION ENCABEZADO EDO CUENTA
		-------------------------------------------------------------
		IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = v_num_credito and fecha_corte = pFechaEmision)
			THEN
				SELECT
					fecha_emision, num_credito, numcte, num_tarjeta, nombre_cte,
					direccion_cn, direccion_col, direccion_del, edo_cd, sucursal_nombre,
					sucursal_gerente, sucursal_tel, fecha_corte, cp, NVL(cl_cobra,''),
					rfc, ruta, entre_calles, observaciones
				INTO
					v_fecha_emision, v_num_credito, v_numcte, v_num_tarjeta, v_nombre_cte,
					v_direccion_cn, v_direccion_col, v_direccion_del, v_edo_cd, v_sucursal_nombre,
					v_sucursal_gerente, v_sucursal_tel, v_fecha_corte, v_cp, v_cl_cobra,
					v_rfc, v_ruta, v_entre_calles, v_observaciones
				 FROM sd_encabezado_edocta
				WHERE fecha_emision = pFechaEmision AND num_credito = v_num_credito;
		--		 WHERE fecha_emision = pFechaEmision AND num_tarjeta = pTarjeta; -- JOM INI
				
				let v_num_tarjeta = pTarjeta;

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
					
					RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
						   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
						   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
						   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
				END IF;
			ELSE
				SELECT
					fecha_emision, num_credito, numcte, num_tarjeta, nombre_cte,
					direccion_cn, direccion_col, direccion_del, edo_cd, sucursal_nombre,
					sucursal_gerente, sucursal_tel, fecha_corte, cp, NVL(cl_cobra,cl_cobra_prev),
					rfc, ruta, entre_calles, observaciones
				INTO
					v_fecha_emision, v_num_credito, v_numcte, v_num_tarjeta, v_nombre_cte,
					v_direccion_cn, v_direccion_col, v_direccion_del, v_edo_cd, v_sucursal_nombre,
					v_sucursal_gerente, v_sucursal_tel, v_fecha_corte, v_cp, v_cl_cobra,
					v_rfc, v_ruta, v_entre_calles, v_observaciones
				 FROM bdicred@pld_tcp:sd_encabezado_edocta
				WHERE fecha_emision = pFechaEmision AND num_credito = v_num_credito;
		--		 WHERE fecha_emision = pFechaEmision AND num_tarjeta = pTarjeta; -- JOM INI
				
				let v_num_tarjeta = pTarjeta;

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
					
					RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
						   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
						   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,date(1)), NVL(v_cp, ""),
						   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
				END IF;
		END IF;
		
		RETURN sCodRet, NVL(v_fecha_emision,''), NVL(v_num_credito, ""), NVL(v_numcte, ""), NVL(v_num_tarjeta, ""),
			   NVL(v_nombre_cte, ""), NVL(v_direccion_cn, ""), NVL(v_direccion_col, ""), NVL(v_direccion_del, ""), NVL(v_edo_cd, ""),
			   NVL(v_sucursal_nombre, ""), NVL(v_sucursal_gerente, ""), NVL(v_sucursal_tel, ""), NVL(v_fecha_corte,''), NVL(v_cp, ""),
			   NVL(v_cl_cobra, ""), NVL(v_rfc, ""), NVL(v_ruta, ""), NVL(v_entre_calles, ""), NVL(v_observaciones, "");
	END;
END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_rep_cartera_quebrantar_crd(pEmpresa char(3))
returning char(06) AS resultado,
          char(80) AS mensaje;

DEFINE cMensajeRet  CHAR(80);
DEFINE cSucursal, cUltMov, cNumSucursal, cNumproducto char(4);
DEFINE cNumCredito, cNumCte, cNumCredito_rees, cApellido1,cApellido2,cNombre1,cNombre2,cCurp, cNumTarjeta, cRefCoppel char(20);
DEFINE pPagos, pNum_Vencidos, cdiacorte Smallint;
DEFINE cRfc, cTelefono, cTelTrab, cExtTrab char(13);
DEFINE cApellidoCasada          char(26);
DEFINE cSector,cEdoCivil        char(2);
DEFINE dFechaNac                date;
DEFINE cSexo                    char(1);
DEFINE cNumIdentificacion       char(30);
DEFINE cEmail                   char(60);
DEFINE cTipoIdentificacion      char(40);
DEFINE cNacionalidad            char(15);
DEFINE cNumEstado,cNumCiudad integer;
DEFINE cPoblacion, cComplemento,cDescripcion, cDescripPermTrabajo char(80);
DEFINE cNumColonia, cNumCalle integer;
DEFINE cNumExterior, cNumInterior char(10);
DEFINE cCodPostal, cCodPostalTrab char(5);
DEFINE cPuntoCardinal           char(1);
DEFINE iManzana, iandador, iEtapa, iLote, iEdificio, iEntrada, iManzanaTrab, iandadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab, iEntradaTrab, iContadorRegistros integer;
DEFINE cDepartamento, cDepartamentoTrab char(6);
DEFINE cEntreCalles, cEntreCallesTrab char(40);
DEFINE sOtros, sElementoRes, sElemResTrabajo, iOtrosTrab, sCausa, iContador, sNumVencidos smallint;
DEFINE mIngresoMensual          money(14,2);
DEFINE cPuesto                  char(3);
DEFINE cLugarTrabajo            char(25);
DEFINE cActividad         char(45);
---Domicilio de Trabajo
DEFINE cNumEstadoTrab, cNumCiudadTrab, cNumColoniaTrab, cNumCalleTrab integer;
DEFINE cPoblacionTrab, cComplementoTrab  char(80);
DEFINE cNumExteriorTrab, cNumInteriorTrab char(10);
DEFINE cPuntoCardinalTrab,cSituacion, cEvaluacionCC,cBegin char(1);
------- PENDIENTES DE GENERAR
DEFINE cExisteCC                char(2);
-----
DEFINE dFechaMovtoSit, dFechaUltPago, dFechaHoy, dFechaCapAux, dFechaUltDisp, dFechaUltMov date;
DEFINE iMaxSecDisp, iCuantosDisp, iRef, cMesesVencidos, iCuantosPagos Integer;
DEFINE fIntenPago, fIntenPago_pres, fMontoUltDisp, fMontoComi, fAbonoMensual, fSaldoMesAnt, mMonto, mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual decimal(14,2);
DEFINE cFolioSuc                char(16);
DEFINE fMontoUltMov, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fMontoPago decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE cNombreArchivo1, cNombreArchivo2	CHAR(50);
-- jom ini
define cNumRegTotal_TC, cNumRegTotal_Rees, cNumRegTotal_Pres, cMesesHistoria integer;
define sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado, mIvaIntMoraTotal, pMonto_otorgado decimal(14,2);
define sFechadeCorte, cFechaApertura, fecha_mesant, dfechapridiames, dfechaultdiames date;
-- jom fin
define var_rga                char(05);
define Ccodcaract             char(03);
DEFINE cTelefonoCel           char(13);
DEFINE cSituacionPago         decimal(5,2);
DEFINE cEvaluacc              char(01);
DEFINE vmonto50, vmonto4meses,vsdo_cap_insoluto decimal(18,2);
DEFINE existe, utili_80, motivoexclusion  smallint;
DEFINE dFechaAlta date;
DEFINE cStatusCred          CHAR(02);
DEFINE dSdoCapital decimal(18,2);
DEFINE dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra decimal(18,2);
DEFINE dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra date;
let fAbonoMensual = 0;
--SET DEBUG FILE TO '/resplogifx/archivoscartera/leo/sp_rep_cartera_quebrantar.out';
--TRACE ON;
BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        IF  cNumProducto = '6001' then
            LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito;
            RETURN P_COD_RET,cMensajeRet;
        ELSE
            LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito_rees;
            RETURN P_COD_RET,cMensajeRet;
        END IF;
        IF cBegin = 'S' then
            RollBack WORK;
		END IF;
    END EXCEPTION;

LET cBegin = 'N';
LET cMensajeRet  = '' ;
LET cNumProducto, cNumCredito, cNumCte, cNumCredito_rees, cNumTarjeta, cRefCoppel = '', '', '', '', '','';
LET cApellido1,cApellido2,cNombre1,cNombre2,cCurp = '','','','','';
--jom ini
LET cNumRegTotal_TC, sSaldoActTotal_TC , cNumRegTotal_Rees, sSaldoActTotal_Rees, cNumRegTotal_Pres, sSaldoActTotal_Pres = 0, 0, 0, 0, 0 ,0 ; 
--jom fin
LET cNumSucursal, P_COD_RET = '0000', '000000';
LET pNum_Vencidos, fIntenPago, fIntenPago_pres, cdiacorte, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fSaldoMesVencido = 0,0,0,0,0,0,0,0,0,0,0,0;
LET sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado,mIvaIntMoraTotal, pMonto_otorgado = 0,0,0,0,0,0,0,0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET Ccodcaract, cSituacion = '', '';
LET iContador,sCausa,sNumVencidos  = 0, 0, 0;
LET vmonto50, vmonto4meses,vsdo_cap_insoluto = 0.00, 0.00, 0.00;
LET existe, utili_80, motivoexclusion,dSdoCapital  = 0, 0, 0, 0;
LET dFechaAlta = date(1);
let dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra =0,0,0;
let dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra, dFechaUltDisp = date(1),date(1),date(1),date(1);

	SELECT Fecha_Hoy, pri_dia_mes, ult_dia_mes
    INTO dFechaHoy, dfechapridiames, dfechaultdiames
    FROM bdicred:sd_fechas
    WHERE empresa = '001';

LET cNombreArchivo1= '/pisa/CarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';
LET cNombreArchivo2= '/pisa/CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';


    BEGIN WORK;
       LET cBegin = 'S';
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar_cifras WHERE fechareporte = date(CURRENT) and num_producto in ('6300','6011');
    COMMIT WORK;

	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar_cifras;
    BEGIN WORK;
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar WHERE fechareporte = date(CURRENT) and producto in ('6300','6011');
    COMMIT WORK;
	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar;
    BEGIN WORK;
       DELETE FROM bdicred:sd_exclusiones_ventacartera WHERE fecha_exclusion = date(CURRENT) and  num_producto in ('6300','6011');
    COMMIT WORK;
    UPDATE statistics medium FOR table bdicred:sd_exclusiones_ventacartera;
    LET cBegin = 'N';

    /*SELECT a.num_producto, a.num_credito, a.numcte, cod_caract_2,
    NVL((SELECT SUM(monto)
    FROM bdicred:sd_movhis
    WHERE empresa = '001'
      AND a.num_credito = num_credito
      AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
      AND codigo_ref = 1
      AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 1 units MONTH)
      AND reversado = 'N'),0) monto50,
    NVL((SELECT SUM(monto)
    FROM bdicred:sd_movhis
    WHERE empresa = '001'
      AND a.num_credito = num_credito
      AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
      AND codigo_ref = 1
      AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 4 units MONTH)
      AND reversado = 'N'),0) monto4meses
      ,b.mto_fin_ven_trasp, b.monto_otorgado,
      sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, 20 dia_corte, sdo_cap_insoluto 
    FROM bdicred:sd_maecred a, bdicred:sd_maesdos b
    WHERE a.empresa= '001'
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
	  AND mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
      AND status_cred = 'BT'
      AND NVL(Cod_caract_2,'') = ''
      AND sdo_cap_insoluto >= 1000
    INTO temp selec_credito WITH NO LOG;*/

-- agregan a la venta los clientes conflicto
/*
    INSERT INTO selec_credito
    SELECT  a.num_producto, a.num_credito, numcte, cod_caract_2,0 ,0 ,mto_fin_ven_trasp, b.monto_otorgado,
      sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
    FROM bdicred:sd_maecred a,
         bdicred:sd_maesdos b,
         bdicred:sd_maecredanexo c
    WHERE a.empresa = '001'
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
      AND a.empresa = c.empresa
      AND a.num_credito = c.num_credito
      AND a.status_cred = 'BT'
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '062')
      AND b.mto_fin_ven_trasp < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
      AND c.fecha_ult_pago is null
      AND sdo_cap_insoluto >= 1000
      AND a.num_credito not IN (SELECT num_credito FROM selec_credito);*/

   --INSERT INTO selec_credito
   SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen cod_caract_2,0 monto50,0 monto4meses,b.mto_fin_ven_trasp, b.monto_otorgado,
          sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
     FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
    WHERE a.empresa = '001'
	  AND a.empresa = b.empresa
	  AND a.num_producto = '6011'
	  AND a.num_credito = b.num_credito
	  AND a.empresa = c.empresa
	  AND a.num_credito = c.num_credito
      AND a.status_cred in ('BT','VP')
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '061')
      AND sdo_cap_insoluto >= 1000
	  --AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	  INTO temp selec_credito WITH NO LOG;

   INSERT INTO selec_credito
   SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
          sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
     FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
    WHERE a.empresa = '001'
	  AND a.empresa = b.empresa
	  AND a.num_producto = '6300'
	  AND a.num_credito = b.num_credito
	  AND a.empresa = c.empresa
	  AND a.num_credito = c.num_credito
      AND a.status_cred = 'BT'
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060') 
	  AND sdo_cap_insoluto >= 1000
	  AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	  AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);

--crea indices
    create index inx_selec_credito on selec_credito(num_credito);
    create index inx_selec_credito2 on selec_credito(numcte);
--actualiza estadisticas
    UPDATE statistics high FOR table selec_credito;
	
--Agregar a tabla sd_exclusiones_vtacartera creditos a excluir
--convenios
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'01' as motivoexclusion from selec_credito a
	inner join bdicobranza:cb_compac b on(b.numcuenta = a.num_credito and (b.fecha_compac + (b.plazo*7)) >= dFechaHoy)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
  	  AND a.mto_fin_ven_trasp < 13;
	
	DELETE FROM selec_credito WHERE num_credito IN (SELECT numcuenta  FROM bdicobranza:cb_compac  WHERE (fecha_compac + (plazo*7)) >=dFechaHoy)
								AND mto_fin_ven_trasp < 13;
--defunciones
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'02' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcte b on(b.numcte = a.numcte and b.situacion = 'F' and b.causa = 42)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT)and num_credito = a.num_credito);
	
    DELETE FROM selec_credito WHERE numcte IN (SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE situacion = 'F' AND causa = 42);
--prospectos reestructuras
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)  
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'03' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 35 )
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
      AND a.mto_fin_ven_trasp < 13;
	
    DELETE FROM selec_credito WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 35)
								AND mto_fin_ven_trasp < 13;*/
--clientes testigo
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)    
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'04' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 60)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
     AND a.mto_fin_ven_trasp < 13;
    DELETE FROM selec_credito WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 60)
				AND mto_fin_ven_trasp < 13;
*/				
--clientes prueba grupo3
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)      
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'05' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 61)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
      AND a.mto_fin_ven_trasp < 13;
DELETE FROM selec_credito WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 61)
								AND mto_fin_ven_trasp < 13;*/
--aclaraciones en proceso
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)           
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'06' as motivoexclusion 
	from selec_credito a
	where a.num_credito in
	(SELECT pro.numero_cuenta
          FROM bdiaclaracion:acl_aclaracion  acl,
                bdiaclaracion:acl_tipo_evento eve,
                bdiaclaracion:acl_producto pro,
                bdiaclaracion:acl_movimiento mov
            WHERE acl.fky_tipo_evento = eve.pky_tipo_evento
            AND pro.pky_producto = acl.fky_producto
            AND acl.pky_aclaracion = mov.fky_aclaracion
            AND  acl.fky_estatus_aclaracion = 2)
  	        AND a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
--    AND mto_fin_ven_trasp < 13;
--rss  poner copy
      DELETE FROM selec_credito WHERE num_credito IN
         (SELECT pro.numero_cuenta
          FROM bdiaclaracion:acl_aclaracion  acl,
                bdiaclaracion:acl_tipo_evento eve,
                bdiaclaracion:acl_producto pro,
                bdiaclaracion:acl_movimiento mov
            WHERE acl.fky_tipo_evento = eve.pky_tipo_evento
            AND pro.pky_producto = acl.fky_producto
            AND acl.pky_aclaracion = mov.fky_aclaracion
            AND  acl.fky_estatus_aclaracion = 2);
--            AND mto_fin_ven_trasp < 13;
--======================
--clientes con email
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)        
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'07' as motivoexclusion 
    from selec_credito a
	left outer join bdinteg:si_correos b on(b.empresa = '001' and b.numcte = a.numcte and b.status_correo = 'A' 
                                            and secuencia = (select max(secuencia) from bdinteg:si_correos cor
                                                              where cor.empresa= b.empresa and cor.numcte = b.numcte  
                                                                and b.status_correo = 'A' ))
	where a.num_producto = '6300'
	and a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
    AND a.mto_fin_ven_trasp < 13;
--elimina clientes con email
    DELETE FROM selec_credito
      WHERE numcte IN (SELECT numcte FROM bdinteg:si_correos WHERE numcte IN (SELECT numcte FROM selec_credito WHERE num_producto = '6300') AND status_correo= 'A' )
                                AND mto_fin_ven_trasp < 13;*/

	select a.num_credito
      from selec_credito a,
	       bdinteg:si_huella_temp b
     where b.numcte = a.numcte
       and b.fecha_alta >= bdicred:monthadd(mdy(month(dFechaHoy),1,year(dFechaHoy)), case when dia_corte > day(dFechaHoy) then mto_fin_ven_trasp::integer + 1 * -1 else mto_fin_ven_trasp::integer * -1 end) 
       and b.fecha_alta <= bdicred:monthadd(mdy(month(dFechaHoy),1,year(dFechaHoy)), case when dia_corte > day(dFechaHoy) then mto_fin_ven_trasp::integer * -1 else mto_fin_ven_trasp::integer - 1 * -1 end) 
       and status = 'M'
     group by 1
     into temp posible_fraude with no log;

    create index idxtemp_credito on posible_fraude(num_credito);
    update statistics high for table posible_fraude;

--clientes fraude huella
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)    
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'04' as motivoexclusion from selec_credito a
	where a.num_credito in (select num_credito from posible_fraude);

    DELETE FROM selec_credito WHERE num_credito IN (select num_credito from posible_fraude);
    
    --programa apoyo
	  insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	  select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'14' as motivoexclusion from selec_credito a
	  inner join bdicred:sd_sucursal_excluye  b on (b.sucursal = a.sucursal)
    where num_producto in ('6300','6001');
	
	DELETE FROM selec_credito 
	  WHERE num_credito IN (select a.num_credito from selec_credito a
							inner join bdicred:sd_sucursal_excluye  b on (b.sucursal = a.sucursal)
							where num_producto in ('6300','6001'));
	  
    SELECT cod_fun 
     FROM bdicred:sd_conceptospagomanualcrd 
    WHERE num_producto = '6300'
    group by 1
    into temp paso_pres;
    create unique index inx_paso_pres on paso_pres(cod_fun);
    update statistics high for table paso_pres;

    set isolation to dirty read;
    SELECT cod_fun 
     FROM bdicred:sd_conceptospagomanualcrd 
    WHERE num_producto = '6011'
    group by 1
    into temp paso_rees;
    create unique index inx_paso_rees on paso_rees(cod_fun);
    update statistics high for table paso_rees;

-- Seleccion de movimientos, historico CRD
    SELECT a.num_credito, codigo_fun, codigo_ref, fecha_mov, monto
    FROM bdicred:sd_movhiscrd a, selec_credito b
    WHERE a.empresa = '001'
    AND a.num_credito = b.num_credito
    AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd ) 
    AND codigo_ref = 1
    AND reversado = 'N'
    into temp movcrd with no log;

    insert into movcrd
    SELECT a.num_credito, codigo_fun, codigo_ref, max(fecha_mov), 0
    FROM bdicred:sd_movhiscrd a, selec_credito b
    WHERE a.empresa = '001'
    AND a.num_credito = b.num_credito
    AND codigo_fun = '602'
    AND codigo_ref = 2
    AND reversado = 'N'
    group by 1,2,3;
 
    insert into movcrd
    SELECT a.num_credito, codigo_fun, codigo_ref, max(fecha_mov), 0
    FROM bdicred:sd_movhiscrd a, selec_credito b
    WHERE a.empresa = '001'
    AND a.num_credito = b.num_credito
    AND codigo_fun = '026'
    AND codigo_ref = 3
    AND reversado = 'N'
    group by 1,2,3;

    create index inx_movcrdvta on movcrd(num_credito,codigo_fun,codigo_ref,fecha_mov);

	FOREACH WITH hold
	SELECT num_producto, num_credito, numcte, cod_caract_2, monto50, monto4meses, mto_fin_ven_trasp, monto_otorgado,
           sucursal, fecha_apertura, status_cred, nvl(dia_corte,0), sdo_cap_insoluto
	INTO   cNumProducto, cNumCredito, cNumCte, Ccodcaract, vmonto50, vmonto4meses, pNum_Vencidos, pMonto_otorgado,
           cNumSucursal, cFechaApertura, cStatusCred, cdiacorte, vsdo_cap_insoluto
	FROM selec_credito 

	LET cNumCredito_rees = cNumCredito;
	
	/*IF  cNumProducto = '6001' then
		if (vmonto50 > 50) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '10');
				continue FOREACH;
		end if;
		
		if (vmonto4meses > round((vsdo_cap_insoluto *.20),2)) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '11');
    			continue FOREACH;
		end if;

	ELSE

		IF  cNumProducto = '6011' then
            

            LET fecha_mesant = dfechapridiames - 1;
			LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
					
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			  AND fecha_mov < MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy))
			  AND num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_rees) 
			  AND codigo_ref = 1;
			
			SELECT capital_mto_cuota
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd a
			WHERE a.empresa   = pEmpresa
			AND a.num_credito = cNumCredito_rees
			AND a.fecha_cuota = (SELECT min(fecha_cuota)
								  FROM bdicred:sd_amortiza_creditocrd
								 WHERE empresa  = pEmpresa
								   AND num_credito = cNumCredito_rees
								   AND capital_status IN ("2","7"));
			
			IF fIntenPago >= (fAbonoMensual * .5) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '08');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;

		ELIF  cNumProducto = '6300' then

			LET cNumCredito_rees = cNumCredito;
		    LET fecha_mesant = dfechapridiames - 1;
			
--- BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

			IF cdiacorte > DAY(fecha_mesant) then
			   LET fecha_mesant = MDY(MONTH(fecha_mesant),DAY(fecha_mesant),YEAR(fecha_mesant));
			ELSE
			   LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
			END IF;
			
			IF cdiacorte > DAY(dfechaultdiames) then
			   LET cdiacorte = DAY(dfechaultdiames);
			END IF;
			
--- BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMIO DE ESTA VARIABLE SI ES NECESARIO
			
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			  AND codigo_ref = 1;
			
			IF pNum_Vencidos < 7 AND fIntenPago > 0 THEN -- Punto 1.3 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				VALUES 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '09');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			LET fIntenPago = 0;

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant  -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			  AND fecha_mov < (CASE WHEN cdiacorte > DAY(dfechaultdiames)
			                      then MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 1 UNITS DAY
								  ELSE MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 0 UNITS DAY
						     END
							) 
			  AND num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			  AND codigo_ref = 1;
			
			SELECT nvl(capital_mto_cuota,0)
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa   = pEmpresa
			  AND num_credito = cNumCredito_rees
              and num_pago = 1;
			
			IF fIntenPago >= (fAbonoMensual * .5) AND pNum_Vencidos < 13 then -- Punto 2.1 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '08');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			IF fIntenPago >= 50 AND pNum_Vencidos < 13 then -- Punto 2.2 RQM 09 274 Inciso B
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '10');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			LET fecha_mesant = dfechapridiames - 3 UNITS MONTH;
			LET fecha_mesant = fecha_mesant - 1 UNITS DAY;
			
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago_pres
			FROM movcrd
			WHERE fecha_mov >= fecha_mesant 
			  AND fecha_mov <= dFechaHoy --MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) con esta condicion se cambia para que sea de corte a corte
			  AND num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			  AND codigo_ref = 1;
			
			IF fIntenPago_pres >= ( SELECT (monto_otorgado * .2) FROM bdicred:sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = cNumCredito_rees ) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '11');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
		END IF;
	END IF;*/

	IF (pNum_Vencidos > 0) then
        LET cMesesVencidos = pNum_Vencidos;

			SELECT  LIMIT 1
						rpad(TRIM(NVL(cte.apell_paterno,'')),20,' ') AS apellpaterno,       --apellido 1
						rpad(TRIM(NVL(cte.apell_materno,'')),20,' ') AS apellmaterno,     --apellido 2
						rpad(TRIM(NVL(cte.nombre1,'')),20,' ') AS nombre1,      -- nombre 1
						rpad(TRIM(NVL(cte.nombre2,'')),20,' ') AS nombre2,      -- nombre 2
						rpad(TRIM(NVL(cte.rfc,'')),13,' ')     as rfc, -- rfc
						rpad(TRIM(NVL(cte.apell_casada,'')),26,' ') as apellcasada, -- apellido de casada
						rpad(TRIM(NVL(cte.sector,'')),2,' ') AS sector, -- sector
						lpad(TRIM(NVL(actesp.descripcion,'')),45,' ') as actividad, --actividad o giro de negocio

						NVL(ctepf.fecha_nac, date(1)) AS anionac,    -- año de nacimiento
						rpad(trim(NVL(ctepf.curp,'')),20,' ') as curp, -- curp
						rpad(trim(NVL(ctepf.sexo,'')),1,' ') as sexo, -- sexo
						rpad(trim(NVL(ctepf.estado_civil,'')),2,' ') as edocivil, -- estado civil
						rpad(trim(NVL(ctepf.numidentifi,'')),30,' ') as numidentificacion, --numero de identificación
						rpad(TRIM(NVL(em.correo_elec,'')),60,' ') as email, -- correo electronico

						rpad(TRIM(NVL(tipoidentif.descripcion,'')),40,' ') as tipoidentificacion, -- tipo de identificación

						rpad(TRIM(NVL(nac.descripcion,'')),15,' ') as nacionalidad, -- nacionalidad

						rpad(TRIM(NVL(ing.nombre_empresa,'')),25,' ') AS lugartrabajo,    -- lugar de trabajo
						NVL(ing.ingreso_mensual, 0) AS ingresomensual,     -- ingreso mensual
						rpad(TRIM(NVL(ing.puesto,'')),3,'0') as puesto, -- descripcion puesto
						rpad(trim(NVL(cte.numcte_ref,'')),20,' ') as referencia_coppel
			INTO
						cApellido1, cApellido2, cNombre1, cNombre2, cRfc, cApellidoCasada,
						cSector, cActividad, dFechaNac, cCurp, cSexo, cEdoCivil, cNumIdentificacion,
						cEmail, 
                        cTipoIdentificacion, cNacionalidad, cLugarTrabajo, mIngresoMensual, cPuesto,
                        cRefCoppel
			FROM  bdinteg:si_cliente cte
			LEFT OUTER JOIN bdinteg:si_actesp  actesp  ON (actesp.empresa= cte.empresa AND actesp.codigo=cte.actividad_esp)
			LEFT OUTER JOIN bdinteg:si_ctepf   ctepf   ON (ctepf.empresa=cte.empresa AND ctepf.numcte = cte.numcte)
			LEFT OUTER JOIN bdinteg:si_tipoidentif tipoidentif ON (tipoidentif.codidentif=ctepf.codidentifi)
			LEFT OUTER JOIN bdinteg:si_nacion nac  ON (nac.nacion = ctepf.nacionalidad)
		    LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa AND ing.tipo_ingreso = 'T' AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(sec_ingreso)
                                                                                                                                              FROM bdinteg:si_ingresos ing1
                                                                                                                                              WHERE ing1.empresa=cte.empresa
                                                                                                                                              AND ing1.numcte = cte.numcte
																																			  AND ing1.tipo_ingreso= 'T'))
            LEFT OUTER JOIN bdinteg:si_correos em ON (em.empresa=cte.empresa and em.numcte = cte.numcte and em.status_correo  = 'A' AND em.secuencia= (SELECT MAX(secuencia)
                                                                                                                                              FROM bdinteg:si_correos ema
                                                                                                                                              WHERE ema.empresa=cte.empresa
                                                                                                                                              AND ema.numcte = cte.numcte
																																			  AND ema.status_correo= 'A'))
			WHERE cte.numcte= cNumCte;

        SELECT
            --rpad(TRIM(NVL(edo1.nombre,'')),30,' ') as estado, -- descripcion del estado
            dir1.estado as estado, -- numero de estado
            case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0)
                 then dir1.numerociudad
                 ELSE zonas1.numerociudadcoppel
            END ciudad, -- numero de ciudad
            NVL(zonas1.poblacionzona, '')as poblacion,
            case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0)
                 then dir1.numerocolonia
                 ELSE zonas1.numerocoloniacoppel
            END colonia,  -- numero de colonia
            dir1.numerocalle as calle, -- numero de calle
            TRIM(dir1.numeroextcalle) AS numextcalle,   -- numero exterior
            TRIM(dir1.numerointcalle) AS numintecalle,  -- numero interior
            lpad(TRIM(dir1.cod_postal),5,'0') AS cod_postal,     -- codigo postal
            rpad(TRIM(dir1.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
            lpad(dir1.manzana,5,'0') AS manzana,     -- manzana
            lpad(dir1.andador,5,'0') AS andador,     -- andador
            lpad(dir1.etapa,5,'0')   AS etapa,     --etapa

            lpad(dir1.lote,5,'0')    AS lote,       -- lote
            lpad(dir1.edificio,5,'0') AS edificio,   --edificio
            lpad(dir1.entrada,5,'0') AS entrada,   -- entrada
            rpad(TRIM(dir1.departamento),6,' ') AS departamento,     -- departamento
            rpad(TRIM(dir1.observaciones),80,' ') AS complemento,  --   complemento
            rpad(TRIM(dir1.entre_calles),40,' ') AS entre_calles,    -- entre calles

            lpad(dir1.otros,2,'0') AS otros,     -- otros 
            
            --Domiclio de Trabajo
            dir2.estado as estadoTrab, --Numero de estado
            case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0)
                 then dir2.numerociudad
                 ELSE zonas2.numerociudadcoppel
            END ciudad, -- numero de ciudad trabajo
            NVL(zonas2.poblacionzona, '')as poblacionTrab,
            case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0)
                 then dir2.numerocolonia
                 ELSE zonas2.numerocoloniacoppel
            END colonia,  -- numero de colonia trabajo
            dir2.numerocalle as calle, -- numero de calle
            TRIM(dir2.numeroextcalle) AS numextcalleTrab,   -- numero exterior
            TRIM(dir2.numerointcalle) AS numintecalleTrab,  -- numero interior
            lpad(TRIM(dir2.cod_postal),5,'0') AS cod_postalTrab,     -- codigo postal
            rpad(TRIM(dir2.puntocardinal),1,' ') AS puntocardinalTrab,   -- punto cardinal
            lpad(dir2.manzana,5,'0') AS manzanaTrab,     -- manzana
            lpad(dir2.andador,5,'0') AS andadorTrab,     -- andador
            lpad(dir2.etapa,5,'0')   AS etapaTrab,     --etapa

            lpad(dir2.lote,5,'0')    AS loteTrab,       -- lote
            lpad(dir2.edificio,5,'0') AS edificioTrab,   --edificio
            lpad(dir2.entrada,5,'0') AS entradaTrab,   -- entrada
            rpad(TRIM(dir2.departamento),6,' ') AS departamentoTrab,     -- departamento
            rpad(TRIM(dir2.observaciones),80,' ') AS complementoTrab,  --   complemento
            rpad(TRIM(dir2.entre_calles),40,' ') AS entre_callesTrab,    -- entre calles
            lpad(dir2.otros,2,'0') AS otrosTrab
        INTO
            cNumEstado,     cNumCiudad,      cPoblacion,     cNumColonia,       cNumCalle,      cNumExterior,
            cNumInterior,   cCodPostal,      cPuntoCardinal, iManzana,          iandador,       iEtapa,
            iLote,          iEdificio,       iEntrada,       cDepartamento,     cComplemento,   cEntreCalles,
            sOtros,         /*cTelefono,       cTelefonoCel,   cTelTrab,          cExtTrab,*/

            cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
            cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iandadorTrab,       iEtapaTrab,
            iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
            iOtrosTrab
        FROM bdinteg:si_cliente cte
            LEFT OUTER JOIN bdinteg:si_direcciones_actual dir1        ON (dir1.numcte = cte.numcte AND dir1.tipo_dir  = '1')
            Left Outer Join bdinteg:si_catzonas    zonas1      On (dir1.numerociudad = zonas1.numerociudad AND dir1.numerocolonia = zonas1.numerocolonia)
            LEFT OUTER JOIN bdinteg:si_direcciones_actual dir2        ON (dir2.numcte = cte.numcte AND dir2.tipo_dir = '2')
            Left Outer Join bdinteg:si_catzonas    zonas2      On (dir2.numerociudad = zonas2.numerociudad AND dir2.numerocolonia = zonas2.numerocolonia)
        WHERE cte.NumCte     = cNumCte;

        -- Se obtiene el elemento respondido en la pregunta tiempo de residencia

        SELECT elemento
        INTO sElementoRes
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud= cNumCredito
        AND seccion= 2
        AND grupo  = 6;

        -- Se obtiene la descripcion del elemento respondido en la pregunta tiempo de residencia
        SELECT descripcion
        INTO cDescripcion
        FROM bdisolic:ss_scoring_element
        WHERE seccion = 2
        AND grupo = 6
        AND elemento = sElementoRes;

        --  Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual

		SELECT elemento
        INTO sElemResTrabajo
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud = cNumCredito
        AND seccion = 2
        AND grupo = 8;

        -- Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
        SELECT descripcion
        INTO cDescripPermTrabajo
        FROM bdisolic:ss_scoring_element
        WHERE seccion=2
        AND grupo=8
        AND elemento= sElemResTrabajo;


        select  nvl(rpad(TRIM(telefono),13,' '),' ') 
			into  cTelefono
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
			and tipo_tel = 1 and cofetel ='V';

		select  nvl(rpad(TRIM(telefono),13,' '),' ') 
			into  cTelefonoCel
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
			and tipo_tel = 2 and cofetel ='V'			;

		select  nvl(rpad(TRIM(telefono),13,' '),' ') ,rpad(NVL(extension,''), 13, ' ')
		into  cTelTrab, cExtTrab
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
			and tipo_tel = 3 and cofetel ='V';

----SEGUNDA PARTE DE CAMPOS

		IF  cNumProducto = '6001' then
            SELECT sucursal
            INTO cSucursal
            FROM bdisolic:ss_solicitudes
            WHERE empresa = pEmpresa
            AND num_solicitud = cNumCredito;
        ELSE
            SELECT sucursal
            INTO cSucursal
            FROM bdisolic:ss_solicitudes
            WHERE empresa = pEmpresa
            AND num_solicitud = cNumCredito_rees;
        END IF;

            -- se agrega los meses de historia, eficiencia coppel y variable hit o no hit
            SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END
            INTO cSituacionPago, cMesesHistoria, cEvaluacc
            FROM bdisolic:ss_resum_scor_fin
            WHERE empresa = pEmpresa
            AND num_solicitud = cNumCredito;
		
		IF  cNumProducto = '6001' then

            SELECT nvl(fecha_ultimo_pago, date(1)),monto_ultimo_pago,
                   nvl(fecha_ultima_compra, date(1)),monto_ultima_compra
              INTO dtFechaUltimoPago,dMontoUltimoPago,
                   dtFechaUltimaCompra,dMontoUltimaCompra
            FROM bdicred:"informix".sd_indicador_cred
            WHERE empresa   = pEmpresa
            AND num_credito = cNumCredito;

            IF dMontoUltimaCompra > 0 then

				let dFechaUltDisp = dtFechaUltimaCompra;
                let fMontoUltDisp = dMontoUltimaCompra; 

                SELECT limit 1 folio_suc into cFolioSuc
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                  AND fecha_mov = dFechaUltDisp
                  AND num_credito = cNumCredito
                  AND codigo_fun = '002' --and codigo_ref=40
                  AND reversado = 'N'
                  AND monto = dMontoUltimaCompra;

                SELECT {+INDEX (bdicred:sd_movhis inx_movhis6)} NVL(max(Monto),0)
                INTO fMontoComi
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                  AND fecha_mov = dFechaUltDisp
                  AND num_credito = cNumCredito
                  AND codigo_fun = '339'
                  AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19)
                  AND reversado = 'N'
				  AND folio_suc = cFolioSuc;
            ELSE
                LET fMontoUltDisp,fMontoComi = 0, 0;
            END IF;
--======================================
            IF dtFechaUltimoPago > dFechaUltDisp then
                LET cUltMov      = 'PAGO';
                LET dFechaUltMov = dtFechaUltimoPago;
            ELIF dtFechaUltimoPago = dFechaUltDisp then
                    IF dtFechaUltimoPago = date(1) then
                        LET cUltMov      = ''; --'NO hubo nada'
                        LET dFechaUltMov = dtFechaUltimoPago;
                    ELSE
                        LET cUltMov      = 'PAGO';
                        LET dFechaUltMov = dtFechaUltimoPago;
                    END IF;
            ELSE
                LET cUltMov      = 'DISP';
                LET dFechaUltMov = dFechaUltDisp;
            END IF;

            IF cUltMov = 'PAGO' then
                LET fMontoUltMov = NVL(dMontoUltimoPago,0);
            ELIF cUltMov = 'DISP' then
                LET fMontoUltMov = fMontoUltDisp;
            ELSE
                LET fMontoUltMov = 0;
            END IF;
--======================================
            LET fAbonoMensual,fSaldoMesAnt = 0, 0;

            FOREACH
                SELECT NVL(monto_financiado,0), --NVL(sdo_capinsoluto,0),
                       NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
                INTO fAbonoMensual, fSaldoMesAnt --, fSaldoMesAnt_2
                FROM bdicred:sd_maesdoshist
                WHERE empresa= pEmpresa
                AND num_credito = cNumCredito
--                AND fecha = MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy)) - 2 units month;
                AND fecha = 
                     (
                      SELECT NVL(max(fecha), dFechaHoy)
                      FROM bdicred:sd_maesdoshist
                      WHERE fecha < MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy))
                      AND empresa= pEmpresa
                      AND num_credito = cNumCredito
                     )

            END FOREACH;

            LET mMontoInteresCap, mMontoIvaIntCap = 0, 0;

            SELECT --sdo_capinsoluto,
                NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
                NVL(SUM(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
                NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0),
                NVL(SUM(NVL(b.mto_venc_tra_int,0)),0) -- INTERES CAPITALIZADO
            INTO fSaldoMesActual , --, fSaldoMesActual_2
                 fSaldoMesVencido,
                 fSaldoMesNoExig, 
                 mMontoInteresCap
            FROM bdicred:sd_maesdos b
            WHERE empresa= pEmpresa
            AND num_credito = cNumCredito;
		
            -- IVA CAPITALIZADO
            FOREACH
                SELECT first 2 monto
                INTO mMonto
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun  = '605'
                AND codigo_ref = 3
                AND reversado = 'N'
                order by fecha_mov desc

                LET mMontoIvaIntCap  = mMontoIvaIntCap + mMonto;

            END FOREACH;

          -- Se  Obtiene el iva correspondiente a la sucursal que se asoció al Credito
            SELECT iva
            INTO mPorcIva
            FROM bdinteg:si_sucursales
            WHERE empresa = pempresa
            AND sucursal = cNumSucursal;

            -- Se obtiene los Intereses orden
            SELECT d.int_tra_no_exig
            INTO mIntVencido_ord
            FROM bdicred:sd_maesdos d
            WHERE d.empresa= pEmpresa
            AND d.num_credito= cNumCredito;

           --  Se obtiene el Iva de los Intereses Vigentes
           SELECT SUM(iva_debe - iva_pagado)
           INTO mIvaIntVencido_ord
           FROM sd_amortiza_credito d
           WHERE d.empresa = pEmpresa
           AND d.num_credito = cNumCredito
           AND capital_status IN ('1','2','7');

         IF (fSaldoMesActual < 1000) AND pNum_Vencidos < 13 then
			INSERT INTO bdicred:sd_exclusiones_ventacartera
			(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
			VALUES
			('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '12');
			
			continue FOREACH;
		 END IF;

		 /*IF (cEmail <> '' ) AND pNum_Vencidos < 13 then
			INSERT INTO bdicred:sd_exclusiones_ventacartera
			(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
			VALUES 
			('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '07');
			
			continue FOREACH;
         END IF;*/

     -- Se obtiene el Iva de Intereses Moratorio pagado
/*
         SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
         INTO mIvaIntMoraTotal
         FROM sd_amortiza_credito
         WHERE empresa = pempresa 
         AND num_credito = cNumCredito
         AND capital_status IN ("2","7")
         AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;
*/

          -- Se obtiene el Interes Moratorio Copete
          SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
                 NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
                 NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
                 NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
          INTO mIntMoraCope,
               mIvaIntMoraCope,
               mIntMoraOrdi,
               mIvaIntMoraOrdi
          FROM sd_amortiza_credito
          WHERE  empresa = pempresa
          AND num_credito = cNumCredito
          AND capital_status IN ("2","7");

    	  IF mIntMoraCope IS NULL OR  mIntMoraCope < 0 THEN
             LET mIntMoraCope = 0;
          END IF;

          IF mIvaIntMoraCope IS NULL OR  mIvaIntMoraCope < 0 THEN
             LET mIvaIntMoraCope = 0;
          END IF;

          IF mIntMoraOrdi IS NULL OR  mIntMoraOrdi < 0 THEN
             LET mIntMoraOrdi = 0;
          END IF;

          IF mIvaIntMoraOrdi IS NULL OR  mIvaIntMoraOrdi < 0 THEN
             LET mIvaIntMoraOrdi = 0;
          END IF;

/*
          if (mIntMoraCope + mIntMoraOrdi) > 0 then
            let mIvaIntMoraTotal = (mIvaIntMoraCope + mIvaIntMoraOrdi) - mIvaIntMoraTotal;
          else
            let mIvaIntMoraTotal = 0;
          end if;

          IF (mIvaIntMoraCope >= mIvaIntMoraTotal) then
             let mIvaIntMoraCope = mIvaIntMoraCope - mIvaIntMoraTotal;
             let mIvaIntMoraTotal = 0;
          else
             let mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraCope;
             let mIvaIntMoraCope = 0;
          end if;

          IF (mIvaIntMoraOrdi >= mIvaIntMoraTotal) then
             let mIvaIntMoraOrdi = mIvaIntMoraOrdi - mIvaIntMoraTotal;
             let mIvaIntMoraTotal = 0;
          else
             let mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraOrdi;
             let mIvaIntMoraOrdi = 0;
          end if;
		  
*/

          SELECT limit 1 num_tarjeta
          INTO cNumTarjeta
          FROM bdicred:sd_tarjeta
          WHERE empresa = pEmpresa
          AND tipo_tarjeta = 'T'
          AND status_tar = 'A'
          AND num_credito  = cNumCredito;

		  IF cNumTarjeta is null then
			SELECT limit 1 num_tarjeta
			INTO cNumTarjeta
			FROM bdicred:sd_tarjeta
			WHERE empresa = pEmpresa
			AND tipo_tarjeta = 'T'
			AND num_credito  = cNumCredito
			AND secuencia =
				(
				 SELECT NVL(max(secuencia),0)
				 FROM bdicred:sd_tarjeta
				 WHERE empresa = pEmpresa
				 AND tipo_tarjeta = 'T'
				 AND num_credito  = cNumCredito
				);
		  END IF;

            LET cNumTarjeta = NVL(cNumTarjeta, '');


		ELSE --- Campos para Reestructura y Préstamo Personal

			SELECT monto_otorgado,0
			INTO fMontoUltDisp,fMontoComi
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees;
	 
			SELECT NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
				   NVL(SUM(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
				   NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual,
				 fSaldoMesVencido,
				 fSaldoMesNoExig
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees;
			
			LET mMontoInteresCap, mMontoIvaIntCap = 0,0;
			
			LET fecha_mesant = dfechapridiames - 1 UNITS MONTH; 
			
			SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
			INTO fSaldoMesAnt
			FROM bdicred:sd_maesdoshistcrd
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees
			AND fecha =  ( SELECT NVL(max(fecha), dFechaHoy)
						  FROM bdicred:sd_maesdoshistcrd
					      WHERE fecha >= fecha_mesant AND empresa= pEmpresa
					      AND num_credito = cNumCredito_rees);
				
            if (cNumProducto = '6300') then
                SELECT NVL(max(fecha_mov), date(1)), COUNT(*)
                INTO dFechaUltPago, iCuantosPagos
                FROM movcrd
                WHERE num_credito = cNumCredito_rees
                  AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
                  AND codigo_ref = 1;

                SELECT NVL(SUM(monto),0)
                INTO fMontoPago
                FROM movcrd
                WHERE fecha_mov = dFechaUltPago
                  AND num_credito = cNumCredito_rees
                  AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
                  AND codigo_ref = 1;

            else
                SELECT NVL(max(fecha_mov), date(1)), COUNT(*)
                INTO dFechaUltPago, iCuantosPagos
                FROM movcrd
                WHERE num_credito = cNumCredito_rees
                AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
                AND codigo_ref = 1;

                SELECT NVL(SUM(monto),0)
                INTO fMontoPago
                FROM movcrd
                WHERE fecha_mov = dFechaUltPago
                  AND num_credito = cNumCredito_rees
                  AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
                  AND codigo_ref = 1;

            end if;
		
		   LET dFechaUltDisp = cFechaApertura;

			IF dFechaUltPago > cFechaApertura then
				LET cUltMov      = 'PAGO';
				LET dFechaUltMov = dFechaUltPago;
				LET fMontoUltMov = NVL(fMontoPago,0);
			ELSE
				LET cUltMov      = 'APER';
				LET dFechaUltMov = cFechaApertura;
				LET fMontoUltMov = NVL(fMontoUltDisp,0);
			   
			END IF;
	
		   	IF cNumProducto = '6011' THEN
                IF cStatusCred = 'BT' THEN
                --balanza y orden
                    select nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(interes_debe - interes_pagado,0) else 0 end),0),
                           nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(iva_debe - iva_pagado,0) else 0 end),0),
                           nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
                           nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
                    INTO mIntVencido_bal, mIvaIntVencido_bal,
                         mIntVencido_ord, mIvaIntVencido_ord
                    from bdicred:sd_amortiza_creditocrd a, movcrd b
                    where a.empresa = pEmpresa
                      and a.num_credito = cNumCredito_rees
                      and a.num_credito = b.num_credito
                      and a.capital_status in ('2','7')
                      and b.codigo_fun = '602' 
                      and b.codigo_ref = 2;
                ELSE
                    select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO mIntVencido_ord, mIvaIntVencido_ord
                    FROM bdicred:sd_amortiza_creditocrd
                    WHERE empresa = pEmpresa
                    AND num_credito= cNumCredito_rees
                    AND capital_status in ('2','7');
                END IF;
			   
				LET mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope = 0,0,0,0;
			   
			ELIF cNumProducto = '6300' THEN

            --balanza y orden
                select nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(interes_debe - interes_pagado,0) else 0 end),0),
                       nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(iva_debe - iva_pagado,0) else 0 end),0),
                       nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
                       nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
                INTO mIntVencido_bal, mIvaIntVencido_bal,
                     mIntVencido_ord, mIvaIntVencido_ord
                from bdicred:sd_amortiza_creditocrd a, movcrd b
                where a.empresa = pEmpresa
                  and a.num_credito = cNumCredito_rees
                  and a.num_credito = b.num_credito
                  and a.capital_status in ('2','7')
                  and b.codigo_fun = '026' 
                  and b.codigo_ref = 3;

				LET mPorcIva = '';				
				SELECT iva
				INTO mPorcIva
				FROM bdinteg:si_sucursales
				WHERE empresa = pempresa
				AND sucursal = cNumSucursal;				   


				-- Se obtiene el Iva de Intereses Moratorio pagado
/*
				SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
				INTO mIvaIntMoraTotal
				FROM sd_amortiza_creditocrd
				WHERE empresa = pempresa
				AND num_credito = cNumCredito_rees
				AND capital_status IN ("2","7")
				AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;
*/

				 -- Se obtiene el Interes Moratorio Copete
				 SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
						NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
						NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
						NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
				  INTO mIntMoraCope,
					   mIvaIntMoraCope,
					   mIntMoraOrdi,
					   mIvaIntMoraOrdi
				  FROM sd_amortiza_creditocrd
				  WHERE empresa = pempresa
				  AND num_credito = cNumCredito_rees
				  AND capital_status IN ("2","7");
			   
		   END IF;		   

		   LET cNumTarjeta = '';	
	   
		END IF;
		
		BEGIN WORK;		
		   INSERT INTO bdicobranza:cb_rep_cart_quebrantar
			(   Num_Credito,    NumCte,
				Apellido1,      Apellido2,          Nombre1,            Nombre2,            Rfc        ,    ApellidoCasada,
				Sector,         FechaNac,           Curp,               Sexo,               EdoCivil   ,    NumIdentificacion,
				Email,          TipoIdentificacion, Nacionalidad,
				NumEstado,      NumCiudad,          Poblacion,          NumColonia,         NumCalle,       NumExterior,
				NumInterior,    CodPostal,          PuntoCardinal,      Manzana,            andador,        Etapa      ,
				Lote,           Edificio,           Entrada,            Departamento,       Complemento,    EntreCalles,
				Otros,          SituacionEsp,       CausaSitEsp,
				IngresoMensual, Puesto,             LugarTrabajo,       Telefono,           TelTrab,        ExtTrab,
				AntigDomic,     AntigTrab,          Actividad,
				NumEstadoTrab,  NumCiudadTrab,      PoblacionTrab,      NumColoniaTrab,     NumCalleTrab,   NumExteriorTrab,
				NumInteriorTrab,CodPostalTrab,      PuntoCardinalTrab,  ManzanaTrab,        andadorTrab,    EtapaTrab,
				LoteTrab,       EdificioTrab,       EntradaTrab,        DepartamentoTrab,   ComplementoTrab,EntreCallesTrab,
				OtrosTrab,
				Sucursal,               Fecha_Ult_Disp,         Monto_Ult_Disp,
				Monto_Comi_Ult_Disp ,   Abono_Mensual_Al_Qub,   Int_Capit,          Iva_Int_Capit ,
				Sdo_Mes_Ant,            Sdo_Actual          ,   Sdo_Vencido,        Sdo_No_Exig,        Fecha_Ult_Mov,      Tipo_Ult_Mov  ,
				Monto_Ult_Mov,          Int_Vencido,            Iva_Int_Vencido,    Int_Vencido_bal,   Iva_Int_Vencido_bal ,
				Int_Mora_Ordi,          Iva_Int_Mora_Ordi ,     Int_Mora_Cope ,     Iva_Int_Mora_Cope , Meses_Vencidos, Numero_Tarjeta,				
			   ReferenciaCoppel, fechareporte,
			   fechaapertura, telefonocel, situacionpago, meseshistoria, evaluacc, monto_otorgado, producto
			)
			Values
			(   case when CNumproducto = '6001' then cNumCredito ELSE cNumCredito_rees END ,        
				cNumCte,
				cApellido1,         cApellido2,         cNombre1,           cNombre2,           cRfc,               cApellidoCasada,
				cSector,            dFechaNac,          cCurp,              cSexo,              cEdoCivil,          cNumIdentificacion,
				cEmail,             cTipoIdentificacion,cNacionalidad,
				cNumEstado,         cNumCiudad,         cPoblacion,         cNumColonia,           cNumCalle,             cNumExterior,
				cNumInterior,       cCodPostal,         cPuntoCardinal,     iManzana,           iandador,           iEtapa,
				iLote,              iEdificio,          iEntrada,           cDepartamento,      cComplemento,       cEntreCalles,
				sOtros,             cSituacion,         sCausa,
				mIngresoMensual,    cPuesto,            cLugarTrabajo,      cTelefono,          cTelTrab,           cExtTrab,
				cDescripcion,       cDescripPermTrabajo,cActividad,
				cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
				cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iandadorTrab,       iEtapaTrab,
				iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
				iOtrosTrab,
				cNumSucursal,           dFechaUltDisp ,          fMontoUltDisp,
				fMontoComi,             fAbonoMensual,          mMontoInteresCap,       mMontoIvaIntCap,
				fSaldoMesAnt,           fSaldoMesActual,        fSaldoMesVencido,       fSaldoMesNoExig,    dFechaUltMov,           cUltMov,
				fMontoUltMov,			mIntVencido_ord,       mIvaIntVencido_ord,       mIntVencido_bal,   mIvaIntVencido_bal, 
                mIntMoraOrdi , mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope , cMesesVencidos, cNumTarjeta,
				--cNumCte,
				cRefCoppel, date(CURRENT),
				cFechaApertura, cTelefonoCel, cSituacionPago, cMesesHistoria, cEvaluacc, pMonto_otorgado, cNumproducto
			);
			/*IF  cNumProducto = '6001' then 
				LET cNumRegTotal_TC = cNumRegTotal_TC + 1;
				LET sSaldoActTotal_TC = sSaldoActTotal_TC + fSaldoMesActual;
				UPDATE sd_maecred
				   SET id_unidad_prod = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito;
			EL*/
			IF cNumProducto = '6011' then 			
				LET cNumRegTotal_Rees = cNumRegTotal_Rees + 1;
				LET sSaldoActTotal_Rees = sSaldoActTotal_Rees + fSaldoMesActual;
				UPDATE sd_maecredcrd
				   SET id_origen = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito_rees;
			ELIF cNumProducto = '6300' then 				
				LET cNumRegTotal_pres = cNumRegTotal_Pres + 1;
				LET sSaldoActTotal_Pres = sSaldoActTotal_Pres + fSaldoMesActual;
				UPDATE sd_maecredcrd
				   SET id_origen = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito_rees;
			END IF;		
		COMMIT WORK;
	END IF;	
        LET mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord = 0,0,0,0;
    END FOREACH;

    --INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6001', cNumRegTotal_TC,sSaldoActTotal_TC,date(CURRENT));
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6011', cNumRegTotal_Rees,sSaldoActTotal_Rees,date(CURRENT));
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6300', cNumRegTotal_Pres,sSaldoActTotal_Pres,date(CURRENT));

    EXECUTE PROCEDURE "informix".sp_gen_rep_cartera_quebrantar('001') INTO P_COD_RET;
	
	UPDATE bdicred:sd_maecred
	   SET id_unidad_prod = 1
	 WHERE empresa = '001'
	   AND num_credito in ( select  num_credito  
                     from bdicred:sd_exclusiones_ventacartera 
                    where motivo_exclusion = 14 
                      AND fecha_exclusion = today);
	
	UPDATE bdicobranza:cb_rep_cart_quebrantar
	SET excluido = 'E'
	WHERE num_credito in ( select  num_credito  
                     from bdicred:sd_exclusiones_ventacartera 
                    where motivo_exclusion = 14 
                      AND fecha_exclusion = today);	

    IF P_COD_RET <> '000000' then
       LET cMensajeRet = 'ERROR en la descarga de archivos para el reporte VENTA DE CARTERA';
       RETURN P_COD_RET, cMensajeRet;
    END IF;
	
	
    LET cMensajeRet = 'El proceso de VENTA DE CARTERA se realizó correctamente';

    LET P_COD_RET = '000000';
	
	---Actualizando tabla de parámetros con valor igual a 0 cuando este sp se ejecute correctamente para que se puedan excluir los nuevos creditos
	IF  P_COD_RET = '000000'  then 
						UPDATE bdicred:sd_param
							SET valor = '0' 
							WHERE cod_param = '108';		
	END IF;						
    TRUNCATE TABLE bdicred:sd_ctes_excluidos_vta;
	
    RETURN P_COD_RET,cMensajeRet;

END;
END procedure
DOCUMENT
'Version: 20130419.1116',
'Modificación : Se Modificó SP para actualizar la tabla bdicred:sd_param con el campo valor = 0 cuando termine de ejecutarse correctamente el proceso',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Abril 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_rep_aumlincred
(
psempresa CHAR(3)
)

RETURNING CHAR(5) AS codretorno

--****************************************************************************************************
-- DESCRIPCION: Genera reporte de incrementos de linea de credito preautorizados por central.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 01/07/2011
-- BD: bdicred
-- SISTEMA : Aumlincred
--****************************************************************************************************
DEFINE vsnomreporte CHAR(33);
DEFINE vssql CHAR (6555) ;
DEFINE vssql1 CHAR (155);
DEFINE vssql2 CHAR (6000) ;
DEFINE vssql3 CHAR (400);
DEFINE vsrepositorio CHAR(90);
DEFINE vscodretorno CHAR(5);
DEFINE vsultimodiames CHAR(10);
DEFINE visqlerr INTEGER;
DEFINE vsSQLO CHAR (370);

LET vsnomreporte = "";
LET vsSQL = "";
LET vssql1 = "";
LET vssql2 = "";
LET vssql3 = "";
LET vsrepositorio = "";
LET vscodretorno = "";
LET vsultimodiames = "";
LET visqlerr = 0;
LET vsSQLO = '';

BEGIN

ON EXCEPTION SET visqlerr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF visqlerr <> 0 THEN
		RETURN visqlerr;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/macf/sp_rep_aumlincred.trc';
--TRACE ON;


IF(psempresa = "001")THEN
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT pri_dia_mes - 1 INTO vsultimodiames FROM bdicred:"informix".sd_fechas;

	LET vsultimodiames = SUBSTRING(vsultimodiames FROM 4 FOR 2) || SUBSTRING(vsultimodiames FROM 1 FOR 2) || SUBSTRING(vsultimodiames FROM 7 FOR 4);
	LET vsrepositorio = "/resplogifx/archivoscartera/";
	LET vsnomreporte = "rep_incremento_linea_" || TRIM(vsultimodiames) || ".txt";
    --- numero de incrementos previos (SELECT COUNT(numcte) FROM bdicred:sd_bitacora_aumlincred WHERE empresa = '001' and num_solicitud = ba.num_solicitud AND status = 'AP')
	LET vsSQL1 = 'echo " set isolation to dirty read; UNLOAD TO ' || TRIM(vsrepositorio) || TRIM(vsnomreporte) || ' DELIMITER ' || '''|''';
	LET vsSQL2 = " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, NVL(TRIM(ba.num_per_porutimay_806),'N/A'), NVL(TRIM(ba.num_per_porutimay_8012),'N/A'), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status, ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'"" ), ' '), ba.lincred_sugerida, ba.califica_buro, NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v, ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
  || " AND ba.fecha_insert <= (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status IN('AT','IN') "
	|| " UNION ALL  "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), ba.lincred_actual, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806), TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), nvl(ba.causa_status,' '), ba.hora_status, "
  || " nvl(ba.sucursal_at,' '), nvl(ba.ejecutivo,' '), NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), ba.lincred_sugerida, nvl(ba.califica_buro,' '), NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v, ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"    
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status = 'AP' "
	|| " UNION ALL "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806), TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status,  ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), 0.0 , ba.califica_buro, NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v , ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status = 'RT' "
	|| " UNION ALL "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0) , TRIM(ba.grado_riesgo) , ba.monto_reserva , NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' ') , ba.int_cred_ven , ba.porc_uso , ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806) , TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status, ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), 0.0 , ba.califica_buro , NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A') , ba.cte_noestit_v , ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred_hist AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito "; 
	LET vsSQL3 = ' " > '|| TRIM(vsrepositorio) || 'control_reporte.sql';
	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = trim(vsSQL1) || ' ' || trim(vsSQL2) || trim(vsSQL3);
	
  		
			IF ( vsSQL <> '' ) THEN 
				SYSTEM vsSQL ;
				--Permiso para la creacion de archivo.
				LET vsSQLO = '';
				LET vsSQLO = 'chmod 666 ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				LET vsSQLO = TRIM(vsSQLO);
				LET vsSQLO = '';
				LET vsSQLO = 'dbaccess bdicred ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				LET vsSQLO = TRIM(vsSQLO);
				SYSTEM vsSQLO;
	
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				SYSTEM vsSQL ;
	
				LET vsSQL = '' ;
				LET vsSQL = 'gzip ' || TRIM(vsrepositorio) || TRIM(vsnomreporte);
				SYSTEM vsSQL ;

				LET vscodretorno = '00000';
			
			ELSE -- CONSULTA VACIA
				LET vscodretorno = '00002';
			END IF;
	
ELSE
	LET vscodretorno = '00001';
END IF;

RETURN vscodretorno;
END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Aumento Linea de Credito',
'Solicito: Ricardo Sanchez Sanchez',
'Descripcion: Genera reporte de incrementos de linea de credito preautorizados por central.',
'Fecha: 2011/07/04',
'Version: 20110704.1800',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_mueve_movdiacrd_fecha(pEmpresa char(3),pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
--    DEFINE pfecha       date; 
    DEFINE vrowid       integer;   
    DEFINE vnumcredito  CHAR(20);
    DEFINE vfolio_suc   CHAR(16);
    DEFINE vfecha_mov   DATE;
    DEFINE vhora_mov    DATETIME HOUR to FRACTION(3);
    DEFINE vsucursal    CHAR(4);


    LET vnumcredito  = "";
    LET vrowid       = 0;   
    LET vnumcredito  = "";
    LET vfolio_suc   = "";
    LET vfecha_mov   = DATE(1);
    LET vhora_mov    = "";
    LET vsucursal    = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
 --SET DEBUG FILE TO "/pisa/leo/sp_mueve_movdia.out";
 --TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;


    SELECT * FROM bdicred:sd_movdiacrd
    WHERE empresa = pEmpresa AND fecha_mov = pfecha
    INTO temp movdiacrd1 WITH NO LOG;


    CREATE INDEX idxmovdiacrd1 on movdiacrd1(empresa, secuencia, fecha_mov, hora_mov, sucursal, num_credito);
    CREATE INDEX idxmovdiacrd2 on movdiacrd1(num_credito,secuencia);

   FOREACH WITH HOLD
        SELECT secuencia, fecha_mov, hora_mov, sucursal, num_credito
          INTO vrowid ,vfecha_mov,vhora_mov,vsucursal,vnumcredito
          FROM movdiacrd1


           BEGIN WORK;
              INSERT INTO bdicred:sd_movhiscrd
              SELECT * FROM bdicred:movdiacrd1 where num_credito = vnumcredito and  secuencia = vrowid;

              DELETE FROM bdicred:sd_movdiacrd WHERE secuencia = vrowid
                                                AND  fecha_mov = vfecha_mov
                                                AND  hora_mov = vhora_mov
                                                AND  sucursal = vsucursal
                                                AND  num_credito = vnumcredito;
           COMMIT WORK;

        LET vrowid     = 0;
        LET vfecha_mov = "";
        LET vhora_mov  = "";
        LET vsucursal  = "";
        LET vnumcredito = "";
        
   END FOREACH;
   
    IF cCodRet <> '000' THEN
            LET cMensaje = "Fallo proceso";
            LET cCodRet =  cCodRet;
 
    ELSE
          LET cMensaje = "Proceso Concluido"; 
    END IF; 
  END;

  DROP TABLE movdiacrd1;

 RETURN cCodRet,cMensaje;

END PROCEDURE;