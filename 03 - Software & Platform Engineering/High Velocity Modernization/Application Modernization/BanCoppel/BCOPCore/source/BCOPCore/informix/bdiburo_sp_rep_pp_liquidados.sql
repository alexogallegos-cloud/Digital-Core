create procedure "informix".sp_rep_pp_liquidados()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_ultimo_mes       DATE;
DEFINE v_primero_mes        DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte        CHAR(08); 

DEFINE vsql                 CHAR(1500);

DEFINE cruta                CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE vdescripcion         CHAR(40);
DEFINE vtotal				INTEGER;
DEFINE vmeses				INTEGER;
DEFINE vproducto			CHAR(4);
DEFINE vperiodos			INTEGER;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET cruta                   = "";
LET cnomarchivo             = "";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;  
		  RETURN cCodRet, cMensajeRet;
	END EXCEPTION;

--SET DEBUG FILE TO "sp_rep_pp_liquidados.out";
--TRACE ON; 

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT pri_dia_mes -1, pri_dia_mes -  1 units MONTH
	  INTO v_ultimo_mes,v_primero_mes
	FROM bdicred:sd_fechas
	WHERE empresa = '001';

	LET vano = YEAR(v_ultimo_mes);
	LET vmes = LPAD(MONTH(v_ultimo_mes),2,"0");
	LET vdia = LPAD(DAY(v_ultimo_mes),2,"0");
	LET vfecha_reporte = vdia||vmes||vano;

--temporal para pruebas
   --let v_ultimo_mes = mdy('07','31','2014');
   --let v_primero_mes  = mdy('07','01','2014');
--temporal para pruebas

	SELECT valor
	  INTO cruta
	FROM bdiburo:br_param
	WHERE cod_param = 139;

	SELECT valor||vfecha_reporte||'.txt'
	  INTO cnomarchivo
	FROM bdiburo:br_param
	WHERE cod_param = 145;

--Procesa Liquidaciones de prestamos Antes de Vencimiento
	SET ISOLATION TO DIRTY READ;
	SELECT a.num_Credito,num_producto,a.fecha_apertura,
	CASE WHEN num_producto ='6300' THEN 12
		 WHEN num_producto ='7600' THEN 18
		 WHEN num_producto ='7700' THEN 24 END periodo,
	CASE WHEN num_producto ='6300' THEN (fecha_apertura + 12 units MONTH) 
		 WHEN num_producto ='7600' THEN (fecha_apertura + 18 units MONTH) 
		 WHEN num_producto ='7700' THEN (fecha_apertura + 24 units MONTH) END  fecha_venc_real,fecha_ult_pago
	FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
	ON a.num_credito = b.num_Credito AND fecha_ult_pago BETWEEN v_primero_mes AND v_ultimo_mes
	WHERE num_producto in ('6300','7600','7700')
	AND status_cred = 'FF'
	INTO temp paso1_FF WITH NO LOG;

	SELECT * ,( YEAR(fecha_ult_pago)-YEAR(fecha_apertura))*12 +(MONTH(fecha_ult_pago)-MONTH(fecha_apertura)) meses_entre_ap_y_pago,
	periodo-(( YEAR(fecha_ult_pago)-YEAR(fecha_apertura))*12 +(MONTH(fecha_ult_pago)-MONTH(fecha_apertura))) meses_liq_antes_venc
	FROM paso1_FF
	INTO temp paso2_FF WITH NO LOG;

	DROP TABLE paso1_FF;


	SELECT num_producto, meses_liq_antes_venc,count(*) t_sols
	FROM paso2_FF
	WHERE meses_liq_antes_venc > 0
	group by 1,2
	INTO temp ff_liquidados WITH NO LOG;

	DROP TABLE paso2_FF;

	--Poner Titulo al archivo.
	LET vsql='';
	LET vsql = 'echo "REPORTE DE PRESTAMOS PERSONALES LIQUIDADOS ANTES DE VENCIMIENTO" >'||TRIM(cruta)|| cnomarchivo;
	SYSTEM vsql; 

    --Poner encabezados.
	LET vsql='';
    LET vsql = 'echo "PRODUCTO     MESES ANTES 		CREDITOS" >> '||TRIM(cruta)|| cnomarchivo;
	SYSTEM vsql; 
	
   	LET vsql='';
    LET vsql = 'echo "			DE VENCIMIENTO     " >> '||TRIM(cruta)|| cnomarchivo;
    SYSTEM vsql; 

	LET vtotal =0;

	FOREACH WITH HOLD

		SELECT num_producto, CASE WHEN num_producto = '6300' THEN 12
								  WHEN num_producto = '7600' THEN 18
								  WHEN num_producto = '7700' THEN 24 END periodo,MIN(meses_liq_antes_venc)
		INTO vproducto, vperiodos, vmeses
		FROM ff_liquidados
		GROUP BY 1
		ORDER BY 1
		
		
		WHILE (vmeses <= vperiodos) LOOP

			SELECT NVL(t_sols,0)
			  INTO vtotal
			FROM ff_liquidados
			WHERE num_producto = vproducto
			and meses_liq_antes_venc = vmeses;
		
			IF vtotal > 0 THEN
				--Pone listado dentro del reporte
				LET vsql='';
				LET vsql = 'echo "'||vproducto||'             '||lpad(vmeses,2,0)||'              '||vtotal||'" >> '||TRIM(cruta)|| cnomarchivo;
				SYSTEM vsql; 
			END IF;
        
			LET vmeses = vmeses + 1;
		END LOOP;	
	END foreach

	DROP TABLE ff_liquidados;

--Procesa Liquidaciones de prestamos Antes de Venta
	SET ISOLATION TO DIRTY READ;
	SELECT a.num_credito,c.num_producto,c.fecha_apertura, a.fecha  f_venta,
	CASE WHEN num_producto ='6300' THEN 12
         WHEN num_producto ='7600' THEN 18
         WHEN num_producto ='7700' THEN 24 end periodo,
	CASE WHEN num_producto ='6300' THEN (fecha_apertura + 12 units MONTH) 
         WHEN num_producto ='7600' THEN (fecha_apertura + 18 units MONTH) 
         WHEN num_producto ='7700' THEN (fecha_apertura + 24 units MONTH) end  fecha_venc_real
	FROM bdicred:sd_maesdoscrd_vendida a INNER JOIN bdicobranza:cb_rep_cart_quebrantar b
	  ON a.num_credito = b.num_credito AND b.fechareporte BETWEEN mdy('03','01','2016') AND mdy('03','31','2016')
	INNER JOIN bdicred:sd_maecredcrd c 
	  ON a.empresa =c.empresa AND a.num_credito = c.num_credito AND status_Cred = 'CV'
	WHERE a.empresa = '001'
	  AND fecha BETWEEN mdy('03','01','2016') AND mdy('03','31','2016')
      AND num_producto in ('6300','7600','7700')
	INTO TEMP paso1_CV with no log;


	SELECT * ,( YEAR(f_venta)-YEAR(fecha_apertura))*12 +(MONTH(f_venta)-MONTH(fecha_apertura)) meses_entre_ap_y_pago,
	periodo-(( YEAR(f_venta)-YEAR(fecha_apertura))*12 +(MONTH(f_venta)-MONTH(fecha_apertura))) meses_liq_antes_venc
	FROM paso1_CV
	INTO TEMP paso2_CV;

	DROP TABLE paso1_CV;

	SELECT num_producto, meses_liq_antes_venc,count(*) t_sols
	FROM paso2_CV
	WHERE meses_liq_antes_venc > 0
	group by 1,2
	INTO temp cv_liquidados WITH NO LOG;

	DROP TABLE paso2_CV;
	
	--Poner Titulo de VENDIDOS.
	LET vsql='';
	LET vsql = 'echo "REPORTE DE PRESTAMOS PERSONALES VENDIDOS ANTES DE VENCIMIENTO" >>'||TRIM(cruta)|| cnomarchivo;
	SYSTEM vsql; 

    --Poner encabezados.
	LET vsql='';
    LET vsql = 'echo "PRODUCTO     MESES ANTES 		CREDITOS" >> '||TRIM(cruta)|| cnomarchivo;
	SYSTEM vsql; 
	
   	LET vsql='';
    LET vsql = 'echo "			DE VENCIMIENTO     " >> '||TRIM(cruta)|| cnomarchivo;
    SYSTEM vsql; 

	LET vtotal =0;

	FOREACH WITH HOLD

		SELECT num_producto, CASE WHEN num_producto = '6300' THEN 12
								  WHEN num_producto = '7600' THEN 18
								  WHEN num_producto = '7700' THEN 24 END periodo,MIN(meses_liq_antes_venc)
		INTO vproducto, vperiodos, vmeses
		FROM cv_liquidados
		GROUP BY 1
		ORDER BY 1
		
		
		WHILE (vmeses <= vperiodos) LOOP

			SELECT NVL(t_sols,0)
			  INTO vtotal
			FROM cv_liquidados
			WHERE num_producto = vproducto
			and meses_liq_antes_venc = vmeses;
		
			IF vtotal > 0 THEN
				--Pone listado dentro del reporte
				LET vsql='';
				LET vsql = 'echo "'||vproducto||'             '||lpad(vmeses,2,0)||'              '||vtotal||'" >> '||TRIM(cruta)|| cnomarchivo;
				SYSTEM vsql; 
			END IF;
        
			LET vmeses = vmeses + 1;
		END LOOP;	
	END foreach

	DROP TABLE cv_liquidados;
	
	
	
LET cCodRet     = "00000";
LET cMensajeRet = "Reporte Prestamos Liquidados "||vfecha_reporte|| " Ok.";

RETURN cCodRet, cMensajeRet; 

END;
END procedure;